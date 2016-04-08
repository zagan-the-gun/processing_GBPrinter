import processing.serial.*;

PImage img;
PImage imgFile;
PImage imgRotation;
PImage imgSize;
PImage imgScissors;
PImage imgGbprinter;
Serial serial;

//byte pixelByte = 0;
int[] row1 = new int[640];
int inByte = 0;
int loop = 0;
int imgWidth = 159;
int windowSizeY = 165;
int imageX = 0;
int imageY = 0 ;
int imageWidth;
int imageHeight;
int rotateRadians = 0;

void setup() {
  size(194, 165);
  img = loadImage("2Bc2.bmp");
  imageWidth = img.width;
  imageHeight = img.height;
  //serial = new Serial( this, Serial.list()[0], 9600 );
  serial = new Serial( this, Serial.list()[0], 115200 );
  background(255);

  //frameRate(1);
  image(img, 0, 0);
  img.filter(GRAY);
}

void draw(){
  background(255);

  imgFile = loadImage("file.png");
  imgRotation = loadImage("rotation.png");
  imgSize = loadImage("size.png");
  imgScissors = loadImage("scissors.png");
  imgGbprinter = loadImage("gbprinter.png");

  imageMode(CENTER);
  translate(imageX+imageWidth/2, imageY+imageHeight/2);
  rotate(radians(rotateRadians));
  image(img, imageX, imageY, imageWidth, imageHeight);
  //image(img, imageX, imageY);
  img.filter(GRAY);
  rotate(radians(-rotateRadians));
  translate(-(imageX+imageWidth/2), -(imageY+imageHeight/2));
  imageMode(CORNER);

  image(imgFile, 161, 0);
  image(imgRotation, 161, 33);
  image(imgSize, 161, 66);
  image(imgScissors, 161, 99);
  image(imgGbprinter, 161, 132);

  loadPixels();
  stroke(#ff0000);
  point(0, 0);
  point((width - 1), 0);
  point(0, (height - 1));
  point((width - 1), (height - 1));
  stroke(#000000);
}

void mousePressed(){
  if(mouseX < width && mouseX > 161){
    // file
    if(mouseY < 32){
      selectInput("Select a file to process:", "viewImage");
    // rotation
    } else if(mouseY > 33 && mouseY < 64) {
      if(rotateRadians <= 360){
        rotateRadians = rotateRadians + 90;
      } else {
        rotateRadians = 0;
      }
    // size down
    } else if(mouseY > 66 && mouseY < 81) {
      if(windowSizeY > 165){
        windowSizeY = windowSizeY - 8;
        surface.setSize(194, windowSizeY);
      }
    // size up
    } else if(mouseY > 84 && mouseY < 97) {
      if(windowSizeY < 640){
        windowSizeY = windowSizeY + 8;
        surface.setSize(194, windowSizeY);
      } else {
        surface.setSize(194, 640);
      }
    // scissors
    } else if(mouseY > 99 && mouseY < 130) {
      
    // gbprinter
    } else if(mouseY > 132 && mouseY < 165) {
      serial.write('h'); 
      gbPrint();
    }
  }
}

void viewImage(File selection){
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String path = selection.getAbsolutePath();
    img = loadImage("" + path);
    imageWidth = img.width;
    imageHeight = img.height;

  }
}

void mouseWheel(MouseEvent event){
  float f = event.getAmount();
  if(f < 0){
    imageWidth++;
    imageHeight++;
    
  } else {
    imageWidth--;
    imageHeight--;
  }
  //img.resize(imageWidth, 0);
}

void mouseDragged(){
  imageX = mouseX;
  imageY = mouseY;
}

void gbPrint(){
  int xPos = 0;
  int yPos = 0;
  int i = 0;
  int j = 0;
  int j2 = 1;
  int rowCount = 0;
  //int lineCount = 1;

  for(loop = 0; loop <= 1; loop++){
  println("before loop: " + loop);
  loop = check();
  println("after loop: " + loop);
  delay(1);
  }

  //println("const char row0[640] PROGMEM = {");

  for(yPos = 0; yPos < height; yPos = yPos + 8){
    //for(xPos = 0; xPos < width; xPos = xPos + 8){
    for(xPos = 0; xPos < imgWidth; xPos = xPos + 8){

      for(int y = yPos; y < (yPos + 8); y++){
        i = 0;
        j = j + 2;
        j2 = j2 + 2;
        //for(int x = (7 + xPos); x <= width && x >= xPos; x--){
        for(int x = (7 + xPos); x <= imgWidth && x >= xPos; x--){
          //if((y*width + x) < (width * height)){
          if((y*imgWidth + x) < (imgWidth * height)){
            color c = pixels[y*width + x];
            //print(int(brightness(c)) + " ");
            //print((c) + " ");
            if(brightness(c) == 0){ // black
              row1[rowCount]       |= (1 << i);
              row1[(rowCount + 1)] |= (1 << i);
            }else if(brightness(c) > 0 && brightness(c) < 85){
              row1[rowCount]       &= ~(1 << i);
              row1[(rowCount + 1)] |= (1 << i);
            }else if(brightness(c) >= 85 && brightness(c) < 250){
              row1[rowCount]       |= (1 << i);
              row1[(rowCount + 1)] &= ~(1 << i);
            }else{ // white
              row1[rowCount]       &= ~(1 << i);
              row1[(rowCount + 1)] &= ~(1 << i);
            }
          }
          i++;
        }
        serial.write(row1[rowCount]); 
        serial.write(row1[(rowCount + 1)]); 
        //print("0x" + hex(row1[rowCount], 2) + ", ");
        //print("0x" + hex(row1[(rowCount + 1)], 2) + ", ");
        rowCount++;
        rowCount++;
        if(rowCount >= 640){
          //println();
          //println("};");
          for(loop = 0; loop <= 1; loop++){
            //println("before loop: " + loop);
            loop = check();
            //println("after loop: " + loop);
            delay(1);
          }
          //println("const char row" + lineCount + "[640] PROGMEM = {");
          //lineCount++;
          rowCount = 0;
        }
        //println(rowCount);
      }
    }
  }
  //println("};");
}

int check(){
  inByte = serial.read();
  if(inByte == 'k'){
    //print("k");
    return 1;
  } else if(inByte != 'k') {
    //print("1x" + hex(inByte, 2) + ", ");
  }
  return 0;
}