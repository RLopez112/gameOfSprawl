import gifAnimation.*;

GifMaker gifExport;


int cellSize = 5;    // Size of cells

String gifName;
float probabilityOfAliveAtStart = 15;  // How likely for a cell to be alive at start (in percentage)

// Variables for timer
int interval = 100;
int lastRecordedTime = 0;

// Colors for active/inactive cells
color alive = color(150,150,150);
color dead = color(200,200,200);
color virgin = color(255,255,255);
color water = color(240,255,240);


int[][] cells; // Array of cells 

int[][] cellsBuffer; // Buffer to record the state of the cells and use this while changing the others in the interations 

boolean pause = false;

float state; //initialization based on pixel brightness. dead(0) alive(255) water(190)

float initialitation_state;

PImage img;


// ===

void setup() {
  
  gifName = "montevideo";
  
  img = loadImage("static/base_montevideo.png");
  size(1549,767);
  img.loadPixels();


  gifExport = new GifMaker(this, "out/"+gifName+".gif");
  gifExport.setRepeat(0); // 0 means "loop forever"
  
  // Instantiate arrays 
  cells = new int[width/cellSize][height/cellSize];
  cellsBuffer = new int[width/cellSize][height/cellSize];


  

  noSmooth();

// Initialization of cells
  for (int x=0; x<width/cellSize; x++) {
    
    for (int y=0; y<height/cellSize; y++) {
      
      initialitation_state = brightness(img.pixels[x*cellSize+y*cellSize*width]);
      
      if (initialitation_state == 0) { 
        state = 1;
      }
      else if (initialitation_state == 109){
        state = 2;
      }else{
      state = 3;
    }
      cells[x][y] = int(state); // Save state of each cell
    }
  }
  background(255); // Fill in black in case cells don't cover all the windows
}


void draw() {

  //Draw grid
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {

      
      if (cells[x][y]==1) {
        fill(alive); // If alive
      }
      else if(cells[x][y]==0) {
        fill(dead); // If dead
      }else if(cells[x][y]==2){
        fill(water);
      }else{
      fill(virgin);
    }
      noStroke();
      rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
  
  
  
  // Iterate if timer ticks
  if (millis()-lastRecordedTime>interval) {
    if (!pause) {
      iteration();
      lastRecordedTime = millis();
    }
  }



// Create  new cells manually on pause

  if (pause && mousePressed) {
    
    // Map and avoid out of bound errors
    int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
    xCellOver = constrain(xCellOver, 0, width/cellSize-1);
    int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
    yCellOver = constrain(yCellOver, 0, height/cellSize-1);

    // Check against cells in buffer
    if (cellsBuffer[xCellOver][yCellOver]==1) { // Cell is alive
      cells[xCellOver][yCellOver]=0; // Kill
      fill(dead); // Fill with kill color
    }
    else { // Cell is dead
      cells[xCellOver][yCellOver]=1; // Make alive
      fill(alive); // Fill alive color
    }
  } 
  else if (pause && !mousePressed) { // And then save to buffer once mouse goes up
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cellsBuffer[x][y] = cells[x][y];
      }
    }
  }

  if(millis()>2000){
    gifExport.addFrame();
  }
  

}



void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      cellsBuffer[x][y] = cells[x][y];
    }
  }

// Visit each cell:
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      // And visit all the neighbours of each cell
      int neighbours = 0; // We'll count the neighbours
      int water = 0;
      
      for (int xx=x-1; xx<=x+1;xx++) {
        for (int yy=y-1; yy<=y+1;yy++) {  
          
          if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) { // Make sure you are not out of bounds
            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
              if (cellsBuffer[xx][yy]==1){
                neighbours ++; // Check alive neighbours and count them
              }else if(cellsBuffer[xx][yy]==2){
                water ++;
              }
            } 
          } 
        } 
      } 
      
// We've checked the neigbours: apply rules!
      if (cellsBuffer[x][y]==1) { // The cell is alive: kill it if necessary
        if (neighbours < 2 || neighbours > 3 ) {
          cells[x][y] = 0; // Die unless it has 2 or 3 neighbours
        } else if (water != 0){
          cells[x][y] = 0;
        }
      } 
      else { // The cell is dead: make it live if necessary      
        if (neighbours == 3 ) {
          cells[x][y] = 1; // Only if it has 3 neighbours
        }
      } 
    }
  } 
} 

// if 'R' is pressed, randomize view
void keyPressed() {
  if (key=='r' || key == 'R') {
    // Restart: reinitialization of cells
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        float state = random (100);
        if (state > probabilityOfAliveAtStart) {
          state = 0;
        }
        else {
          state = 1;
        }
        cells[x][y] = int(state); // Save state of each cell
      }
    }
  }
  
//if 'space' is pressed, pause sim  
  if (key==' ') { // On/off of pause
    pause = !pause;
    //saveFrame("saved/-######.png");
    
    gifExport.setDelay(30);
    gifExport.addFrame();
    gifExport.finish();

  }
  
//if 'C' is pressed, clear view
  if (key=='c' || key == 'C') { // Clear all
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cells[x][y] = 0; // Save all to zero
      }
    }
  }
}
