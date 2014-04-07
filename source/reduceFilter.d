import std.stdio, std.exception;
import coordinates;

struct ReduceFilter{
  this( ubyte[] _udata, ubyte interlace, ubyte pixelsize, uint width, uint height){
    this.data = _udata;
    writeln(_udata[0..10]);
    this.interlace = interlace;
    this.pixelsize = pixelsize;
    this.width = width;
    this.height = height;
  }
  ubyte[] _data;
  ubyte[] _realdata;
  ubyte _pixelsize;
  uint _width;
  uint _height;
  ubyte _interlace;
  @property ubyte[] data(ubyte[] udata){ return _data = udata; }
  @property ubyte[] data(){ return _data; }
  @property ubyte pixelsize(){return _pixelsize; }
  @property ubyte pixelsize(ubyte pixelSize){return _pixelsize = pixelSize; }
  @property uint width(){ return _width; }
  @property uint width( uint Width){ return _width = Width; }
  @property uint height(){ return _height; }
  @property uint height( uint Height){ return _height = Height; }
  @property uint interlace(){ return _interlace; }
  @property uint interlace( ubyte Interlace){ return _interlace = Interlace; }
  
  void build(){
    if ( interlace == 0 ) {
      NonInterlacedAccessor source = NonInterlacedAccessor( width, height,pixelsize, _data);
      NonInterlacedAccessor dest = NonInterlacedAccessor( width, height,pixelsize, new ubyte[_data.length]);
      FlatImageAccessor final_destination = FlatImageAccessor( width, height,4);
      foreach ( int row; 0..height){
	foreach ( int column; 0..width){
	  import filters;
	  auto unfilter = &ReconPaeth;
	  switch( source.getFilter(row)){
	  case 0:
	    unfilter = &ReconNone;
	    break;
	  case 1:
	    unfilter = &ReconSub;
	    break;
	  case 2:
	    unfilter = &ReconUp;
	    break;
	  case 3:
	    unfilter = &ReconAverage;
	    break;
	  case 4:
	    unfilter = & ReconPaeth;
	    break;
	  default:
	  }
	  foreach( ubyte subpixel; 0..pixelsize){
	    dest[column, row, subpixel] = 
	      unfilter(
		       source[column,row,subpixel], 
		       dest[column-1,row,subpixel], 
		       dest[column,row-1,subpixel],
		       dest[column-1,row-1,subpixel]);
	  }
	}
      }
	
      foreach ( int row; 0..height){
	foreach ( int column; 0..width){
	  foreach( ubyte subpixel; 0..pixelsize){
	    final_destination[column, row, subpixel] = dest[column,row,subpixel];  
	  }
	}
	
      }
      
      writeln( "dest[0..12] ", dest.data[0..12]);
      writeln( "source[0..12] ", source.data[0..12]);
      writeln( "final dest[0..12] ", final_destination.data[0..12]);
      _realdata = final_destination.data;
      
    }else if ( interlace == 1 ) { 
      InterlacedImageAccessor source = InterlacedImageAccessor( width, height,pixelsize, _data);
      InterlacedImageAccessor dest = InterlacedImageAccessor( width, height,pixelsize, new ubyte[_data.length]);
      //writeln(  source.data[0..10]);
      foreach( subimage; 1..8){
	foreach ( int row; 0..subImageHeight(height, subimage )){
	  import filters;
	  auto unfilter = &ReconPaeth;
	  switch( source.getFilter(subimage, row)){
	  case 0:
	    unfilter = &ReconNone;
	    break;
	  case 1:
	    unfilter = &ReconSub;
	    break;
	  case 2:
	    unfilter = &ReconUp;
	    break;
	  case 3:
	    unfilter = &ReconAverage;
	    break;
	  case 4:
	    unfilter = & ReconPaeth;
	    break;
	  default:
	  }
	  foreach ( int column; 0..subImageWidth(width, subimage )){
	    foreach( ubyte subpixel; 0..pixelsize){
	      import filters;
	      dest[subimage,column, row , subpixel] = 
		unfilter(
			 source[subimage,column,row,subpixel], 
			 dest[subimage,column-1,row,subpixel], 
			 dest[subimage,column,row-1,subpixel],
			 dest[subimage,column-1,row-1,subpixel]);
	    }
	  }
	}
      }
      auto dia = DirectImageAccessor( width, height, 4);
      foreach( subimage; 1..8){
	foreach ( int row; 0..subImageHeight(height,subimage)){
	  foreach ( int column; 0..subImageWidth(width, subimage)){
	    dia[subimage,column, row,2] = dest[subimage,column,row,0];
	    dia[subimage,column, row,1] = dest[subimage,column,row,1];
	    dia[subimage,column, row,0] = dest[subimage,column,row,2];
	  }
	}
      }
      _realdata = dia.data;
    }
  }
}