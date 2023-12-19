
class Connection {
    String id;
    Device from;
    Device to;
    String method;

    public Connection(Device from, Device to, String method){
        this.from = from;
        this.to = to;
        this.method = method;
    }

    public void handle (){
        to.trigger(method);
    }

}
