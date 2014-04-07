import std.stdio;
import dpng, chunk;
ubyte[] decode1( PNGReader pngreader) {
  import std.algorithm;
  char[4] ihdrType = "IHDR";
  auto ret = find!( (Chunk chunk, char[4] t){ return chunk.type == t;})( pngreader.chunks, ihdrType);
  if( ret.length == 0){
    //writeln("no IHDR found");
  }
  IHDR ihdr = IHDR(ret[0]);
  uint colourchannels;
  switch( ihdr.colour_type){
  case 0:
    colourchannels = 1;
    break;  
  case 2:
    colourchannels = 3;
    break;  
  case 3:
    colourchannels = 1;
    break;  
  case 4:
    colourchannels = 2;
    break;  
  case 6:
    colourchannels = 4;
    break;
  default:
    throw new std.exception.Exception("colour error " ~ std.conv.to!string(ihdr.colour_type));
  }
  switch( ihdr.bit_depth ) {
  case 1:
    break;
  case 2:
    break;
  case 4:
    break;
  case 8:
    break;
  case 16:
    break;
  default:
    throw new std.exception.Exception("depth failure");
  }
  ubyte pixelsize = std.conv.to!(ubyte)(ihdr.bit_depth*colourchannels);
  //writeln("pixelsize: ",pixelsize);
  pixelsize +=7;
  pixelsize /=8;
  import reduceFilter;
  ReduceFilter rf = ReduceFilter( pngreader.udata, pngreader.interlace_method, pixelsize, pngreader.width, pngreader.height);
  rf.build;
  writeln( "#YOLO");
  if ( std.conv.to!bool("true")){
    writeln( "Using accessors");
    writeln( rf._realdata[0..12]);
    return rf._realdata;
  }
    
  
  
  if ( pngreader.colour_type == 2  &&
       pngreader.bit_depth == 8  &&
       pngreader.compression_method == 0 && 
       pngreader.interlace_method == 0 &&
       pngreader.filter_method == 0 
       ) {
    bool unsupportedFilter = false;
    ubyte[] ARGBdata = new ubyte[4*pngreader.width*pngreader.height];
    foreach( i; 0.. pngreader.height ){
      //if (  pngreader.udata[i*(pngreader.width)*3+1] != 0 ) {
      if ( pngreader.udata[i*(pngreader.width)*3+i] == 0  ) {
	//writeln("Done line ", i);
	foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,pngreader.width*3,3), std.range.iota(0,pngreader.width*4,4))) {
	  //writeln("test");
	  ARGBdata[pngreader.width*4*i+argb_j] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; // B 
	  ARGBdata[pngreader.width*4*i+argb_j+1] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+1];//G
	  ARGBdata[pngreader.width*4*i+argb_j+2] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+0];//R
	  ARGBdata[pngreader.width*4*i+argb_j+3] = 0;//pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; //A
	}
      } else if ( pngreader.udata[i*(pngreader.width)*3+i] == 3  ) {
	//writeln("Done line ", i);
	if ( i == 0 ){
	  foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,pngreader.width*3,3), std.range.iota(0,pngreader.width*4,4))) {
	    //writeln("test");
	    ARGBdata[pngreader.width*4*i+argb_j] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; // B 
	    ARGBdata[pngreader.width*4*i+argb_j+1] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+1];//G
	    ARGBdata[pngreader.width*4*i+argb_j+2] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+0];//R
	    ARGBdata[pngreader.width*4*i+argb_j+3] = 0;//pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; //A
	  }
	}else{
	  foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,pngreader.width*3,3), std.range.iota(0,pngreader.width*4,4))) {
	    //writeln("test");
	    ARGBdata[pngreader.width*4*i+argb_j] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; // B 
	    ARGBdata[pngreader.width*4*i+argb_j+1] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+1];//G
	    ARGBdata[pngreader.width*4*i+argb_j+2] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+0];//R
	    ARGBdata[pngreader.width*4*i+argb_j+3] = 0;//pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; //A
	  }
	}
      } else {// ( pngreader.udata[i*(pngreader.width)*3+i] != 0 ) {
	unsupportedFilter = true; 
	//writeln("oups error, scanline #: ", i, ". Filter type: ", pngreader.udata[i*(pngreader.width)*3+i]);
	foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,pngreader.width*3,3), std.range.iota(0,pngreader.width*4,4))) {	  
	  ARGBdata[pngreader.width*4*i+argb_j] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; // B 
	  ARGBdata[pngreader.width*4*i+argb_j+1] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+1];//G
	  ARGBdata[pngreader.width*4*i+argb_j+2] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+0];//R
	  ARGBdata[pngreader.width*4*i+argb_j+3] = 0;//pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; //A
	  //continue;//throw new std.exception.Exception("shit");
	}
      }
    }
    return ARGBdata;
  }else   if ( pngreader.colour_type == 2  &&
	       pngreader.bit_depth == 8  &&
	       pngreader.compression_method == 0 && 
	       pngreader.interlace_method == 1 &&
	       pngreader.filter_method == 0 
	       ) {
    import subImage;
    auto ert =  unfilter!(0,1)(pngreader.udata, pngreader.width, pngreader.height, 3);
    //writeln(ihdr);
    return ert;
  }else   if ( pngreader.colour_type == 2  &&
	       pngreader.bit_depth == 8  &&
	       pngreader.compression_method == 0 && 
	       pngreader.interlace_method == 0 &&
	       pngreader.filter_method == 1 
	       ) {	  

    bool unsupportedFilter = false;
    ubyte[] ARGBdata = new ubyte[4*pngreader.width*pngreader.height];
    foreach( i; 0.. pngreader.height ){
      unsupportedFilter = false;
      if ( pngreader.udata[i*(pngreader.width)*3+i] != 0 ) {
	unsupportedFilter = true; 
	//writeln("oups error, scanline #: ", i, ". Filter type: ", pngreader.udata[i*(pngreader.width+1)*3]);
	continue;//throw new std.exception.Exception("shit");
      }else {
	//writeln("Done line ", i);
	foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,pngreader.width*3,3), std.range.iota(0,pngreader.width*4,4))) {
	  ARGBdata[pngreader.width*4*i+argb_j] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; // B 
	  ARGBdata[pngreader.width*4*i+argb_j+1] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+1];//G
	  ARGBdata[pngreader.width*4*i+argb_j+2] = pngreader.udata[pngreader.width*3*i+i+1+rgb_j+0];//R
	  ARGBdata[pngreader.width*4*i+argb_j+3] = 255;//pngreader.udata[pngreader.width*3*i+i+1+rgb_j+2]; //A
	}
      }
    }
    return ARGBdata;
  }
  else{
    return new ubyte[4*pngreader.width*pngreader.height];
  }
}