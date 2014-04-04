import std.exception, std.digest.crc, std.stdio, std.array, std.container, std.algorithm, std.conv, std.range, std.zlib;
import endianrange, chunk;
struct PNGReader{
  EndianRange             pngData;
  RedBlackTree!(char[4])  allowed_chunks;
  ubyte[char[4]]          stuff;
  Chunk[]                 chunks;
  

  static bool isType(string file: "png")(ubyte[] pngdata){
    enforce( sig == [ 0x89, 'P','N','G', '\r', '\n', 26, 10], "shit, no valid headre");
    return true;
  }
  this( ubyte[] pngData)
  {
    allowed_chunks = new RedBlackTree!(char[4]);
    this.pngData = new EndianRange( pngData);
    auto sig =  this.pngData.frontN(8);
    enforce( sig == [ 0x89, 'P','N','G', '\r', '\n', 26, 10], "shit, no valid headre");
    this.pngData.popFrontN(8);
    writeln( "passed header check");

    try {
      while( true ) {
	chunks ~= Chunk(this);
      }
    }
    catch  {
      foreach ( chunk; chunks) {
	//writeln(chunk.metaInfo);
      }
    }
  } 
  
  auto verifyChunkOrder() {
    allowed_chunks.insert(cast(char[4])"IHDR");
    auto chunksDup = chunks.dup;
    Chunk current = chunksDup.front;
    while ( !chunksDup.empty){
      current = chunksDup.front;
      if ( std.algorithm.canFind( allowed_chunks[], current.type ))
      {
	if      (current.type ==  "zTXt"){enforce ( chunk!"zTXt"( current), "chunkError");}
	else if (current.type ==  "tEXt"){enforce ( chunk!"tEXt"( current), "chunkError");}
	else if (current.type ==  "iTXt"){enforce ( chunk!"iTXt"( current), "chunkError");}
	else if (current.type ==  "pHYs"){
	  enforce ( chunk!"pHYs"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"pHYs");
	}
	else if (current.type ==  "sPLT"){
	  enforce ( chunk!"sPLT"( current), "chunkError");
	}
	else if (current.type ==  "iCCP"){
	  enforce ( chunk!"iCCP"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"sRGB");
	  allowed_chunks.removeKey(cast(char[4])"iCCP");
	}
	else if (current.type ==  "sRGB"){
	  enforce ( chunk!"sRGB"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"iCCP");
	  allowed_chunks.removeKey(cast(char[4])"sRGB");
	}
	else if (current.type ==  "sBIT"){
	  enforce ( chunk!"sBIT"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"sBIT");
	}
	else if (current.type ==  "gAMA"){
	  enforce ( chunk!"gAMA"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"gAMA");
	}
	else if (current.type ==  "cHRM"){
	  enforce ( chunk!"cHRM"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"cHRM");
	}
	else if (current.type ==  "IHDR"){
	  enforce ( chunk!"IHDR"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"iHDR");
	} 
	else if (current.type ==  "PLTE"){
	  enforce ( chunk!"PLTE"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"cHRM");
	  allowed_chunks.removeKey(cast(char[4])"gAMA");
	  allowed_chunks.removeKey(cast(char[4])"sBIT");
	  allowed_chunks.removeKey(cast(char[4])"iCCP");
	  allowed_chunks.removeKey(cast(char[4])"sRGB");
	} 
	else if (current.type ==  "IDAT"){
	  enforce ( chunk!"IDAT"( current), "chunkError");
	  while( chunksDup.front.type == "IDAT"){
	    chunksDup = chunksDup[1..$];
	    current = chunksDup.front;
	    enforce ( chunk!"IDAT"( current), "chunkError");
	  }
	  allowed_chunks.removeKey(cast(char[4])"IDAT"); 

	  allowed_chunks.removeKey(cast(char[4])"pHYs");
	  allowed_chunks.removeKey(cast(char[4])"sPLT");
	  allowed_chunks.removeKey(cast(char[4])"iCCP");
	  allowed_chunks.removeKey(cast(char[4])"sRGB");
	  allowed_chunks.removeKey(cast(char[4])"sBIT");
	  allowed_chunks.removeKey(cast(char[4])"gAMA");
	  allowed_chunks.removeKey(cast(char[4])"cHRM");
	  allowed_chunks.removeKey(cast(char[4])"tRNS");
	  allowed_chunks.removeKey(cast(char[4])"hIST");
	  allowed_chunks.removeKey(cast(char[4])"bKGD")	;
    	  continue;
	} 
	else if (current.type ==  "bKGD"){
	  enforce ( chunk!"bKGD"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"bKGD");
    	  
	} 
	else if (current.type ==  "hIST"){
	  enforce ( chunk!"hIST"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"hIST");
	} 
	else if (current.type ==  "tRNS"){
	  enforce ( chunk!"tRNS"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"tRNS");
	} 
	else if (current.type ==  "tIME"){
	  enforce ( chunk!"tIME"( current), "chunkError");
	  allowed_chunks.removeKey(cast(char[4])"tIME");
	} 
      }
      else 
      {	
	if (current.type ==  "IEND")
	{
	  enforce ( chunk!"IEND"( current), "chunkError");
	  break;
	}
 	writeln("wrong chunk: ", current.type);
      }
      chunksDup = chunksDup[1..$];
    }
    
    writeln("end of verify"); 
  }

  ubyte[] cdata;
  ubyte[] udata;
  void extractData( ) 
  {
    auto mChunk = chunks.front; 
    while ( mChunk.type != ['I','D','A','T'] ) 
    {
      chunks.popFront;
      mChunk = chunks.front;
    }
    auto app = appender(cdata);
    while ( mChunk.type == ['I','D','A','T'] ) 
    {
      app.put(mChunk.data);
      
      chunks.popFront;
      mChunk = chunks.front;
    }
    cdata = app.data;
    writefln("cdata: length: %s ", cdata.length);
    
  }
  
  void decompress(){
    udata = cast(ubyte[])std.zlib.uncompress( cdata);
    writefln("udata: length: %s ", udata.length);
    writeln(udata[0..12]);
  }
  
  bool chunk(string chunkName)( Chunk mChunk){
    writeln("unknown chunk, default handling. Type: ", mChunk.type); 
    return mChunk.checkCRC();
  }

  bool chunk(string chunkName : "tEXt")( Chunk mChunk)
  {
    writeln("tEXt: ", cast(char[])mChunk.data); 
    return mChunk.checkCRC();
  }

  bool chunk(string chunkName : "IEND")( Chunk mChunk)
  {
    auto bitTester =  function( char rytlock)
    {
      return rytlock & 0b0010000;
    };
    auto critical = bitTester( mChunk.type[0]) == 0;
    auto privateBit = bitTester( mChunk.type[1]) ==1;
    auto reserved = bitTester( mChunk.type[2]) ==1;
    auto sefeToCopy  = bitTester( mChunk.type[3]) ==1;
    enforce(mChunk.length ==0, "IEND contains data, I don'tlike it.");
    writeln("IEND"); 
    return mChunk.checkCRC();
  }

  bool chunk(string chunkName: "IDAT")( Chunk mChunk)
  {
    allowed_chunks.removeKey( cast(char[4])"cHRM", cast(char[4])"gAMA", cast(char[4])"iCCP", cast(char[4])"sBIT", cast(char[4])"sRGB", cast(char[4])"bKGD", cast(char[4])"hIST", cast(char[4])"tRNS", cast(char[4])"pHYs", cast(char[4])"sPLT");
    writeln(mChunk.type, " CRC check: ", mChunk.checkCRC());
    return mChunk.checkCRC();
  }
  
  ubyte[3][] palette;
  bool chunk(string chunkName: "PLTE")( Chunk mChunk)
  {
    allowed_chunks.removeKey(cast(char[4])"cHRM", cast(char[4])"gAMA", cast(char[4])"iCCP", cast(char[4])"sBIT", cast(char[4])"sRGB"); 
    allowed_chunks.insert(cast(char[4])"bKGD");
    allowed_chunks.insert(  cast(char[4])"hIST"); 
    allowed_chunks.insert(  cast(char[4])"tRNS");
    writefln( "length is: %s, remainder: %s", mChunk.length, mChunk.length % 3);
    for( size_t i = 0; i < mChunk.data.length ; i+=3){
      foreach( j; 0..3)
      {
	palette ~= ['p','n','g'].to!(ubyte[3]);
	palette[i][j] = mChunk.data[i+j];
      }
    }
    return mChunk.checkCRC();
  }

  bool chunk(string chunkName: "sRGB" )( Chunk mChunk) 
  {
    allowed_chunks.removeKey( [ cast(char[4])"iCCP", cast(char[4])"sRGB"] );
    return mChunk.checkCRC();  }

  bool chunk(string chunkName: "iCCP" )( Chunk mChunk) 
  {
    allowed_chunks.removeKey( [ cast(char[4])"iCCP", cast(char[4])"sRGB"] );
    return mChunk.checkCRC();
  }

  bool chunk(string tIME: "tIME")( Chunk possiblytIME)
  {
    allowed_chunks.removeKey( cast(char[4])"tIME");
    return possiblytIME.checkCRC();
  }
  



  uint width;
  uint height;
  byte bit_depth	;
  byte colour_type	;
  byte compression_method	;
  byte filter_method	;
  byte interlace_method	;
  
  static string colourType( byte colourType ) {
    switch( colourType){
    case 0:
      return "greyscale";
    case 2:
      return "RGB";
    case 3:
      return "colour palette";
    case 4:
      return "GA";
    case 6:
      return "RGBA";
    default:
      return "illegal I think";
    }
  }
  static string compressionMethod( byte ct){
    switch( ct){
    case 0:
      return "deflate 32k sliding window";
    default:
      return "illegal I think";
    }
  }
  static string filterMethod( byte ct){
    switch( ct){
    case 0:
      return "adaptive filter";
    default:
      return "illegal I think";
    }
  }
  static string interlaceMethod( byte ct){
    switch( ct){
    case 0:
      return "no interlace";
    case 1:
      return "Adam7";
    default:
      return "illegal I think";
    }
  }

  ubyte[] decode(){
    if ( this.colour_type == 2  &&
	 this.bit_depth == 8  &&
	 this.compression_method == 0 && 
	 this.interlace_method == 0 &&
	 this.filter_method == 0 
	 ) {
      bool unsupportedFilter = false;
      ubyte[] ARGBdata = new ubyte[4*this.width*this.height];
      foreach( i; 0.. this.height ){
	//if (  udata[i*(this.width)*3+1] != 0 ) {
	if ( udata[i*(this.width)*3+i] == 0  ) {
	  //writeln("Done line ", i);
	  foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,this.width*3,3), std.range.iota(0,this.width*4,4))) {
	    //writeln("test");
	    ARGBdata[this.width*4*i+argb_j] = udata[this.width*3*i+i+1+rgb_j+2]; // B 
	    ARGBdata[this.width*4*i+argb_j+1] = udata[this.width*3*i+i+1+rgb_j+1];//G
	    ARGBdata[this.width*4*i+argb_j+2] = udata[this.width*3*i+i+1+rgb_j+0];//R
	    ARGBdata[this.width*4*i+argb_j+3] = 0;//udata[this.width*3*i+i+1+rgb_j+2]; //A
	  }
	} else if ( udata[i*(this.width)*3+i] == 3  ) {
	  //writeln("Done line ", i);
	  if ( i == 0 ){
	    foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,this.width*3,3), std.range.iota(0,this.width*4,4))) {
	      //writeln("test");
	      ARGBdata[this.width*4*i+argb_j] = udata[this.width*3*i+i+1+rgb_j+2]; // B 
	      ARGBdata[this.width*4*i+argb_j+1] = udata[this.width*3*i+i+1+rgb_j+1];//G
	      ARGBdata[this.width*4*i+argb_j+2] = udata[this.width*3*i+i+1+rgb_j+0];//R
	      ARGBdata[this.width*4*i+argb_j+3] = 0;//udata[this.width*3*i+i+1+rgb_j+2]; //A
	    }
	  }else{
	    foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,this.width*3,3), std.range.iota(0,this.width*4,4))) {
	      //writeln("test");
	      ARGBdata[this.width*4*i+argb_j] = udata[this.width*3*i+i+1+rgb_j+2]; // B 
	      ARGBdata[this.width*4*i+argb_j+1] = udata[this.width*3*i+i+1+rgb_j+1];//G
	      ARGBdata[this.width*4*i+argb_j+2] = udata[this.width*3*i+i+1+rgb_j+0];//R
	      ARGBdata[this.width*4*i+argb_j+3] = 0;//udata[this.width*3*i+i+1+rgb_j+2]; //A
	    }
	  }
	} else {// ( udata[i*(this.width)*3+i] != 0 ) {
	  unsupportedFilter = true; 
	  writeln("oups error, scanline #: ", i, ". Filter type: ", udata[i*(this.width)*3+i]);
	  foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,this.width*3,3), std.range.iota(0,this.width*4,4))) {	  
	    ARGBdata[this.width*4*i+argb_j] = udata[this.width*3*i+i+1+rgb_j+2]; // B 
	    ARGBdata[this.width*4*i+argb_j+1] = udata[this.width*3*i+i+1+rgb_j+1];//G
	    ARGBdata[this.width*4*i+argb_j+2] = udata[this.width*3*i+i+1+rgb_j+0];//R
	    ARGBdata[this.width*4*i+argb_j+3] = 0;//udata[this.width*3*i+i+1+rgb_j+2]; //A
	    //continue;//throw new std.exception.Exception("shit");
	  }
	}
      }
      return ARGBdata;
    }else   if ( this.colour_type == 2  &&
	 this.bit_depth == 8  &&
	 this.compression_method == 0 && 
	 this.interlace_method == 1 &&
	 this.filter_method == 0 
		 ) {
      import subImage;
      return unfilter!(0,1)(udata, width, height, 3);
    }else   if ( this.colour_type == 2  &&
	 this.bit_depth == 8  &&
	 this.compression_method == 0 && 
	 this.interlace_method == 0 &&
	 this.filter_method == 1 
		 ) {	  

      bool unsupportedFilter = false;
      ubyte[] ARGBdata = new ubyte[4*this.width*this.height];
      foreach( i; 0.. this.height ){
	unsupportedFilter = false;
	if ( udata[i*(this.width)*3+i] != 0 ) {
	  unsupportedFilter = true; 
	  writeln("oups error, scanline #: ", i, ". Filter type: ", udata[i*(this.width+1)*3]);
	  continue;//throw new std.exception.Exception("shit");
	}else {
	  //writeln("Done line ", i);
	  foreach ( rgb_j,argb_j; std.range.lockstep(std.range.iota(0,this.width*3,3), std.range.iota(0,this.width*4,4))) {
	    ARGBdata[this.width*4*i+argb_j] = udata[this.width*3*i+i+1+rgb_j+2]; // B 
	    ARGBdata[this.width*4*i+argb_j+1] = udata[this.width*3*i+i+1+rgb_j+1];//G
	    ARGBdata[this.width*4*i+argb_j+2] = udata[this.width*3*i+i+1+rgb_j+0];//R
	    ARGBdata[this.width*4*i+argb_j+3] = 255;//udata[this.width*3*i+i+1+rgb_j+2]; //A
	  }
	}
      }
      return ARGBdata;
    }
    else{
      return new ubyte[4*this.width*this.height];
    }
  }

  bool chunk(string IHDR: "IHDR")( Chunk possiblyIHDR)
  {
    if ( possiblyIHDR.length == 13 && possiblyIHDR.type == "IHDR" && possiblyIHDR.checkCRC())
    {
      writeln( "Seems like IHDR");
      alias mChunk = possiblyIHDR;
      auto data = new EndianRange( mChunk.data);
      auto chunkReader = new EndianRange(mChunk.data);
      this.width = chunkReader.front!(uint)[0];
      chunkReader.popFront!(uint);
      this.height = chunkReader.front!(uint)[0];
      chunkReader.popFront!(uint);
      this.bit_depth = chunkReader.front!(byte)[0];
      chunkReader.popFront!(byte);
      this.colour_type = chunkReader.front!(byte)[0];
      chunkReader.popFront!(byte);
      this.compression_method = chunkReader.front!(byte)[0];
      chunkReader.popFront!(byte);
      this.filter_method = chunkReader.front!(byte)[0];
      chunkReader.popFront!(byte);
      this.interlace_method = chunkReader.front!(byte)[0];
      chunkReader.popFront!(byte);
      
      writefln("width: %s; height: %s; bit_depth: %x; colour_type: %s; compression_method: %s; filter_method: %s; interlace_method: %s", 
	       width,
	       height,
	       bit_depth	,
	       colourType(colour_type)	,
	       compressionMethod(compression_method	),
	       filterMethod(filter_method	),
	       interlaceMethod(interlace_method)	
	       );
      
      allowed_chunks = redBlackTree!(char[4])([ "tIME", "zTXt", "tEXt", "iTXt", "pHYs","sPLT", "iCCP", "sRGB", "sBIT", "gAMA", "cHRM", "bKGD", "IDAT", "IEND"]);
      return true;
    }else{
      return false;
    }
    //return false;
  }

/+  ubyte[] refImage(){
    if ( filter_method == 0&& interlace_method == 0 ){
      
    }
  }
+/

  
}