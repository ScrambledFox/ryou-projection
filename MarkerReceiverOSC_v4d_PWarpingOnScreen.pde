//*********************************************
// Example Code: ArUCo Fiducial Marker Detection in OpenCV Python and then send to Processing via OSC
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import org.ejml.simple.SimpleMatrix;
import oscP5.*;
import mqtt.*;
import netP5.*;
import processing.net.*;

TagManager tm;
Middleware mw;
MQTTClient mqtt;
OscP5 oscP5;
boolean serialDebug = true;

int[] cornersID = {1, 3, 2, 0};
int[][] bundlesIDs = {{21},{14}};
PVector[][] bundlesOffsets = {{new PVector(0,0,-0.124)},{new PVector(0,0,-0.048)}};
int camWidth = 1280;
int camHeight = 720;

float touchThreshold = 0.015; //unit: m

float paperWidthOnScreen = 297; //unit: mm
float markerWidth = 50; //unit: mm

PImage calibImg; 

void setup() {
  size(1280, 720);
  oscP5 = new OscP5(this, 9000);
  initMqtt();
  initMiddleware();
  initTagManager();
  calibImg = loadImage("ArUco_Grid50.png");
  imageOffset.set((width - calibImg.width)/2 , (height - calibImg.height)/2);
}

void draw() {
  tm.update();
  mw.update();
  homographyMatrixCalculated = true;
  if (!homographyMatrixCalculated) {
    background(100);
    drawCalibImage();
    if (cornersDetected()) {
      calculateHomographyMatrix();
      registerPlanePoints();
      homographyMatrixCalculated = true;
    }
    //tm.displayRaw(); 
  } else {
    background(10);
    drawCanvas();
    tm.display2D(homography);
  }
}


void drawCalibImage(){
  pushStyle();
  imageMode(CENTER);
  image(calibImg,width/2,height/2,(float)calibImg.width*tag2screenRatio,(float)calibImg.height*tag2screenRatio);
  popStyle();
}

void drawCanvas(){
  pushStyle();
  noStroke();
  fill(0);
  rectMode(CENTER);
  rect(width/2,height/2,(float)calibImg.width*tag2screenRatio,(float)calibImg.height*tag2screenRatio);
  popStyle();
}

void showInfo(String s,int x, int y){
  pushStyle();
  fill(52);
  textAlign(LEFT, BOTTOM);
  textSize(48);
  text(s, x, y);
  popStyle();
}
