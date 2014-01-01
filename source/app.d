import std.stdio, std.file, std.conv, std.bitmanip;

void main(string[] args)
{ 
  auto fileContents = cast(ubyte[])read(args[1]);
  auto PNGHeader = [0x89,0x50,0x4e,0x47,0xd,0xa,0x1a,0xa].to!(ubyte[]);
  if ( fileContents[0..8] == PNGHeader){
    writeln("Think this is a PNG header");
  } else {
    writeln(PNGHeader);
    writeln(fileContents[0..8]);
    writeln("I think not");
  }
  writef("%0x ", cast(char)fileContents[0]);
  writef("%s%s%s ", cast(char)fileContents[1], cast(char)fileContents[2], cast(char)fileContents[3]);
  writef( "%02x %02x ",  cast(char)fileContents[4], cast(char)fileContents[5]);
  writef("%02x ", cast(char)fileContents[6]);
  writefln("%02x ", cast(char)fileContents[7]);
  int[1] length = (cast(int*)(fileContents[8..12].ptr) )
    [0..1];
  int ilength = bigEndianToNative!(int)(fileContents[8..12]);
  writeln("Chunklength: ", ilength);
  int* chunkType = cast(int*)(fileContents[12..16].ptr);
  writeln("ChunkType:   ", *chunkType);
  uint crc = *(cast(int*)fileContents[16..20].ptr);
  writeln("CRC        : ", crc);
}
