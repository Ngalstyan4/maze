import java.util.Stack;
//import java.util.Set;
//import java.util.HashSet;
class Block{
  private int x;
  private int y;
  private Block prev;
  
  public Block(int x, int y, Block prev) {
    this.x = x;
    this.y = y;
    this.prev = prev;
  }
} 
  

Iterable<Block> solve(int[][] maze, int startX, int startY, int endX, int endY) {
  boolean [][]visited = new boolean[maze.length][maze.length];
  Block current = new Block(startX, startY,null);
  Stack<Block> s = new Stack();
  s.push(current);
  while(! (s.isEmpty() || isGoal(current, endX, endY))) {
    current = s.pop();
    visited[current.y][current.x] = true;
    for (Block i: neighbours(maze,visited, current))
      s.push(i);
    
  }
  
  if (isGoal(current, endX, endY)) {
      Stack<Block> result = new Stack();
    do{
        result.push(current);
        current = current.prev;
    } while (current != null);
    
    return result;
  } else 
  return null;
 }

Iterable<Block> neighbours(int [][] maze, boolean [][] visited, Block b) {
  // note visited is necessary now because a random path is selected without considering its length
  // in later more advanced implementations this should not be necessary;
  int px = -1, py = -1;
  if (b.prev != null) {
    px = b.prev.x;
    py = b.prev.y;
  }
  int walls = maze[b.y][b.x];
  Stack<Block> n = new Stack();
  if ((walls & N) == 0  && b.y-1 >= 0 && (b.y-1 != py && !visited[b.y-1][b.x])) n.push(new Block(b.x, b.y-1, b));
  if ((walls & S) == 0  && b.y+1 < maze.length && (b.y+1 != py && ! visited[b.y+1][b.x])) n.push(new Block(b.x, b.y+1, b));
  if ((walls & E) == 0  && b.x+1 < maze.length && (b.x+1 != px && ! visited[b.y][b.x+1])) n.push(new Block(b.x+1, b.y, b));
  if ((walls & W) == 0  && b.x-1 > 0 && (b.x-1 != px && ! visited[b.y][b.x-1])) n.push(new Block(b.x-1, b.y, b));
  
  return n;
}

boolean isGoal(Block b, int x, int y) {
  return b.x == x && b.y == y;
}

void drawPath (Iterable<Block> s) {
      if (s == null){
        text("NO such path", PADDING * 2 + BLOCK_CNT * BLOCK + 1* PADDING, 40 + 5*PADDING);
        return;
      }
      noFill();
      stroke(255,0,0);
      strokeWeight(4);
      beginShape();
      for (Block b: s)
        vertex(PADDING + b.x * BLOCK+ BLOCK/2, PADDING + b.y * BLOCK + BLOCK/2);
      endShape();
      strokeWeight(1);
      stroke(0);
      
}
