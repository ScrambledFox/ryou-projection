// MQTT Handler

void initMqtt(){
   mqtt = new MQTTClient(this);
   mqtt.connect("mqtt://localhost:1883", "ryou-vis");
}

void clientConnected () {
  println("MQTT Connected!");
  
  mqtt.subscribe("/hello");
}

void messageReceived(String topic, byte[] payload){
  println("new message: "+ topic + " - " + new String(payload));

  // Topic looks like: ryou/<id>/<eventName>
  String[] topicParts = split(topic, '/');
  // Parse int
  String name = topicParts[1];
  String eventName = topicParts[2];

  println("name: " + name + " event: " + eventName);

  // Get device with id
  Device device = mw.getDeviceWithName(name);
  if(device == null){
    println("Device not found: " + name);
    return;
  }

  device.handleIncomingEvent(eventName, new String(payload));
}

void connectionLost(){
  println("MQTT Connection Lost!");
}
