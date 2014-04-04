struct ImageUnfilterer{
  NonInterlacedAccessor niAccessor;
  InterlacedImageAccessor iAccessor;
  DirectImageAccessor dAccessor;
  uint filtertype;
  uint interlace;
  @disable this();
  this( ubyte[] filtereddata, uint filtertype, uint interlace, uint imagewidth, uint imageheight, uint pixelsize){
    this.filtertype = filtertype;
    this.interlace = interlace;
    niAccessor = NonInterlacedAccessor( imagewidth, imageheight,pixelsize, filtereddata);
    iAccessor = InterlacedImageAccessor( imagewidth, imageheight,pixelsize, filtereddata);
    dAccessor = DirectImageAccessor( imagewidth, imageheight,pixelsize);    
  }
}

struct NonInterlacedAccessor{
  ubyte[] data;
  uint delegate(uint,uint) ni;
  @disable this();
  this( uint imageWidth, uint imageHeight, uint pixelsize, ubyte[] filteredData  ){
    setup ( imageWidth, imageHeight, pixelsize, filteredData ); 
  }
  void setup( uint imageWidth, uint imageHeight, uint pixelsize, ubyte[] filteredData  ){
    ni = noninterlaceCoords( imageWidth, imageHeight, pixelsize);
    data = filteredData;
  }
  ubyte opIndex(int column, int row){
    if ( 0>column||0>row){
      return data[ni(column,row)];
    }
    else{
      return 0;
    }
  }
  ubyte opIndex(int column, int row, ubyte value){
    if ( 0>column||0>row){
      return data[ni(column,row)];
    }
    else{
      return 0;
    }
  }
  auto noninterlaceCoords(uint imageWidth, uint imageHeight, uint pixelsize){
    return delegate uint (uint column,uint row){
      uint linewidth = imageWidth * pixelsize + 1;
      return linewidth*row + 1 +column*pixelsize;
    };
  }
}

struct InterlacedImageAccessor{
  ubyte[] data;
  uint delegate(uint,uint,uint) i;
  @disable this();
  this(  uint imageWidth, uint imageHeight, uint pixelsize, ubyte[] filteredData   ){
    setup( imageWidth, imageHeight, pixelsize, filteredData  );
  }
  void setup( uint imageWidth, uint imageHeight, uint pixelsize, ubyte[] filteredData  ){
    i = interlaceCoords( imageWidth, imageHeight, pixelsize);
    data = filteredData;
  }
  ubyte opIndex(int subimage, int column, int row){
    if ( 0>column||0>row){
      return data[i(subimage,column,row)];
    }else{
      return 0;
    }
  }
  ubyte opIndex(int subimage, int column, int row, ubyte value){
    if ( 0>column||0>row){
      return data[i(subimage,column,row)];
    }else{
      return 0;
    }
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
}
struct DirectImageAccessor{
  ubyte[] data;
  uint delegate(uint,uint,uint) d;
  @disable this();
  this(  uint imageWidth, uint imageHeight, uint pixelsize    ){
    setup ( imageWidth, imageHeight, pixelsize  );
  }
  void setup( uint imageWidth, uint imageHeight, uint pixelsize  ){
    d = directCoords( imageWidth, imageHeight, pixelsize);
    data = new ubyte[](imageWidth*imageHeight*pixelsize);
  }
  ubyte opIndex(int subimage, int column, int row){
    if ( 0>column||0>row){
      return data[d(subimage,column,row)];
    }else{
      return 0;
    }
  }
  ubyte opIndex(int subimage, int column, int row, ubyte value){
    if ( 0>column||0>row){
      return data[d(subimage,column,row)];
    }else{
      return 0;
    }
  }
  auto directCoords(uint imageWidth, uint imageHeight, uint pixelsize){
    return delegate uint  (uint subimage, uint column, uint row){
      uint row_add, row_mult,
	col_add, col_mult;
      switch ( subimage ) {
      case 1: row_add = 0, col_add = 0, row_mult=8, col_mult = 8; break;
      case 2: row_add = 0, col_add = 4, row_mult=8, col_mult = 8; break;
      case 3: row_add = 4, col_add = 0, row_mult=8, col_mult = 4; break;
      case 4: row_add = 0, col_add = 2, row_mult=4, col_mult = 4; break;
      case 5: row_add = 2, col_add = 0, row_mult=4, col_mult = 2; break;
      case 6: row_add = 0, col_add = 1, row_mult=2, col_mult = 2; break;
      case 7: row_add = 1, col_add = 0, row_mult=2, col_mult = 1; break;
      default: row_add = 0, col_add = 0, row_mult=0, col_mult = 0; break;
      }
      return (column*col_mult+col_add) * pixelsize + (row*row_mult+row_add)*pixelsize*imageWidth;
    };
  }
}

uint subImageWidth( uint imageWidth, uint subImageNo ) {
  uint add;
  uint divisor;
  switch( subImageNo ){
  case 1: add = 7; divisor = 8; break;
  case 2: add =3; divisor = 8; break;
  case 3: add = 3; divisor = 4; break;
  case 4: add = 1; divisor = 4; break;
  case 5: add = 1; divisor = 2; break;
  case 6: add = 0; divisor = 2; break;
  case 7: add = 0; divisor=1; break;
  default: add = add.max; divisor = divisor.max;
  }
  return (imageWidth+add)/divisor;
}
uint subImageHeight( uint imageHeight, uint subImageNo) {
  uint add, div;
  switch(subImageNo){
  case 1: add = 7; div = 8; break;
  case 2: add = 7; div = 8; break;
  case 3: add = 3; div = 8; break;
  case 4: add = 3; div = 4; break;
  case 5: add = 1; div = 4; break;
  case 6: add = 1; div = 2; break;
  case 7: add = 0; div = 2; break;
  default: add= add.max; div = div.max;
  }
  return (imageHeight+add)/div;
}