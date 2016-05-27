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
int imgWidth = 160;
int printSizeY = 10;
int windowSizeY = 198;
int imageX = 1;
int imageY = 1;
int imageWidth;
int imageHeight;
int rotateRadians = 0;

int gaugePos1 = 178;
int gaugePos2 = 95;
int gaugePos3 = 20;

float brightness1;
float brightness2;
float brightness3;
float brightness4;


void setup() {
  img = loadImage("gradation-s.bmp");
  imageWidth = img.width;
  imageHeight = img.height;
  size(198, 198);
  // Win
  //serial = new Serial( this, Serial.list()[0], 9600 );
  //serial = new Serial( this, Serial.list()[0], 115200 );
  // OSX
  serial = new Serial( this, "/dev/ttyp0", 115200 );

  background(255);

  //frameRate(1);
  image(img, imageX, imageY);
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
  img.filter(GRAY);
  img.filter(POSTERIZE, 4);
  rotate(radians(-rotateRadians));
  translate(-(imageX+imageWidth/2), -(imageY+imageHeight/2));
  imageMode(CORNER);

  loadPixels();

  // print area
  stroke(#ff0000);
  line(0,0,163,0);
  line(0,printSizeY,163,printSizeY);
  line(0,0,0,printSizeY);
  line(163,0,163,printSizeY);
  // slider area
  noStroke();
  rect(0,(windowSizeY - 35),197,35);
  //image(imgSize, 165,(windowSizeY - 33));
  stroke(#000000);
  // button
  image(imgFile, 165, 0);
  image(imgRotation, 165, 33);
  image(imgSize, 165, 66);
  image(imgScissors, 165, 99);
  image(imgGbprinter, 165, 132);

  // line
  //strokeWeight(2);
  line(10, (windowSizeY - 18), (width - 10), (windowSizeY - 18));
  // slider
  fill(255);
  triangle(gaugePos1, (windowSizeY - 17), (gaugePos1 - 5), (windowSizeY - 5), (gaugePos1 + 5), (windowSizeY - 5));
  fill(85);
  triangle(gaugePos2, (windowSizeY - 17), (gaugePos2 - 5), (windowSizeY - 5), (gaugePos2 + 5), (windowSizeY - 5));
  fill(0);
  triangle(gaugePos3, (windowSizeY - 17), (gaugePos3 - 5), (windowSizeY - 5), (gaugePos3 + 5), (windowSizeY - 5));
  fill(#ffffff);
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
      if(printSizeY > 10){
        printSizeY = printSizeY - 8;
      }
      if(windowSizeY > 201){
        windowSizeY = windowSizeY - 8;
        surface.setSize(198, windowSizeY);
      }
    // size up
    } else if(mouseY > 84 && mouseY < 97) {
      if(printSizeY < 640){
        printSizeY = printSizeY + 8;
      }
      if(windowSizeY < 640 && (windowSizeY - 34) < (printSizeY )){
        windowSizeY = windowSizeY + 8;
        surface.setSize(198, windowSizeY);
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

    imageX = 1;
    imageY = 1;
    imageWidth = 0;
    imageHeight = 0;

    rotateRadians = 0;
    imageWidth = img.width;
    imageHeight = img.height;

  }
}

void mouseWheel(MouseEvent event){
  float f = event.getAmount();

  if(f < 0){
    //imageWidth++;
    //imageHeight++;
    imageWidth = imageWidth + int(imageWidth/(map(f, 0, 10, 100, 200)));
    imageHeight = imageHeight + int(imageHeight/(map(f, 0, 10, 100, 200)));
      } else {
        if(imageWidth > 160 && imageHeight > 160){
    //imageWidth--;
    //imageHeight--;
    imageWidth = imageWidth - int(imageWidth/(map(f, 0, 10, 100, 200)));
    imageHeight = imageHeight - int(imageHeight/(map(f, 0, 10, 100, 200)));
        }
  }
  //img.resize(imageWidth, 0);
}

void mouseDragged(){
  if(printSizeY > mouseY){
    imageX = imageX + (mouseX - pmouseX);
    imageY = imageY + (mouseY - pmouseY);
  } else if ((windowSizeY - 35) < mouseY) {
    if((gaugePos1 - 5) < mouseX && (gaugePos1 + 5) > mouseX){
      if(gaugePos1 < mouseX && (width - 9) > mouseX){
        gaugePos1 = mouseX;
      } else if(gaugePos1 > mouseX && 9 < mouseX){
        gaugePos1 = mouseX;
      }
      brightness1 = ((256/(width - 19.0))*(gaugePos1 - 10));
      println("((256/(width - 10.0)) " + (256/(width - 10.0)));
      println("gaugePos1 " + gaugePos1);
      println("brightness1 " + brightness1);
    } else if((gaugePos2 - 5) < mouseX && (gaugePos2 + 5) > mouseX){
      if(gaugePos2 < mouseX && (width - 9) > mouseX){
        gaugePos2 = mouseX;
      } else if(gaugePos2 > mouseX && 9 < mouseX){
        gaugePos2 = mouseX;
      }
      brightness2 = ((256/(width - 19.0))*(gaugePos2 - 10));
    } else if((gaugePos3 - 5) < mouseX && (gaugePos3 + 5) > mouseX){
      if(gaugePos3 < mouseX && (width - 9) > mouseX){
        gaugePos3 = mouseX;
      } else if(gaugePos3 > mouseX && 9 < mouseX){
        gaugePos3 = mouseX;
      }
      brightness3 = ((256/(width - 19.0))*(gaugePos3 - 10));
    }
  }
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

  for(yPos = 1; yPos < printSizeY; yPos = yPos + 8){
    //for(xPos = 0; xPos < width; xPos = xPos + 8){
    for(xPos = 1; xPos < imgWidth; xPos = xPos + 8){

      for(int y = yPos; y < (yPos + 8); y++){
        i = 0;
        j = j + 2;
        j2 = j2 + 2;
        //for(int x = (7 + xPos); x <= width && x >= xPos; x--){
        for(int x = (7 + xPos); x <= imgWidth && x >= xPos; x--){
          //if((y*width + x) < (width * height)){
          if((y*imgWidth + x) < (imgWidth * printSizeY)){
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