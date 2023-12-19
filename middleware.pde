
class Middleware {
  
  ArrayList<Device> devices;
  
  public Middleware(ArrayList<Device> devices){
    this.devices = devices;

    subscribeToTopics();

    // TEST CONNECTIONS
    devices.get(0).getEventWithName("OnBlueButtonDown").connect(devices.get(2), "TurnOff");
    devices.get(1).getEventWithName("OnChange").connect(devices.get(2), "TurnOn");

  }

  public void subscribeToTopics(){
    for(Device device : devices){
      for (String topic : device.getTopics()){
        mqtt.subscribe(topic);
      }
    }
  }

  public Device getDevice (int id) {
    for (Device device : devices) {
      if (device.id == id) {
        return device;
      }
    }

    return null;
  }

  public Device getDeviceWithName (String name) {
    for (Device device : devices) {
      if (device.name.equals(name)) {
        return device;
      }
    }

    return null;
  }

  public void update(){
    for (Device device: devices){
      device.tick();

      for (Device other: devices) {
        if (device.name == other.name) continue;

        // Check if device is in range
        if (!device.isInRange(other)) continue;

        // Check which nodes are near.
        for (DeviceEvent ourNode : device.events){
          for (DeviceEvent otherNode : other.events) {
            if (ourNode.type == otherNode.type) continue;
              
              // Calculate distance between nodes
              float distance = ourNode.getDistance(otherNode);
              if (distance > 100) continue;

              // Check if connection already exists
              boolean connectionExists = false;
              for (Connection con : ourNode.connections) {
                if (con.to.name == otherNode.name) {
                  connectionExists = true;
                  continue;
                }
              }
              
              // Activate connection timer
              device.setConnectionReqStart(other);
          }
        }
      }
    }
  }

  public void draw(){
    for (Device device: devices){
      for (DeviceEvent event: device.events){
        for (Connection con: event.connections) {
          con.showDataStream();
        }
      }
    }
  }

}
