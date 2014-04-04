import std.stdio;

import subImage;

uint previousImageSize(uint imageWidth, uint imageHeight, uint pixelsize, uint currentImage){
  uint cumulative_size = 0;
  foreach( subimage; 1..currentImage ){
    cumulative_size += subImageHeight( imageHeight, subimage);
    cumulative_size += subImageHeight( imageHeight, subimage)*pixelsize*subImageWidth( imageWidth, subimage);
  }
  return cumulative_size;
}