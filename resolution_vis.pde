PImage img;                         // the main image object used for displaying the original image
int matrixsize = 3;                 // the width in pixels of the area being processed via the convolution matrix
int start_matrixsize = matrixsize;  // default initial matrix size
int res_level = 1;                  // new resolution level, user configurable at runtime
int current_res_level = 1;          // previously processed resolution level.
float matrix_multiplier = 0.0;      // multiplication factor used in spatial convolution processing
int num_pixels = 0;                 // number of pixels in the convolution matrix
boolean new_image = false;

void setup() {
  // set window size
  size(640, 480);

  // load in the image
  img = loadImage("Selection_001.png"); //yasunao-tone.jpg");

  // load in the pixels for the base image
  image(img, 0, 0);
  loadPixels();

  // remove outline of drawn objects
  noStroke();
}

void draw() 
{

  // do we need to recompute resolution? 
  // (user pressed '+' or '-' to change resolution level
  if (res_level != current_res_level  || new_image)
  {
    new_image = false;
    if (res_level <= 0)
    {
      background(0);
      res_level = 0;
      // load in the pixels for the base image
      image(img, 0, 0);
      loadPixels();
    } else
    {
      // clear previous image
      background(0);
      // compute size of new resolution convolution matrix
      matrixsize = start_matrixsize * res_level;

      // loop through the matrix, applying the matrix filter to the pixels
      for (int x = 1; x < img.width; x+= matrixsize) {
        for (int y = 1; y < img.height; y+= matrixsize ) {
          color c = convolution(x, y, matrixsize);

          // set draw colour to the result of the convolution processing
          fill(c);
          // draw the ellipses representing new pixels
          ellipse(x + (matrixsize/2), y + (matrixsize/2), matrixsize, matrixsize);
        }
      }
    }
    current_res_level = res_level;
  }

  // draw instructions to the screen
  drawUI();
}

// uses a spatial convolution matrix technique to apply a smoothing of pixels in a given area.
// averaging the pixel colour to produce the next image
color convolution(int x, int y, int matsize) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;

  // offset used to help find the pixels in the current matrixsize
  int offset = matsize / 2;

  // a smoothing convolution matrix applies an even multiplication factor for 
  // averaging for all pixels in the given area.
  // so just calculate that value now rather than use an actual matrix
  float num_pixels = matsize * matsize;
  matrix_multiplier = 1.0 / num_pixels;

  // Loop through convolution matrix
  for (int i = 0; i < matsize; i++) {
    for (int j= 0; j < matsize; j++) {
      // What pixel are we testing
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      // Make sure we have not walked off the edge of the pixel array
      loc = constrain(loc, 0, img.pixels.length-1);
      // Calculate the convolution
      // We sum all the neighboring pixels multiplied by the values in the convolution matrix.
      rtotal += (red(img.pixels[loc]) * matrix_multiplier);
      gtotal += (green(img.pixels[loc]) * matrix_multiplier);
      btotal += (blue(img.pixels[loc]) * matrix_multiplier);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  // Return the resulting color
  return color(rtotal, gtotal, btotal);
}

void keyPressed()
{
  // increment or decrement the new resolution level appropriately.

  if (key == '+')
  {
    res_level--;
  }
  else if (key == '-')
  {
    res_level++;
  }
  else if (key == 'l' || key == 'L')
  {
    selectInput("Select an image file to process:", "fileSelected");
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel."); 
  } else {
    println("User selected " + selection.getAbsolutePath());
    
    loadNewImage(selection.getAbsolutePath());

  }
}

// set up the new image and reset resolution
// called when user loads new image---
void loadNewImage(String path)
{
  // load in the image
  img = loadImage(path);
  // load in the pixels for the base image
  image(img, 0, 0);
  loadPixels();
  res_level = 0;
  current_res_level = res_level;
  new_image = true;
}

// show text instructions for use
void drawUI()
{
  fill(255, 255, 255);
  textSize(18);
  text("press '-' to decrease resolution", 10, height-60);
  text("press '+' to increase resolution", 10, height-40);
  text("press 'L' to load new image", 10, height-20);
}