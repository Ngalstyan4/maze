/*maze simulator*/
/*Author: Narek Galstyan*/

// set to null to create a maze from scratch
final String LOADMAZE = "maze16x16onlineGenerated.txt";
final int START_X = 7,START_Y = 0;
final int END_X = 8, END_Y = 15; 
// go change size accordingly if these are chagned!
final float PADDING = 5;
final float BLOCK = 50;
final int BLOCK_CNT = 16;
final float DIM = BLOCK_CNT * BLOCK + 2* PADDING;
final float CONTROLS = 100;

final byte N = 0b0001; 
final byte S = 0b0010;
final byte E = 0b0100;
final byte W = 0b1000;

/*controls*/
boolean modify = false;
// example 4x4 maze
//int[][] maze = {{N|W,E,N|W,N|E|S},
//                      {W|E,W,S,N|E}, 
//                      {E|W, W|S, N|E, E|W},
//                      {W|S, N|E|S, E|W, E|W|S}}; 
int[][] maze = null;
Iterable<Block> solution = null;
/*HELPERS begin*/
void prect(float x, float y, float w, float h, byte sides) {
  if ((sides & N) != 0) line(x,y, x+w, y);
  if ((sides & S) != 0) line(x,y+h, x+w, y+h);
  if ((sides & E) != 0) line(x+w,y, x+w, y+h);
  if ((sides & W) != 0) line(x,y, x, y+h);

}
/* this is to make sure sides argument can be sth like N|S|E without errors*/
void prect(float x, float y, float w, float h, int sides) {
  prect(x,y,w,h,(byte)sides);
}

boolean pointInRect(float px,float py, float x,float y,float w,float h) {
  return x < px && px < x+w && y < py && py < y+h;
}

boolean mouseIn(byte dir) {
  int row = (int)((mouseY - PADDING)/BLOCK);
  int col = (int)((mouseX - PADDING)/BLOCK);
  switch(dir){
  case N:
  return pointInRect(mouseX, mouseY,PADDING + col * BLOCK,PADDING + row* BLOCK,
      BLOCK,BLOCK/4);
  case S: 
  return pointInRect(mouseX, mouseY,PADDING + col * BLOCK,PADDING + row* BLOCK + BLOCK*0.75,
      BLOCK,BLOCK/4);
  case E: 
  return pointInRect(mouseX, mouseY,PADDING + col * BLOCK + BLOCK*0.75,PADDING + row* BLOCK,
      BLOCK/4,BLOCK);
  case W:
  return pointInRect(mouseX, mouseY,PADDING + col * BLOCK,PADDING + row* BLOCK,
      BLOCK/4,BLOCK);
  default:
  print ("ERROR, unknown direction:" + dir);
  return false;
  }
  
} 

void drawMaze() {
  background(255);
  for (int row = 0; row < BLOCK_CNT; row++) {
    for(int col = 0; col < BLOCK_CNT; col++) {
      prect(PADDING + col * BLOCK,PADDING + row* BLOCK,
      BLOCK,BLOCK, 
      maze[row][col]);   
    }
  }
}

void saveMaze() {
  String[] sMaze = new String[maze.length];
  for (int i = 0; i < maze.length; i++) {
    sMaze[i] = "";
    for (int j = 0; j < maze.length; j++) {
      sMaze[i] += maze[i][j];
      if (j != maze.length - 1)
        sMaze[i] += " ";
    }
    String filename = String.format("data/maze%dx%d_%d.%d.%d %d.%d.%d.txt",BLOCK_CNT, BLOCK_CNT,
    day(), month(), year(), hour(), minute(), second());
    saveStrings(filename, sMaze);
  }
      
 }
 
 int [][] loadMaze(String filename) {
   String[] sMaze = loadStrings(filename);
   int [][] maze = new int[BLOCK_CNT][BLOCK_CNT];
   
   for (int i = 0; i < maze.length;i++) {
     String[] irow = split(sMaze[i], " ");
     if (irow.length != BLOCK_CNT) {
       
       println ("ERROR< window SIZE and LOADED maze SIZE do not MATCH\n irow length, BLOCK_CNT:",irow.length, BLOCK_CNT);
       exit();
     }
     for (int j = 0; j < maze.length; j++) {
       maze[i][j] = int(irow[j]);
     }
   }
   return maze;
 }

boolean isValid(int [][] maze) {
  for (int row = 1; row < maze.length-1; row++) {
    for (int col = 1; col < maze.length-1; col++) {
      // shifts rely on internal representaion of N,S,E,W
      if ((maze[row][col] & N) >> 0 !=  (maze[row-1][col] & S) >> 1) return false;
      if ((maze[row][col] & S) >>1  !=  (maze[row+1][col] & N) >> 0) return false;
      //println (row,col,maze[row][col] & S,maze[row+1][col] & N);
      if ((maze[row][col] & E) >>2 !=  (maze[row][col+1] & W) >> 3) return false;
      if ((maze[row][col] & W) >>3 !=  (maze[row][col-1] & E)>>2) return false;
    }  
  }
  return true;
  
    
}

void mazeClicked() {
  int row = (int)((mouseY - PADDING)/BLOCK);
  int col = (int)((mouseX - PADDING)/BLOCK);
  
  //north
  if (mouseIn(N)){
      maze[row][col] ^= N;
      if (row-1 >= 0)
        maze[row-1][col] ^= S;
    }
    
  //south
  if (mouseIn(S)){
      maze[row][col] ^= S;
      if (row+1 < maze.length)
        maze[row+1][col] ^= N;
    }
    
    // east
    if (mouseIn(E)){
    maze[row][col] ^= E;
    if (col+1 < maze.length)
      maze[row][col+1] ^= W;
    }
    // west
    if (mouseIn(W)){
    maze[row][col] ^= W;
    if (col-1 >= 0)
      maze[row][col-1] ^= E;
    }
      
    if (! isValid(maze))println("INVALID MAZE after click !!");
    solution = solve(maze, START_X, START_Y, END_X, END_Y);
}

void drawControls() {
  if (modify) fill(0,255,0);
  else fill(255,0,0);
  rect(BLOCK * BLOCK_CNT + PADDING * 2, PADDING, 90, 20);
  fill(0);
  text("Modify", BLOCK * BLOCK_CNT + PADDING + 3*PADDING * 2, PADDING+3*PADDING);
  
  fill(255);
  rect(BLOCK * BLOCK_CNT + PADDING * 2, PADDING*2 + 20, 90, 20);
  fill(0);
  text("Save", BLOCK * BLOCK_CNT + PADDING + 3*PADDING * 2, PADDING*2 + 20 +3*PADDING);
  
}

void controlsClicked() {
  // modify click
  if (pointInRect(mouseX, mouseY, BLOCK * BLOCK_CNT + PADDING * 2, PADDING, 90, 20))
    modify = !modify; 
    
  if (pointInRect(mouseX, mouseY, BLOCK * BLOCK_CNT + PADDING * 2, PADDING*2 + 20, 90, 20))
    saveMaze();
}

/*HELPERS end*/
void setup() {
  if (LOADMAZE == null) {
     maze = new int[BLOCK_CNT][BLOCK_CNT];
      for (int i = 0; i < maze.length; i++) 
        for (int j =0; j < maze.length; j++)
          maze[i][j] = N|S|E|W;
  } else maze = loadMaze(LOADMAZE);
  size(910,810);// BLOCK * BLOCK_CNT + PADDING * 2 + CONTROLS, BLOCK * BLOCK_CNT + PADDING * 2
  if (! isValid(maze))println("INVALID MAZE in setup !!");

  drawMaze();
  drawControls();
  
  //solve maze
  solution = solve(maze, START_X, START_Y, END_X, END_Y);
}

void draw() {
  clear();
  drawMaze();
  drawControls();
  drawPath(solution);
  if (!modify) return;
  if (PADDING < mouseX && mouseX < PADDING + BLOCK_CNT * BLOCK &&
      PADDING < mouseY && mouseY < PADDING + BLOCK_CNT * BLOCK) {
      int row = (int)((mouseY - PADDING)/BLOCK);
      int col = (int)((mouseX - PADDING)/BLOCK);
      
      if (mouseIn(N)){
          fill(100,100,100);
          rect(PADDING + col * BLOCK,PADDING + row* BLOCK,
          BLOCK,BLOCK/4);
        }
      if (mouseIn(S)){
          fill(100,100,100);
          rect(PADDING + col * BLOCK,PADDING + row* BLOCK+ BLOCK*0.75,
          BLOCK,BLOCK/4);
      }
      if (mouseIn(E)){
          fill(100,100,100);
          rect(PADDING + col * BLOCK+ BLOCK*0.75,PADDING + row* BLOCK,
          BLOCK/4,BLOCK);
      }
      if (mouseIn(W)){
          fill(100,100,100);
          rect(PADDING + col * BLOCK ,PADDING + row* BLOCK,
          BLOCK/4,BLOCK);
      }
        
  }  
}

void mouseClicked()
{
  if (width - mouseX < CONTROLS - PADDING) {
    controlsClicked();
  }
   //only proceed if clicks will change sth in the rest
  if (! modify) return;
  if (PADDING < mouseX && mouseX < PADDING + BLOCK_CNT * BLOCK &&
      PADDING < mouseY && mouseY < PADDING + BLOCK_CNT * BLOCK)
      mazeClicked();
}
