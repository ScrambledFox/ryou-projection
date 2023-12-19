import java.util.function.*;

class Device {
  int TTL = 500;
  int TTC = 1000;
  String name;
  int id;
  ArrayList<DeviceEvent> events;

  boolean active = false;
  float tx, ty, tz, rx, ry, rz;
  long ts, tc;
  
  public Device (String _name, int _id, ArrayList<DeviceEvent> _events) {
      this.name = _name;
      this.id = _id;
      this.events = _events;
      this.ts = 0;
      this.tc = 0;
  }
  
  public Device(){
    // super("", 0, new ArrayList<DeviceEvent>());
  }
  
  public void setAbsent(){
    if (!this.active) return;
    
    this.active = false;
    this.ts = millis();
  }

  public void updatePosition (float tx, float ty, float tz, float rx, float ry, float rz) {
    this.tx = tx;
    this.ty = ty;
    this.tz = tz;
    this.rx = rx;
    this.ry = ry;
    this.rz = rz;
    
    this.active = true;
    calculateNodePosition(this.get2dPosition());
  }

  public void calculateNodePosition (PVector local2d) {
    float eventAngle = 0;
    float globalAngle = this.getAngle2d();
    for (DeviceEvent event : events) {
      float eventD = 150/2;
      float eventR = eventD/2;
      float eventX = eventR * 3.5 * cos(eventAngle);
      float eventY = eventR * 3.5 * sin(eventAngle);
      event.nodePosition = new PVector(eventX, eventY);
      
      float globalX = local2d.x +  eventR * 3.5 * cos(globalAngle + eventAngle);
      float globalY = local2d.y +  eventR * 3.5 * sin(globalAngle + eventAngle);
      
      event.globalPosition = new PVector(globalX, globalY);
      eventAngle += TWO_PI/this.events.size();
    }
  }

  DeviceEvent ourEvent;
  Device otherTryConnect;
  DeviceEvent otherEvent;
  public void setConnectionReqStart (DeviceEvent ourEvent, Device other, DeviceEvent otherEvent){
    if (otherTryConnect != null) return;
    
    println("TRY CON: " + ourEvent.name + " -> "+ otherEvent.name);
    
    println("------------------------------------------------------------ Setting connection request start");
    this.ourEvent = ourEvent;
    this.otherTryConnect = other;
    this.otherEvent = otherEvent;
    this.tc = millis();
  }

  public boolean isInRange (Device other) {
    PVector me = this.get2dPosition();
    PVector them = other.get2dPosition();
    return them.dist(me) < 450;
  }
  
  public void tick(){
    if (this.otherTryConnect != null && (millis() - this.tc) > this.TTC){
      println("------------------------------------------------------------- Setting connection request end");
      this.ourEvent.connect(this.otherTryConnect, this.otherEvent.name);
      this.ourEvent = null;
      this.otherTryConnect = null;
      this.otherEvent = null;
    }
    
    if (!this.active && (millis() - this.ts) > this.TTL){
      this.clearConnections();
    }

    
  }

  public void clearConnections () {
    for(DeviceEvent event: this.events){
      event.clearConnections();
    }    
  }

  public PVector get2dPosition () {
    return img2screen(transformPoint(new PVector(tx, ty, tz), homography));
  }
  
  public float getAngle2d (){
    return this.rz-globalR.z;
  }

  public ArrayList<String> getTopics() {
    ArrayList<String> topics = new ArrayList<String>();
    for (DeviceEvent event : events) {
      topics.add("ryou/" + this.name + "/" + event.name);
    }
    return topics;
  }

  public DeviceEvent getEventWithName (String eventName) {
    for (DeviceEvent event : events) {
      if (event.name.equals(eventName)) {
        return event;
      }
    }

    return null;
  }

  public void trigger (String eventName) {
    DeviceEvent event = getEventWithName(eventName);
    if (event != null) {
      event.trigger();
    }
  }

  public void handleIncomingEvent (String name, String payload) {
    DeviceEvent event = getEventWithName(name);
    if (event != null) {
      event.handle(payload);
    }
  }
  
}

class DeviceEvent {
  Device device;
  String name;
  String type;
  PVector nodePosition;
  PVector globalPosition;

  ArrayList<Connection> connections;

  public DeviceEvent( Device _device, String _name, String _type ){
    this.device = _device;
    this.name = _name;
    this.type = _type;

    this.connections = new ArrayList<Connection>();
    this.nodePosition = new PVector(0, 0);
    this.globalPosition = new PVector(0, 0);
}

  public void connect (Device other, String method) {
    println("Connecting event " + name + " with the following event with name " + other.name + " and method "+  method );
    DeviceEvent otherEvent = other.getEventWithName(method);
    connections.add(new Connection(this.device, other, this, otherEvent, method));
  }

  public float getDistance ( DeviceEvent other ) {
    return this.globalPosition.dist(other.globalPosition);
  }
  
  public void clearConnections() {
    connections = new ArrayList<Connection>();
  }

  public void trigger () {
    println("Triggering event " + name);
    String topic = "ryou/" + device.name + "/" + name;
    mqtt.publish(topic, "");
  }

  public void handle (String payload) {
    println("Handling event " + name + " with payload " + payload);

    if (type.equals("output")) {
      for (Connection connection : connections) {
        connection.handle();
      }
    }
  }
  
}
