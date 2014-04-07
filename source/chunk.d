import dpng;
struct Chunk {
  uint length;
  char[4] type;
  ubyte[] data;
  uint crc;
  ubyte[] delegate(string fieldname) field;

  this( uint length, char[4] type, ubyte[] data, uint crc)
  {
    this.length =       length;  
    this.type   =	type;	
    this.data   =	data.dup;	
    this.crc    =	crc;
  }
    
  this( PNGReader pNGReader) {
    this.length = pNGReader.pngData.front!(uint)[0];
    pNGReader.pngData.popFront!(uint);
    this.type = pNGReader.pngData.front!(char[4])[0];
    pNGReader.pngData.popFront!(char[4]);
    this.data = pNGReader.pngData.frontN(this.length);
    pNGReader.pngData.popFrontN(this.length);
    this.crc = pNGReader.pngData.front!(uint)[0];
    pNGReader.pngData.popFront!(ubyte[4]);
  }
  auto checkCRC( ) {
    import std.bitmanip, std.digest.crc, std.conv;
    ubyte[] typeAsUbyteArr = (cast(ubyte*)this.type.ptr)[0..4];
    return (*cast(uint*)crc32Of( typeAsUbyteArr ~ this.data).ptr) == this.crc;
  }
  string metaInfo()
  {
    import std.array, std.format;
    auto str = appender!string;
    formattedWrite(str, "length: %s, type: %s, crc: %s-%s", this.length, this.type, this.crc, this.checkCRC);
    return str.data;
  }
}

struct IHDR{
  import endianrange;
private:
  uint _length;
  char[4] _type;
  ubyte[] _data;
  uint _crc;
  ubyte[] delegate(string fieldname) _field;
public:
  this(Chunk chunk){
    import endianrange;
    import std.array;
    this._length	= chunk.length;
    this._type		= chunk.type;
    this._data		= chunk.data;
    this._crc		= chunk.crc;
    EndianRange er = new EndianRange(chunk.data);
    _Width = er.front!uint[0];
    er.popFront!uint;
    _Height = er.front!uint[0];
    er.popFront!uint;
    _Bit_depth = er.front!ubyte[0];
    er.popFront!ubyte;
    _Colour_type = er.front!ubyte[0];
    er.popFront!ubyte;
    _Compression_method = er.front!ubyte[0];
    er.popFront!ubyte;
    _Filter_method = er.front!ubyte[0];
    er.popFront!ubyte;
    _Interlace_method = er.front!ubyte[0];
    er.popFront!ubyte;
  }  
  uint crc(){return _crc;};
  uint type(){return ( new EndianRange( _type)).front!uint[0]; }
  uint data(){return ( new EndianRange( _data)).front!uint[0]; }
  uint length(){return _length;};
  string toString(){
    import std.array, std.format;
    auto app = appender!string;
    formattedWrite( app, "%s--%s--%s--%s::", _length, _type, _data, _crc);
    formattedWrite( app, 
		    "width:%s--height:%s--bit_depth:%s--colour_type:%s--compression_method:%s--filter_method:%s--interlace_method:%s", 
		    width, 
		    height, 
		    bit_depth, 
		    colour_type, 
		    compression_method, 
		    filter_method, 
		    interlace_method);
    return app.data;
  }
private:
  uint _Width;//	        4 bytes
  uint _Height;//	        4 bytes
  ubyte _Bit_depth;//	        1 byte
  ubyte _Colour_type;//	        1 byte
  ubyte _Compression_method;//	1 byte
  ubyte _Filter_method;//	1 byte
  ubyte _Interlace_method;//	1 byte
public:
  uint width(){ return _Width;}
  uint height(){ return _Height;}
  uint bit_depth(){ return _Bit_depth;}
  uint colour_type(){ return _Colour_type;}
  uint compression_method(){ return _Compression_method;}
  uint filter_method(){ return _Filter_method;}
  uint interlace_method(){ return _Interlace_method;}


}