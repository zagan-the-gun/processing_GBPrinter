import processing.serial.*;

PImage img;
PImage imgRotation;
PImage imgFile;
Serial serial;

byte pixelByte = 0;
int[] row1 = new int[640];
int inByte = 0;
int loop = 0;
int imgWidth = 159;

void setup() {
  //size(159, 376); //logs.bmp
  //size(159, 226); //160.bmp
  size(194, 198); //2Bc.bmp
  //size(159, 159); //gradation.bmp
  //size(159, 159); //gradation.bmp
  //size(159, 216); //5Bh.jpg
  //size(159, 159); //text.bmp

  //serial = new Serial( this, Serial.list()[0], 9600 );
  serial = new Serial( this, Serial.list()[0], 115200 );
  background(255);
  //serial.write('h'); 
  //frameRate(1);
}

void draw(){
  imgRotation = loadImage("rotation.png");
  imgFile = loadImage("file.png");

  //img = loadImage("logos.bmp");
  //img = loadImage("box.bmp");
  //img = loadImage("160.bmp");
  img = loadImage("2Bc2.bmp");
  //img = loadImage("2Bc.bmp");
  //img = loadImage("gradation.bmp");
  //img = loadImage("gradation-s.bmp");
  //img = loadImage("5Bh.jpg");
  //img = loadImage("5Bh-s.jpg");
  //img = loadImage("text.png");
  
  img.filter(GRAY);

  image(imgFile, 161, 0);
  image(imgRotation, 161, 33);

  image(img, 0, 0);

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
    if(mouseY < 32){
      serial.write('h'); 
      gbPrint();
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