import peasy.*;
PeasyCam cam;

float angle = 0;
float x, y, z;
float r = 300; // Size of the globe

PImage earth;
PShape globe;

Table table; // table to store the data
String url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.csv";

float d_angle = 0.05; // amount of radians the globe turns
int dayLength = 240;//round(2*PI/d_angle);//

int N_stars = 100;
ArrayList<Star> stars = new ArrayList<Star>();

int textsize = 40;
PFont Font;

int t = 0; // counter for time of the day
float angleY = 0;
float angleX = 0;


void setup() {
  size(800, 800, P3D);
  translate(width/2, height/2);
  
  cam = new PeasyCam(this, width/2, height/2, 0, max(width, height));
  
  table = loadTable(url, "header");

  earth  = loadImage("earth.jpg");
  earth.resize(width, width/2);
  
  noStroke();
  globe = createShape(SPHERE, r);
  globe.setTexture(earth);
  
  for (int i=0; i<N_stars; i++) {
    stars.add(new Star());
  }
  Font = createFont("Sans Serif", textsize);
}



void draw() {
  clear();
  background(11);
  
  translate(width/2, height/2);
  
  // display the day of the month
  textFont(Font);
  fill(255);
  noStroke();
  String txt = "Day "+str(t/dayLength+1);
  text(txt, -width/2+textsize/2, -height/2+1.5*textsize, 0);
  
  for (Star s : stars) {
    s.show();
  }
  
  // rotate to get the correct orientation of the globe
  rotateX(-23*PI/180);
  rotateY(PI/3);
  
  // rotate the sphere as the day progresses
  rotateY(angle);
  angle += d_angle;
  
  lights();
  noStroke();
  shape(globe);
  
  
  for (TableRow row : table.rows()) {
    // extract data from the table
    // convert strings to floats 
    float lat = row.getFloat("latitude");
    float lon = row.getFloat("longitude");
    float mag = row.getFloat("mag");
    String time = row.getString("time");
    String dayString = match(time, "-[0-9][0-9]T")[0].replace("-", "").replace("T", "");
    int day = Integer.parseInt(dayString);
    String hourString = match(time, "T[0-9][0-9]")[0].replace("T", "");
    int hour = Integer.parseInt(hourString);
    
    // adapt latidude and longitude values because 
    // the processing coordinate system is different 
    // from the coordinate system used for the earth
    lat *= -1;
    lon = 180 - lon;
    
    // Spherical to cartesian coordinates
    x = r*cos(radians(lat))*cos(radians(lon));
    z = r*cos(radians(lat))*sin(radians(lon));
    y = r*sin(radians(lat));
    
    // convert magnitude of the earthquake to a height for the box
    float h = pow(10, mag);
    // avoid NaN
    h = Float.isNaN(h)? 0 : h;
    // limit max height of the boxes
    float maxh = pow(10,7);
    h = map(h, 0, maxh, 2, 100);
    
    // only display earthquake data for the current day
    if (t>0 && t%dayLength != 0 && day == t/dayLength+1) {
      // only display  earthquake data for the current hour of the day
      if ((t%dayLength)%10 != 0 && hour == (t%dayLength)/10) {
        // display magnitude of the earthquake as a red box
        // height of the box is measure for the magnitude
        PVector xAxis = new PVector(1,0,0);
        PVector pos = new PVector(x,y,z);
        float angleX = PVector.angleBetween(xAxis, pos);
        PVector rAxis = xAxis.cross(pos);
        
        pushMatrix();
        translate(x, y, z);
        rotate(angleX, rAxis.x, rAxis.y, rAxis.z);
        rotateX(angleX);
        fill(255, 0, 0);
        box(h, 5, 5);
        popMatrix();
      }
    }
  }
  
  t++;
  
  if (t/dayLength+1 == 31) {
    t = 0;
  }
}



// Star class to display in the background
class Star {
  PVector pos;
  float r, bright;
  float d;
  Star() {
    d = 3000;
    pos = PVector.random3D().mult(d);
    this.r = random(1, 5);
    bright = random(0,180);
  }
  
  void show() {
    stroke(bright);
    strokeWeight(r);
    point(pos.x, pos.y, pos.z);
  }
}
