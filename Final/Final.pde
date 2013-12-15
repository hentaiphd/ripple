import arb.soundcipher.*;

int s = 0;

PFont fontL;
PFont fontB;

int[] r = new int[5];
int[] g = new int[5];
int[] b = new int[5];

PVector circlePosition;
ArrayList<PVector> circleTrail;
int trailSize;

int nodeCount;
int rCount;//number of ripples
int diaIncreaseRate; //diameter increasing rate
int strokeDecreaseRate; //stroke weight decreasing rate
int alphaS;//alpha value of the stroke
float nodeX;
float nodeY;

int score;
int widthRect;
boolean playing;
boolean start;

SoundCipher sc = new SoundCipher(this);
SoundCipher sc1 = new SoundCipher(this);
float keyRoot;
float density;

Ripple[] ri;
Node[] myNodes;

void setup(){
  //ripple stuff
  rCount = 50;
  diaIncreaseRate = 1;
  strokeDecreaseRate = 10;
  alphaS = int(random(1,60));
  ri = new Ripple[rCount];
  
  //node and trail stuff
  nodeCount = 1;
  myNodes = new Node[nodeCount];
  trailSize = 5;
  circlePosition = new PVector(width*0.5, width*0.5);
  circleTrail = new ArrayList<PVector>();
  
  //game state stuff
  playing = false;
  start = true;
  score = 0;
  widthRect = 100;
  
  //sound
  keyRoot = 0;
  density = 0.8;
  sc.instrument(118);//118* 125
  sc1.instrument(10);//10 90 118* 125
  
  //font
  fontL = loadFont("NexaLight.vlw");
  fontB = loadFont("NexaBold.vlw");
  
  //screen and colors
  size(500,500);
  noFill();
  smooth(8);

  r[0] = int(14);
  g[0] = int(190);
  b[0] = int(204);
  
  r[1] = int(87);
  g[1] = int(148);
  b[1] = int(153);
  
  r[2] = int(43);
  g[2] = int(255);
  b[2] = int(152);
  
  r[3] = int(255);
  g[3] = int(107);
  b[3] = int(121);
  
  r[4] = int(204);
  g[4] = int(14);
  b[4] = int(127);

  //node and ripple init
  for (int i = 0; i < nodeCount; i++) {
    myNodes[i] = new Node(random(width), random(height));
    myNodes[i].velocity.x = random(-3, 3);
    myNodes[i].velocity.y = random(-3, 3);
    myNodes[i].damping = .01;
    
    for(int x=0; x<rCount; x++)
      ri[x] = new Ripple(int(myNodes[0].x),int(myNodes[0].y),0,0,int(110),int(176),int(255),alphaS);
  
  }
}


void draw(){ 
  //start screen
  if(start){
    background(43,255,152);
    startScreenRipples();
    
    //text
    textFont(fontB, 30);
    text("Click to cast a ray.", 80, 220);
    textFont(fontL, 25);
    text("Try to catch the node", 80, 250);
    text("before your ray gets too weak.",80,275);
    
    //switch state
    if(mousePressed){
      start = false;
      playing = true;
    }
  }
  
  if(playing == true){
    s++;
    stroke(55,88,127);
    
    for(int node = 0; node < nodeCount; node++){
      //ripples
      for(int i=0; i<rCount; i++){
          //reset
          if(ri[i].sw==0){
            ri[i].x = int(myNodes[node].x);
            ri[i].y = int(myNodes[node].y);
            int colors = int(random(0,4)); 
            ri[i].sr = r[colors];
            ri[i].sg = g[colors];
            ri[i].sb = b[colors];
            ri[i].sa = int(random(1,100))/*alphaS*/;
            ri[i].d = 0;
            ri[i].sw = int(random(1,100));
          }
          //update
          ri[i].d += diaIncreaseRate; //increase the diameter
          if(ri[i].d%strokeDecreaseRate==0) ri[i].sw--; //decrease the stroke weight
          //render
          strokeWeight(1);
          stroke(ri[i].sr, ri[i].sg, ri[i].sb, ri[i].sa);
          if(ri[i].x != 0) ellipse(ri[i].x, ri[i].y, ri[i].d, ri[i].d);  
        } 
        
      myNodes[node].update();
      fill(255,50);
      
      //drawing trail
      trail(myNodes[node].x, myNodes[node].y);
      
      //score
      textFont(fontB, 20);
      fill(43,255,152);
      rect(10,10,20,24,10);
      fill(255);
      text(str(score), 15, 29);
      noFill();
      
      //make the node move erratically
      if(s%10==0){
        for (int i = 0; i < nodeCount; i++) {
          sc.playNote(20+(myNodes[i].y/height)*(107-20), random(90)+30, random(20)/10 + 0.2);
          myNodes[i].velocity.x = random(-10, 10);
          myNodes[i].velocity.y = random(-10, 10);
          //saving these for collision detection
          nodeX = myNodes[i].x;
          nodeY = myNodes[i].y; 
        }
      }
    }
  } else if(start == false && playing == false) {
      //endstate  
      noStroke();
      noFill();
      startScreenRipples();
      color col = color(43,255,152);
      fill(col,90);
      rect(175, 0, 160, height);
      fill(255);
      textFont(fontL, 30);
      text("score", 217, 200);
      textFont(fontB, 30);
      text(str(score), 245, 240);
      textFont(fontL, 20);
      text("click to restart", 191, 275);
  }
    
  if(widthRect == 0){
    playing = false; 
  }
}

void mouseReleased(){
  if(start == false && playing == false) {
    //reset
    setup();
  }
  //draw the rectangle and check if node is colliding with it
  if(playing){
    widthRect -= 10;
    strokeWeight(3);
    rect(mouseX, -5, widthRect, height+20);
    noFill();
    
    if(nodeX > mouseX){
      if(nodeX < mouseX + widthRect){
        score++;
        sc1.playNote(60+(nodeY/height)*(100-60), random(90)+30, random(20)/10 + 0.2);
        println(str(score));
        textFont(fontL, 30);
        fill(43,255,152);
      }
    }
  }
}

void trail(float nodeX, float nodeY){
  int trailLength;
  circlePosition = new PVector(nodeX, nodeY);
  circleTrail.add(circlePosition);

  trailLength = circleTrail.size() - 2;

  for (int t = 0; t < trailLength; t++) {
    PVector currentTrail = circleTrail.get(t);
    PVector previousTrail = circleTrail.get(t + 1);

    stroke(43,255,152,255*t/trailLength);
    strokeWeight(3);
    smooth(8);
    line(
      currentTrail.x, currentTrail.y,
      previousTrail.x, previousTrail.y
    );
  }

  if (trailLength >= trailSize) {
    circleTrail.remove(0);
  }
}

void startScreenRipples(){
for(int node = 0; node < nodeCount; node++){
  //ripples
  for(int i=0; i<rCount; i++){
      //reset
      if(ri[i].sw==0){
        ri[i].x = int(myNodes[node].x);
        ri[i].y = int(myNodes[node].y);
        int colors = int(random(0,4)); 
        ri[i].sr = r[colors];
        ri[i].sg = g[colors];
        ri[i].sb = b[colors];
        ri[i].sa = int(random(1,100))/*alphaS*/;
        ri[i].d = 0;
        ri[i].sw = int(random(1,100));
      }
      //update
      ri[i].d += diaIncreaseRate; //increase the diameter
      if(ri[i].d%strokeDecreaseRate==0) ri[i].sw--; //decrease the stroke weight
      //render
      strokeWeight(1);
      stroke(ri[i].sr, ri[i].sg, ri[i].sb, ri[i].sa);
      if(ri[i].x != 0) ellipse(ri[i].x, ri[i].y, ri[i].d, ri[i].d);  
    } 
  }
}

/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/51756*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/*
  Ripples
  Author: Yen-Chia Hsu, CoDe Lab, Carnegie Mellon University, U.S.A.
*/

class Ripple{
  int x,y,d,sw,sr,sg,sb,sa;
  //x: center X coordinate
  //y: center Y coordinate
  //d: diameter
  //sw: stroke weight
  //sr: stroke color R
  //sg: stroke color G
  //sb: stroke color B
  //sa: stroke color alpha
  Ripple (int x_in,int y_in,int d_in,int sw_in,int sr_in,int sg_in,int sb_in,int sa_in)
  { x=x_in; y=y_in; d=d_in; sw=sw_in; sr=sr_in; sg=sg_in; sb=sb_in; sa=sa_in;}
}  

//README for Node
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

class Node extends PVector {

  // velocity
  PVector velocity = new PVector();

  // minimum and maximum posiions
  float minX=5, minY=5, maxX=width-5, maxY=height-5;

  // damping of the velocity (0 = no damping, 1 = full damping)
  float damping = 0.1;


  Node(float theX, float theY) {
    x = theX;
    y = theY;
  }

  // ------ calculate new position of the node ------
  void update() {
    x += velocity.x;
    y += velocity.y;

    if (x < minX) {
      x = minX - (x - minX);
      velocity.x = -velocity.x;
    }
    if (x > maxX) {
      x = maxX - (x - maxX);
      velocity.x = -velocity.x;
    }

    if (y < minY) {
      y = minY - (y - minY);
      velocity.y = -velocity.y;
    }
    if (y > maxY) {
      y = maxY - (y - maxY);
      velocity.y = -velocity.y;
    }

    velocity.x *= (1-damping);
    velocity.y *= (1-damping);
  }
}
