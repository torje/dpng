import std.stdio;

returntype  decode(returntype = ubyte[4], string transform)(){
  returntype retval;

  import std.regex; 
  auto match =   ctRegex!`[1,2,4,8]`;
  
}
uint subImageWidth( uint imageWidth, uint subImageNo ) {
  uint add;
  uint divisor;
  switch( subImageNo ){
  case 1:
    add = 7;
    divisor = 8;
    break;
  case 2:
    add =3;
    divisor = 8;
    break;
  case 3:
    add = 3;
    divisor = 4;
    break;
  case 4:
    add = 1;
    divisor = 4;
    break;
  case 5:
    add = 1;
    divisor = 2;
    break;
  case 6:
    add = 0;
    divisor = 2;
    break;
  case 7:
    add = 0;
    divisor=1;
    break;
  default:
    add = add.max;
    divisor = divisor.max;
  }
  return (imageWidth+add)/divisor;
}
uint subImageHeight( uint imageHeight, uint subImageNo) {

  uint add;
  uint div;
  switch(subImageNo){
  case 1:
    add= 7;
    div=8;
    break;
  case 2:
    add = 7;
    div = 8;
    break;
  case 3:
    add = 3;
    div =8;
    break;
  case 4:
    add = 3;
    div =4;
    break;
  case 5:
    add = 1;
    div = 4;
    break;
  case 6:
    add = 1;
    div = 2;
    break;
  case 7:
    add = 0;
    div = 2;
    break;
  default:
    add= add.max;
    div = div.max;
  }
  return (imageHeight+add)/div;
}

ubyte[] subImage(ubyte[] udata, uint height, uint width, uint subimage, uint pixelSize){
  import std.stdio;
  uint step= 0;
  foreach(previous; 1..subimage){
    step+= subImageWidth( width , previous)*subImageHeight(height, previous)*pixelSize + subImageHeight(height, previous);
  }
  foreach ( scanlineIndex ; 0..subImageHeight(height, subimage) ) {
    writefln("%s: start: %s  - %s",
	     scanlineIndex, 
	     step + subImageWidth(width, subimage)*scanlineIndex*pixelSize+1+scanlineIndex, 
	     step + subImageWidth(width, subimage)*scanlineIndex*pixelSize+1+scanlineIndex+subImageWidth(width, subimage)*pixelSize);
  }
  return new ubyte[0];
}

auto interlaceCoords(uint imageWidth, uint imageHeight, uint pixelsize){
  
  return delegate uint (uint subimage, uint column,uint row){
    uint offset = 0;
    foreach( previous;1..subimage){
      offset += subImageWidth( imageWidth, previous)*subImageHeight( imageHeight, previous)*pixelsize + subImageHeight(imageHeight, previous);
    }
    uint linewidth = subImageWidth( imageWidth, subimage) * pixelsize + 1;
    return offset + linewidth*row + 1 +column*pixelsize;
  };
}
auto directCoord(uint imageWidth, uint imageHeight, uint pixelsize){
  return delegate uint  (uint subimage, uint column, uint row){
    uint row_add, row_mult,
      col_add, col_mult;
    switch ( subimage ) {
    case 1:
      row_add = 0, col_add = 0, row_mult=8, col_mult = 8;
      break;
    case 2:
      row_add = 0, col_add = 4, row_mult=8, col_mult = 8;
      break;
    case 3:
      row_add = 4, col_add = 0, row_mult=8, col_mult = 4;
      break;
    case 4:
      row_add = 0, col_add = 2, row_mult=4, col_mult = 4;
      break;
    case 5:
      row_add = 2, col_add = 0, row_mult=4, col_mult = 2;
      break;
    case 6:
      row_add = 0, col_add = 1, row_mult=2, col_mult = 2;
      break;
    case 7:
      row_add = 1, col_add = 0, row_mult=2, col_mult = 1;
      break;
    default:
      row_add = 0, col_add = 0, row_mult=0, col_mult = 0;
      break;
    }
    //writefln("%s %s %s %s %s",subimage, row_add, col_add, row_mult, col_mult);
    //writefln("%s %s %s ",subimage, row, column, row_mult, col_mult);
    //writefln("si:%s %s %s %s %s %s ",subimage, row,row_mult,row_add,pixelsize,imageWidth);
    //writefln("%s %s ",(column*col_mult+col_add)*pixelsize  , (row*row_mult+row_add)*pixelsize*imageWidth);
    return (column*col_mult+col_add) * pixelsize + (row*row_mult+row_add)*pixelsize*imageWidth;
    //return row*pixelsize*imageWidth+column*pixelsize;
  };
}

/+ubyte[] unfilter(uint filtertype:1, uint interlace :1)( ubyte[] data, uint width, height){  
  auto image = new ubyte[1];
  foreach(subimage; 1..8){
    foreach(row ; 0..subImageHeight( height,subimage)){
      foreach(col ; 0..subImageWidth( width,subimage)){
      }
    }
  }
  return image;
}
+/
ubyte[] unfilter(uint filtertype:0, uint interlace :1)( ubyte[] data, uint width, uint height, uint pixelsize){  
  auto image = new ubyte[width*height*4];
  auto i =interlaceCoords(width, height,pixelsize);
  auto d = directCoord(width, height,4);
  foreach(subimage; 1..8){
    foreach(row ; 0..subImageHeight( height,subimage)){
      auto filterMethod = data[i(subimage,0,row)-1];
      write( filterMethod, ""); 
      foreach(col ; 0..subImageWidth( width,subimage)){
    	uint icoords = i(subimage,col,row);
	uint dcoords = d(subimage,col,row);
	try {
	  if ( filterMethod == 2 && row >0){
	    int temp = (data[icoords + 2] + image[d(subimage,col, row-1)+0]);
	    image[dcoords+0] = cast(byte)((data[icoords + 2] + cast(int)image[d(subimage,col, row-1)+0])%256);
	    image[dcoords+1] = cast(byte)((data[icoords + 1] + cast(int)image[d(subimage,col, row-1)+1])%256);
	    image[dcoords+2] = cast(byte)((data[icoords + 0] + cast(int)image[d(subimage,col, row-1)+2])%256);
	  }else{

	    image[dcoords+0] = cast(ubyte)(data[icoords + 2]);
	    image[dcoords+1] = cast(ubyte)(data[icoords + 1]);
	    image[dcoords+2] = cast(ubyte)(data[icoords + 0]);
	  }
	}
	catch( core.exception.RangeError e) {
	  writeln("Exception");
	  throw e;
	  //writefln( "i%s col%s row%s", subimage, col, row );
	  //writefln( "%s imlen%s data.len%s", subimage, image.length, data.length );
	  //writefln( "%s im.coord%s interlace.coord%s", subimage, dcoords , icoords  );
	  //throw new Exception("oups");
	}
      }
    }
  }
  return image;
}


unittest{
  import std.stdio;
  writeln("unittest: subimage width");
  foreach ( width; 1..2){
    foreach( subimageNo; 1..5){
      writeln( "image width: ", width, ", subimage: ", subimageNo, ": ", subImageWidth(width, subimageNo));
    }
  }
  foreach( height; 1..3){
    foreach( subimageNo; 1..2){
      writeln( "image height: ", height, ", subimage: ", subimageNo, ": ", subImageWidth( height, subimageNo));
    }
  }
  writeln("subimage size testing: sum of size");
  foreach( imageWidth; 1..16){
    foreach( imageHeight; 1..16){
      uint area= 0;
      uint imageno = 1;
      auto area1 = subImageWidth(imageWidth, imageno)*subImageHeight(imageHeight, imageno);
      imageno = 2;
      auto area2 = subImageWidth(imageWidth, imageno)*subImageHeight(imageHeight, imageno);
      imageno = 3;
      auto area3 = subImageWidth(imageWidth, imageno)*subImageHeight(imageHeight, imageno);
      imageno = 4;
      auto area4 = subImageWidth(imageWidth, imageno)*subImageHeight(imageHeight, imageno);
      imageno = 5;
      auto area5 = subImageWidth(imageWidth, imageno)*subImageHeight(imageHeight, imageno);
      imageno = 6;
      auto area6 = subImageWidth(imageWidth, imageno)*subImageHeight(imageHeight, imageno);
      imageno = 7;
      auto area7 = subImageWidth(imageWidth, imageno)*subImageHeight(imageHeight, imageno);
      auto totalArea = area1+area2+area3+area4+area5+area6+area7;
      if ( totalArea !=imageWidth*imageHeight){
	writefln("a1:%s - a2:%s - a3:%s - a4:%s - a5:%s - a6:%s - a7:%s  :: total sum: %s - multiplication: %s", area1, area2, area3, area4, area5, area6, area7, totalArea, imageWidth*imageHeight); 
      }
    }
  }
  subImage( new ubyte[0], 8, 8, 1,4);
  subImage( new ubyte[0], 8, 8, 2,4);
  subImage( new ubyte[0], 8, 8, 3,4);
  subImage( new ubyte[0], 8, 8, 4,4);
  subImage( new ubyte[0], 8, 8, 5,4);
  subImage( new ubyte[0], 8, 8, 6,4);
  subImage( new ubyte[0], 8, 8, 7,4);
  //  subImageUnfilter(new ubyte[526], 16, 8, 4);
  
  auto  i = interlaceCoords(8, 8,4);
  auto  c = directCoord(8, 8,4);
  int[] icoords;
  int[] dcoords;
  foreach(subimage; 1..8){
    foreach(row ; 0..subImageHeight(4096,subimage)){
      foreach(col ; 0..subImageWidth(4096,subimage)){
	icoords ~= i(subimage,col,row);
	dcoords ~= c(subimage,col,row);
	//writef("si:%x::(%x,%x)->il(%x)",subimage,col, row, c.ilace(subimage,col,row),c.direct(subimage,col,row));
	//writef("%3x->%3x ",i(subimage,col,row),c(subimage,col,row));
      }
      //writeln();
    }
  }
  import std.algorithm;
  assert(equal(uniq(dcoords), dcoords));
  assert(equal(uniq(icoords), icoords));
  
}


/+
   16462646
   77777777
   56565656
   77777777
   36463646
   77777777
   56565656
   77777777
+/