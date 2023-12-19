
class Middleware {
  
  ArrayList<Device> devices;
  
  public Middleware(ArrayList<Device> devices){
    this.devices = devices;

    subscribeToTopics();

    // TEST CONNECTIONS
    devices.get(0).getEventWithName("OnBlueButtonDown").connect(devices.get(2), "TurnOn");
    devices.get(0).getEventWithName("OnBlueButtonUp").connect(devices.get(2), "TurnOff");

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

  void update(){}

}

void helloWorld(){
  println("Hello World");
}
