
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

    public void showDataStream(){
        pushMatrix();
        pushStyle();
        stroke(255, 0, 0);
        strokeWeight(10);

        PVector from2d = from.get2dPosition();
        PVector to2d = to.get2dPosition();

        line(from2d.x, from2d.y, to2d.x, to2d.y);

        popStyle();
        popMatrix();
    }

}
