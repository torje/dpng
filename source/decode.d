import std.stdio;
import dpng, chunk;
ubyte[] decode1( PNGReader pngreader) {
  import std.algorithm;
  import core.time;
  auto timeStart = TickDuration.currSystemTick();
  auto timeStop = TickDuration.currSystemTick();

  char[4] ihdrType = "IHDR";
  auto ret = find!( (Chunk chunk, char[4] t){ return chunk.type == t;})( pngreader.chunks, ihdrType);
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
  auto RGB_to_RGBA = lambdaGen(ihdr.bit_depth ,colourchannels,4,255 );
  foreach ( int row; 0..rf.height){
      uint d_rowstart = rf.final_destination.d(0, row);
      uint ni_rowstart = rf.source.ni(0, row);
			
      foreach ( int column; 0..rf.width){
	  auto s = rf.source.data[ni_rowstart+4*column..ni_rowstart+4+4*column];
	  auto d = rf.final_destination.data[d_rowstart+4*column..d_rowstart+4+4*column];
	  immutable uint channels4 = 4;
	  RGB_to_RGBA( s, d);	
      }
  }
  timeStop = TickDuration.currSystemTick();
  writeln("Copystep: ", (timeStop -timeStart).to!("msecs",double));
  timeStart = TickDuration.currSystemTick();
  return rf._realdata;
}

auto lambdaGen( uint sourceDepth, uint sourceChannels, uint destDepth, uint destChannels, ubyte defaultVal = 255)
{
    if ( ( sourceDepth    == destDepth && destDepth == 8  ) && ( sourceChannels <= destChannels    ) )	{
	return delegate void (ref ubyte[] source, ref ubyte[] dest) {
	    dest[sourceChannels..$] = defaultVal;
	    foreach( i; 0..sourceChannels){
		auto temp = source[i];
		dest[i] = temp;
	    }
	  };
    }else{
	return delegate void(ref ubyte[] source, ref ubyte[] dest) {
	    dest[sourceChannels..$] = defaultVal;
	    foreach( i; 0..min(sourceChannels, destChannels)){
		auto temp = source[i];
		dest[i] = temp;
	    }
	};	
    }
}