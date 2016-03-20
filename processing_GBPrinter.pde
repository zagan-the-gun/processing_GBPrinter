import processing.serial.*;

PImage img;
Serial serial;

byte pixelByte = 0;
int[] row1 = new int[640];
int inByte = 0;
int loop = 0;

void setup() {
  //size(159, 376); //logs.bmp
  //size(159, 226); //160.bmp
  //size(159, 198); //2Bc.bmp
  size(159, 159); //gradation.bmp

  //serial = new Serial( this, Serial.list()[0], 9600 );
  serial = new Serial( this, Serial.list()[0], 115200 );
  background(255);
  //serial.write('h'); 
  //frameRate(1);
}

void draw(){
  //img = loadImage("logos.bmp");
  //img = loadImage("box.bmp");
  //img = loadImage("160.bmp");
  //img = loadImage("2Bc2.bmp");
  img = loadImage("gradation.bmp");

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
  serial.write('h'); 

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
    for(xPos = 0; xPos < width; xPos = xPos + 8){

      for(int y = yPos; y < (yPos + 8); y++){
        i = 0;
        j = j + 2;
        j2 = j2 + 2;
        for(int x = (7 + xPos); x <= width && x >= xPos; x--){
          if((y*width + x) < (width * height)){
            color c = pixels[y*width + x];
            if(c == color(0)){
              row1[rowCount] |= (1 << i);
              row1[(rowCount + 1)] = 0x00;
            }else{
              row1[rowCount] &= ~(1 << i);
              row1[(rowCount + 1)] = 0x00;
            }
          }
          i++;
        }
        serial.write(row1[rowCount]); 
        serial.write(row1[rowCount]); 
        //print("0x" + hex(row1[rowCount], 2) + ", ");
        //print("0x" + hex(row1[rowCount], 2) + ", ");
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