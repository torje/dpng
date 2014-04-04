import dpng;
struct Chunk 
{
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
    this.length =pNGReader.pngData.front!(uint)[0];
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
private:
  uint _length;
  char[4] _type;
  ubyte[] _data;
  uint _crc;
  ubyte[] delegate(string fieldname) _field;
public:
  this(Chunk chunk){
    import endianrange;
    EndianRange   er    = new EndianRange(chunk.data);
    this._length	= chunk.length;
    this._type		= chunk.type;/+
    this._data		= chunk.data;
    this._crc		= chunk.crc;+/ 
  }  
  uint crc(){return _crc;};
  //uint type(){return _type;};
  //uint data(){return _data;};
  uint length(){return _length;};

  uint Width;//	4 bytes
  uint Height;//	4 bytes
  ubyte Bit_depth;//	1 byte
  ubyte Colour_type;//	1 byte
  ubyte Compression_method;//	1 byte
  ubyte Filter_method;//	1 byte
  ubyte Interlace_method;//	1 byte



}