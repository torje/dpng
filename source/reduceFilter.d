import std.stdio, std.exception;
import coordinates;

struct ReduceFilter{
    this( ubyte[] _udata, ubyte interlace, ubyte pixelsize, uint width, uint height){
	this.data = _udata;
	//writeln(_udata[0..10]);
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
	import core.time;
	auto timeStart = TickDuration.currSystemTick();
	auto timeStop = TickDuration.currSystemTick();
	timeStop = TickDuration.currSystemTick();
	//writeln((timeStop -timeStart).to!("msecs",double));
	timeStart = TickDuration.currSystemTick();
	if ( interlace == 0 ) {
	    NonInterlacedAccessor source = NonInterlacedAccessor( width, height,pixelsize, _data);
	    FlatImageAccessor final_destination = FlatImageAccessor( width, height,4);
	    ubyte[] flat = final_destination.data;
	    timeStop = TickDuration.currSystemTick();
	    //writeln((timeStop -timeStart).to!("msecs",double));
	    timeStart = TickDuration.currSystemTick();
	    ubyte[] previous=new ubyte[source.ni(0,1)-1+pixelsize];
	    foreach( ref i ; previous){ i=0;}
	    foreach ( int row; 0..height){
		import filters;
		ubyte[] line = new ubyte[source.ni(0,row+1)-source.ni(0,row)-1+pixelsize];
		line =  source.data[source.ni( 0, row) .. source.ni(0,row+1)-1];
		switch( source.getFilter(row)){
		case 0:
		    break;
		case 1:
		    foreach(i; 0..pixelsize){
			line[i] = ReconSub(line[i], 0, previous[i], 0);                     
		    }
		    foreach ( column; pixelsize..line.length){
			line[column] = ReconSub(line[column], line[column-pixelsize], previous[column], previous[column-pixelsize]);
		    }
		    break;
		case 2:
		    foreach ( column; pixelsize..line.length){
			line[column] = ReconUp(line[column], line[column-pixelsize], previous[column], previous[column-pixelsize]);
		    }
		    break;
		case 3:
		    foreach(i; 0..pixelsize){
			line[i] = ReconAverage(line[i], 0, previous[i], 0);                     
		    }
		    foreach ( column; pixelsize..line.length){
			line[column] = ReconAverage(line[column], line[column-pixelsize], previous[column], previous[column-pixelsize]);
		    }
		    break;
		case 4:
		    foreach(i; 0..pixelsize){
			line[i] = ReconPaeth(line[i], 0, previous[i], 0);                     
		    }
		    foreach ( column; pixelsize..line.length){
			line[column] = ReconPaeth(line[column], line[column-pixelsize], previous[column], previous[column-pixelsize]);      
		    }
		    break;
		default:
		}
		previous = line;
	    }

	    timeStop = TickDuration.currSystemTick();
	    writeln("Start: ", (timeStop -timeStart).to!("msecs",double));
	    timeStart = TickDuration.currSystemTick();
	    uint index = 0;
	    _realdata = final_destination.data;
      
	}else if ( 1 == interlace  ) { 
	    InterlacedImageAccessor source = InterlacedImageAccessor( width, height,pixelsize, _data);
	    InterlacedImageAccessor dest = InterlacedImageAccessor( width, height,pixelsize, new ubyte[_data.length]);
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
			    source[subimage,column, row , subpixel] = unfilter(source[subimage,column,row,subpixel], source[subimage,column-1,row,subpixel], source[subimage,column,row-1,subpixel], source[subimage,column-1,row-1,subpixel]);
			}
		    }
		}
	    }
	    auto dia = DirectImageAccessor( width, height, pixelsize);
	    foreach( subimage; 1..8){
		foreach ( int row; 0..subImageHeight(height,subimage)){
		    foreach ( int column; 0..subImageWidth(width, subimage)){
			dia[subimage,column, row,2] = source[subimage,column,row,0];
			dia[subimage,column, row,1] = source[subimage,column,row,1];
			dia[subimage,column, row,0] = source[subimage,column,row,2];
		    }
		}
	    }
	    _realdata = dia.data;
	}
    }
}