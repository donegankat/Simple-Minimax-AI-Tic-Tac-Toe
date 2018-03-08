/// *********
/// Variables
/// *********

// We'll treat the window width & height as a bit smaller than we actually make it so that we have a border around the game board 
int windowWidth = 840;
int windowHeight = 840;
int windowPadding = 40;

int squarePadding = 20; // The space between the square edges and the shapes we're going to draw in them

int currentPlayer = 1; // 1 is X, 2 is O
int humanPlayer = 1; // The human player will always be player 1
int computerPlayer = 2; // The AI player will always be player 2

int shapeWidth = windowWidth/3 - windowPadding - squarePadding;
int shapeHeight = windowHeight/3 - windowPadding - squarePadding;

int[] boardSquares;

class Move
{
  int boardIndex;
  int score;
  
  Move(int i, int sc)
  {
    boardIndex = i;
    score = sc;
  }
}


/// *********
/// Setup
/// *********

void setup()
{
  size(880,920);
  noStroke();
  background(0);
  
  PFont f = createFont("Arial", 24);
  textFont(f);
  
  setupBoard();
}

void draw() // This doesn't need to do anything but it can be called if we need to refresh the screen
{
  
}

void setupBoard()
{
  boardSquares = new int[9];
  
  for (int i = 0; i < 9; i++)
  {
    boardSquares[i] = 0; // Start with a fresh, empty board. 0 indicates that a space is free.
  }
  
  stroke(255, 255, 255);
  strokeWeight(5);  // Thicker
  
  // I don't know why but both the horizontal and vertical lines need to have windowPadding/2 added whenever we do anything with windowWidth/3 or windowHeight/3
  // If we don't add the windowPadding/2, then the squares come out unevenly sized.
  
  // Horizontal lines
  line(windowPadding, windowHeight/3 + windowPadding/2, windowWidth, windowHeight/3 + windowPadding/2);
  line(windowPadding, windowHeight - windowHeight/3 + windowPadding/2, windowWidth, windowHeight - windowHeight/3 + windowPadding/2);
  
  // Vertical Lines
  line(windowWidth/3 + windowPadding/2, windowPadding, windowWidth/3 + windowPadding/2, windowHeight);
  line(windowWidth - windowWidth/3 + windowPadding/2, windowPadding, windowWidth - windowWidth/3 + windowPadding/2, windowHeight);
}



/// *********
/// Events
/// *********

void mouseClicked()
{
  boolean validClick = true;
  
  int squareIndex = 0;
  
  // NOTE: The row/column stuff is sorta backwards. I 
  int row = 0;
  int column = 0;
  
  // Make sure the click was in a valid area. If the user clicked outside of the game board, don't do anything.
  // If the click was valid, calculate which square was clicked.
  if (mouseX >= windowPadding && mouseX <= windowWidth/3) // Click was in the left column
  {
    column = 0;
  }
  else if (mouseX > windowWidth/3 && mouseX <= windowWidth - windowWidth/3) // Click was in the middle column
  {
    column = 1;
  }
  else if (mouseX > windowWidth - windowWidth/3 && mouseX < windowWidth - windowPadding) // Click was in the right column
  {
    column = 2;
  }
  else // The click was off the board somewhere
  {
    validClick = false;
  }
  
  
  if (mouseY >= windowPadding && mouseY <= windowHeight/3) // Click was in the top row
  {
    row = 0;
  }
  else if (mouseY > windowHeight/3 && mouseY <= windowHeight - windowHeight/3) // Click was in the middle row
  {
    row = 1;
  }
  else if (mouseY > windowHeight - windowHeight/3 && mouseY < windowHeight - windowPadding) // Click was in the bottom row
  {
    row = 2;
  }
  else // The click was off the board somewhere
  {
    validClick = false;
  }

  
  if (validClick) // The click was in a valid area
  {
    int startX = getShapeX(column); // Get the X position to draw the shape at
    int startY = getShapeY(row); // Get the Y position to draw the shape at
    
    int currentSquareIndex = getSquareIndex(row, column); // Figure out which square was clicked on
    int currentSquareStatus = getSquareStatus(currentSquareIndex); // Check to see if the square that was clicked was already occupied
    
    if (currentSquareStatus == 0) // If the square is empty then we can fill it in.
    {
      setSquareStatus(currentSquareIndex, currentPlayer); // Mark that this square is now filled by the current player
      
      boolean playerWon = checkPlayerWon(currentPlayer, boardSquares); // Check to see if the player won the game
      
      if (currentPlayer == humanPlayer)
      {
        drawX(startX, startY);
        currentPlayer = computerPlayer; // Switch from X to O next time
        
        takeComputerTurn(); // The human just took their turn, so make the computer take a turn
      }
      else
      {
        
      }
      
      if (playerWon)
      {
        println("PLAYER", currentPlayer, "WON");
        printMessage("PLAYER " + currentPlayer + " WON", true); // Print on the screen for the player to see
      }
      else
      {
        eraseMessage(); // Clear any previous text from below the board
      }
    }
  }
  else
  {
    printMessage("INVALID CLICK", false); // Print on the screen for the player to see
  }
}

int getShapeX(int column)
{
  int startX = 0;
  if (column == 0) // Click was in the left column
  {
    startX = windowPadding;
  }
  else if (column == 1) // Click was in the middle column
  {
    startX = windowWidth/3 + windowPadding/2;
  }
  else if (column == 2) // Click was in the right column
  {
    startX = windowWidth - windowWidth/3 + windowPadding/2;
  }
  
  startX += squarePadding; // Pad each square a little bit
  
  return startX;
}

int getShapeY(int row)
{
  int startY = 0;
  
  if (row == 0) // Click was in the top row
  {
    startY = windowPadding;
  }
  else if (row == 1) // Click was in the middle row
  {
    startY = windowHeight/3 + windowPadding/2;
  }
  else if (row == 2) // Click was in the bottom row
  {
    startY = windowHeight - windowHeight/3 + windowPadding/2;
  }

  startY += squarePadding; // Pad each square a little bit 
  
  return startY;
}


/// *********
/// Helpers
/// *********

// Returns the index that a particular square is stored in boardSquares[]
int getSquareIndex(int row, int column)
{
  //println((row * 3) + column);
  return (row * 3) + column;
}

// Returns the vertical column that a given index is in on the game board
int getIndexColumn(int index)
{
  return index % 3;
}

// Returns the horizontal row that a given index is in on the game board
int getIndexRow(int index)
{
  return index / 3;
}

// Returns the current status of the given board index. Not actually strictly necessary because this functionality is easy enough to just do
int getSquareStatus(int index)
{
  return boardSquares[index];
}

// Sets the status of a board index
void setSquareStatus(int index, int status)
{
  boardSquares[index] = status;
}


// Checks to see if a player has won the game yet
boolean checkPlayerWon(int player, int[] boardState)
{
  boolean playerWon = false; 
  int horizontalCombo = 0;
  
  // Possible winning game states
  // Horizontal:
  // 0, 1, 2
  // 3, 4, 5
  // 6, 7, 8

  // Vertical:
  // 0, 3, 6
  // 1, 4, 7
  // 2, 5, 8

  // Diagonal:
  // 0, 4, 8
  // 2, 4, 6
  
  for (int i = 0; i < 9; i++)
  {
    // Vertical check
    if (i < 3) // Only need to check if i is 0, 1, or 2 because we'll look at the other squares in the if statement
    {
      if (boardSquares[i] == player && boardSquares[i + 3] == player && boardSquares[i + 6] == player)
      {
        playerWon = true;
        break;
      }
    }
    
    // Horizontal check
    if (i % 3 == 0) // We're on a new row so reset the horizontal combo to 0
    {
      horizontalCombo = 0;
    }
    
    if (boardSquares[i] == player)
    {
      horizontalCombo ++;
    }
    
    if (horizontalCombo >= 3)
    {
      playerWon = true;
      break;
    }
  }
  
  // Diagonal check
  if ((boardSquares[0] == player && boardSquares[4] == player && boardSquares[8] == player)
  || (boardSquares[2] == player && boardSquares[4] == player && boardSquares[6] == player))
  {
    playerWon = true;
  }
  
  return playerWon;
}

void takeComputerTurn()
{
  IntList freeSpaces = getFreeSpaces(boardSquares);
  
  Move bestMove = new Move(0, -1000);
  
  for (int i = 0; i < freeSpaces.size(); i++)
  {
    println("FREE:", freeSpaces.get(i));
    int score = minimax(computerPlayer, 0, boardSquares);
    if (score > bestMove.score)
    {
      bestMove.boardIndex = freeSpaces.get(i);
      bestMove.score = score;
    }
  }
  
  println("BEST MOVE:", bestMove.boardIndex, "SCORE:", bestMove.score);
  
  int startX = getShapeX(getIndexColumn(bestMove.boardIndex));
  int startY = getShapeY(getIndexRow(bestMove.boardIndex));
  
  drawO(startX, startY);
  currentPlayer = humanPlayer; // switch from O to X next time
}

IntList getFreeSpaces(int[] board)
{
  IntList freeSpaces = new IntList();
  for (int i = 0; i < 9; i++)
  {
    if (board[i] == 0)
    {
      freeSpaces.append(i);
    }
  }
  return freeSpaces;
}

int minimax(int player, int depth, int[] board)
{
  IntList freeSpaces = getFreeSpaces(board);
  
  if (checkPlayerWon(player, board)) // Check if the the current game state is a win 
  {
    if (player == computerPlayer) // If it was a win for the computer, then awesome!
    {
      //println("AI win: +10");
      return 10;
    }
    else // If it was a win for the player, boo.
    {
      //println("Player win: -10");
      return -10;
    }
  }
  else if (freeSpaces.size() == 0) // If nobody has won yet and there are no more free spaces left to play
  {
    return 0; // Tie
  }
  

  int bestComputer = -1000;
  int bestHuman = 1000;
  
  for (int i = 0; i < freeSpaces.size(); i++)
  {
    //int[] boardCopy = board; // Copy the board so we can refer back to the original
    
    board[freeSpaces.get(i)] = player; // Try going here and see if it results in a win/loss
    
    if (player == computerPlayer) // Maximize the computer player's score
    {
      int score = minimax(humanPlayer, depth + 1, board);
      
      if (score > bestComputer)
      {
        bestComputer = score;
      }
      //moveScores.add(new MoveScore(i, ));
    }
    else // Minimize the human player's score
    {
      int score = minimax(computerPlayer, depth + 1, board);
      
      if (score < bestHuman)
      {
        bestHuman = score;
      }
      //moveScores.add(new MoveScore(i, ));
    }
    
    board[freeSpaces.get(i)] = 0; // Undo the move
  }
  
  if (player == computerPlayer) // Maximize the computer player's score
  {
    return bestComputer;
  }
  else
  {
    return bestHuman;
  }
}


// Draw an X in the given square
void drawX(int startX, int startY)
{
  stroke(0, 100, 255); // Set the stroke to blue for X's
  
  line(startX, startY, startX + shapeWidth, startY + shapeHeight);
  line(startX, startY + shapeHeight, startX + shapeWidth, startY);
}

// Draw an O in the given square
void drawO(int startX, int startY)
{
  stroke(0, 255, 50); // Set the stroke to green for O's
  
  ellipseMode(CORNER);
  fill(0);
  ellipse(startX, startY, shapeWidth, shapeHeight);
}


// Prints a message on the screen below the board.
// TODO: If I ever feel like making this a better game, the redFill parameter should be changed to a fancier way of defining the text color.
// TODO: I should also add an x and y parameter to let the text position be customizable.
void printMessage(String message, boolean redFill) // The redFill boolean is just a lazy, shitty way for me to indicate if the text should be red. Otherwise have the text be white.
{
  if (redFill) // Red is used when a player has won the game
  {
    fill(255, 0, 0);
  }
  else // All other notifications are white.
  {
    fill(255, 255, 255); 
  }
  
  text(message, windowPadding, 900); // Print on the screen for the player to see
}

// This is just a super hacky, shitty way to erase any text we've previously printed below the board. I'm being lazy so I'm just going to cover it up rather than redraw the canvas or anything.
// TODO: If I ever actually do anything with this game, make this better.
// TODO: I should also add an x and y parameter to let the text position be customizable.
void eraseMessage()
{
  fill(0);
  noStroke();
  rect(0, 900 - 24, windowWidth, windowPadding);
}

// Writes the current state of the board to the console window for debugging purposes.
void printBoard(int[] board)
{
  for (int i = 0; i < board.length; i += 3)
  {
    println(board[i], " | ", board[i + 1], " | ", board[i + 2]);
  }
}