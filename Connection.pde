
class Connection {
    String id;
    Device from;
    Device to;
    String method;
    ArrayList<Float> dataUnits;

    public Connection(Device from, Device to, String method){
        this.from = from;
        this.to = to;
        this.method = method;
        this.dataUnits = new ArrayList<Float>();
    }

    public void handle (){
        to.trigger(method);
        this.addDataUnit();
    }

    public void addDataUnit(){
        dataUnits.add(new Float(0));
    }

    public void tick(){
        ArrayList<Float> newDataUnits = new ArrayList<Float>();
        for (int i = 0; i < dataUnits.size(); i++){
            float dataUnit = dataUnits.get(i);
            dataUnit += 0.01;

            if (dataUnit < 1) newDataUnits.add(dataUnit);
        }
        this.dataUnits = newDataUnits;
    }

    public void showDataStream(){
        tick();
        
        pushMatrix();
        pushStyle();
        stroke(255, 0, 0);
        strokeWeight(10);

        PVector from2d = from.get2dPosition();
        PVector to2d = to.get2dPosition();

        // Draw a line from2d to to2d, but don't draw the first and last 100 pixels
        PVector direction = PVector.sub(to2d, from2d);
        direction.normalize();
        direction.mult(100);
        from2d.add(direction);
        to2d.sub(direction);

        line(from2d.x, from2d.y, to2d.x, to2d.y);

        for (int i = 0; i < dataUnits.size(); i++){
            float dataUnit = dataUnits.get(i);
            float x = map(dataUnit, 0, 1, from2d.x, to2d.x);
            float y = map(dataUnit, 0, 1, from2d.y, to2d.y);
            fill(255, 0, 0);
            circle(x, y, 25);
        }

        popStyle();
        popMatrix();
    }

}
