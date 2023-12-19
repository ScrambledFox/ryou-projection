//trigger your events here


void tagPresent3D(int id, float tx, float ty, float tz, float rx, float ry, float rz) {
    if(serialDebug && !isCorner(id)) println("+ Tag:", id, "loc = (", tx, ",", ty, ",", tz, "), angle = (", degrees(rx),",",degrees(ry),",",degrees(rz),")");
}

void tagAbsent3D(int id, float tx, float ty, float tz, float rx, float ry, float rz) {
    if(serialDebug && !isCorner(id)) println("- Tag:", id, "loc = (", tx, ",", ty, ",", tz,"), angle = (", degrees(rx),",",degrees(ry),",",degrees(rz),")");
}

void tagUpdate3D(int id, float tx, float ty, float tz, float rx, float ry, float rz) {
    //if(serialDebug && !isCorner(id)) println("% Tag:", id, "loc = (", tx, ",", ty, ",", tz,"), angle = (", degrees(rx),",",degrees(ry),",",degrees(rz),")");
}

void tagPresent2D(int id, float x, float y, float z, float yaw) { 
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    println("+ Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void tagAbsent2D(int id, float x, float y, float z, float yaw) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    println("- Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void tagUpdate2D(int id, float x, float y, float z, float yaw) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    float distance = distancePointToPlane(new PVector(x, y, z), planePoints);
    //println("% Tag:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw),", d= ",distance);
  }
}

void bundlePresent2D(int id, float x, float y, float z, float yaw) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    println("+ Bundle:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void bundleAbsent2D(int id, float x, float y, float z, float yaw) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    println("- Bundle:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw));
  }
}

void bundleUpdate2D(int id, float x, float y, float z, float yaw) {
  if (serialDebug && homographyMatrixCalculated && !isCorner(id)) {
    PVector t = img2screen(transformPoint(new PVector(x, y, z), homography));
    float distance = distancePointToPlane(new PVector(x, y, z), planePoints);
    //println("% Bundle:", id, "loc = (", t.x, ",", t.y, "), angle = ", degrees(yaw),", d= ",distance);
  }
}
