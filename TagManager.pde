class TagManager {
  Tag[] tags;
  ArrayList<Bundle> tagBundles;
  PMatrix3D R1;
  PMatrix3D R2;
  int TAG_D = 150;
  int BUNDLE_D = 300;
  
  TagManager(int n, ArrayList b_ids, ArrayList b_offs) {
    tags = new Tag[n];
    this.tagBundles = new ArrayList<Bundle>();
    for (int i = 0; i < n; i++) {
      tags[i] = new Tag(i);
    }
    for (int i = 0; i < b_ids.size(); i++) {
      ArrayList<Integer> ids = (ArrayList<Integer>) b_ids.get(i);
      ArrayList<PVector> offs = (ArrayList<PVector>) b_offs.get(i);
      this.tagBundles.add(new Bundle(ids, offs));
    }
  }

  Tag getWithId(int id) {
    for (Tag t : tags) {
      if (t.id == id) {
        return t;
      }
    }
    
    return null;
  }

  void set(int id, float tx, float ty, float tz, float rx, float ry, float rz, PVector[] corners) {
    //tags[id].set(tx, ty, tz, rx-globalR.x, ry-globalR.y, rz-globalR.z, corners);
    tags[id].set(tx, ty, tz, rx, ry, rz, corners);
  }

  void update() {
    for (Tag t : this.tags) {
      t.checkActive();
    }
    for (Bundle b : this.tagBundles) {
      ArrayList<Tag> activeTags = new ArrayList<Tag>();
      for (Integer id : b.ids) {
        if (tags[id].active) {
          activeTags.add(tags[id]);
        }
      }
      if (activeTags.size() > 0) {
        PVector loc = new PVector(0, 0, 0);
        PVector ori = new PVector(0, 0, 0);

        for (Tag t : activeTags) {
          PVector O = new PVector(t.tx, t.ty, t.tz);
          PVector offset = b.getOffsetFromID(t.id);
          PVector v = new PVector(0, 0, offset.z);
          R1 = new PMatrix3D();
          R1.rotateZ(-t.rz);
          R1.rotateX(t.rx);
          R1.rotateY(t.ry);
          R1.rotateZ(t.rz);
          PVector rotated_v = new PVector();
          R1.mult(v, rotated_v);
          PVector P = new PVector(O.x - rotated_v.x, O.y + rotated_v.y, O.z + rotated_v.z); // x is inversed because of the inversed coordinate

          PVector w = new PVector(offset.x, offset.y, 0);
          R2 = new PMatrix3D();
          R2.rotateX(t.rx);
          R2.rotateY(t.ry);
          R2.rotateZ(t.rz);
          PVector rotated_w = new PVector();
          R2.mult(w, rotated_w);
          PVector P_prime = new PVector(P.x - rotated_w.x, P.y + rotated_w.y, P.z + rotated_w.z); // x is inversed because of the inversed coordinate
          loc.add(new PVector(P_prime.x, P_prime.y, P_prime.z));
          ori.add(new PVector(t.rx, t.ry, t.rz));
        }

        loc.div(activeTags.size());
        ori.div(activeTags.size());
        b.set(loc.x, loc.y, loc.z, ori.x, ori.y, ori.z);
      } else {
        b.setInactive();
      }
    }
  }

  void displayRaw() {
    for (Tag t : tags) {
      if (t.active) {
        pushMatrix();
        pushStyle();
        noStroke();
        fill(255, 0, 0);
        ellipse(t.corners[0].x, t.corners[0].y, 5, 5);
        fill(255, 255, 0);
        ellipse(t.corners[1].x, t.corners[1].y, 5, 5);
        fill(0, 255, 255);
        ellipse(t.corners[2].x, t.corners[2].y, 5, 5);
        fill(0, 0, 255);
        ellipse(t.corners[3].x, t.corners[3].y, 5, 5);
        fill(0, 0, 255);


        beginShape();
        fill(255);
        stroke(0, 255, 0);
        for (int i = 0; i < 4; i++) {
          vertex(t.corners[i].x, t.corners[i].y);
        }
        endShape(CLOSE);

        fill(52);
        noStroke();

        PVector c = new PVector((t.corners[0].x+t.corners[2].x)/2, (t.corners[0].y+t.corners[2].y)/2);
        String s = "(x,y)=("+nf(round(t.tx*100))+","+nf(round(t.ty*100))+")\nz="+nf(round(t.tz*100));
        textAlign(CENTER, CENTER);
        textSize(18);
        text("ID="+t.id+"\n"+s, c.x, c.y);
        popStyle();
        popMatrix();
      }
    }
  }
  
  void display2D(SimpleMatrix homography) {
    for (Tag t : tags) {
      if (!isCorner(t.id) && t.active) {
        float tagD = TAG_D;
        float angle2D = t.rz-globalR.z;
        PVector loc2D = img2screen(transformPoint(new PVector(t.tx, t.ty, t.tz), homography));
        float distance = distancePointToPlane(new PVector(t.tx, t.ty, t.tz), planePoints);
        if(distance<touchThreshold) drawTagSimple(t.id, loc2D, angle2D, tagD, color(100)); //example visualization
        else drawTagSimple(t.id, loc2D, angle2D, tagD, color(100,100));
      }
    }
    for (Bundle b : tagBundles) {
      if (b.active) {
        float bundleD = BUNDLE_D;
        float angle2D = b.rz-globalR.z;
        PVector loc2D = img2screen(transformPoint(new PVector(b.tx, b.ty, b.tz), homography));
        float distance = distancePointToPlane(new PVector(b.tx, b.ty, b.tz), planePoints);
        if(distance<touchThreshold) drawTagSimple(b.ids.get(0), loc2D, angle2D, bundleD, color(0, 127, 255)); //example visualization
        else drawTagSimple(b.ids.get(0), loc2D, angle2D, bundleD, color(0, 127, 255, 100)); //example visualization
      }
    }
  }

  void drawTagSimple(int id, PVector loc2D, float angle2D, float D, color c) {
    float R = D/2;
    pushMatrix();
    pushStyle();
    noFill();
    strokeWeight(5);
    stroke(255);
    //ellipse(loc2D.x, loc2D.y, D, D);
    translate(loc2D.x, loc2D.y);
    rotate(angle2D);
    rect(-D/2, -D/2, D, D);
    //line(R * (cos(angle2D)), R * (sin(angle2D)), R * 1.25 * (cos(angle2D)), R * 1.25 * (sin(angle2D)));
    fill(255);
    noStroke();
    textSize(R);
    textAlign(CENTER, CENTER);
    text(id, 0, -D);
    popStyle();
    popMatrix();
  }

}
