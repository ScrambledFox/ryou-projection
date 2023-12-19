import java.util.function.*;

class Device {
  String name;
  int id;
  ArrayList<DeviceEvent> events;

  float tx, ty, tz, rx, ry, rz;
  
  public Device (String _name, int _id, ArrayList<DeviceEvent> _events) {
      this.name = _name;
      this.id = _id;
      this.events = _events;
  }
  
  public Device(){
    // super("", 0, new ArrayList<DeviceEvent>());
  }

  public void updatePosition (float tx, float ty, float tz, float rx, float ry, float rz) {
    this.tx = tx;
    this.ty = ty;
    this.tz = tz;
    this.rx = rx;
    this.ry = ry;
    this.rz = rz;
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

  ArrayList<Connection> connections;

  public DeviceEvent( Device _device, String _name, String _type ){
    this.device = _device;
    this.name = _name;
    this.type = _type;

    this.connections = new ArrayList<Connection>();
  }

  public void connect (Device other, String method) {
    println("Connecting event " + name + "with the following event with name " + other.name + " and method "+  method );
    connections.add(new Connection(this.device, other, method));
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
