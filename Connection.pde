
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
        showDataStream();
    }

    public void showDataStream(){
        pushMatrix();
        pushStyle();
        stroke(255, 0, 0);
        strokeWeight(2);

        line(from.tx, from.ty, to.tx, to.ty);

        popStyle();
        popMatrix();
    }

}
