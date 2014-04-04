import std.stdio, std.file, std.conv, std.bitmanip;
import dpng;

void main(string[] args)
{ 
  auto fileContents = cast(ubyte[])read(args[1]);
  PNGReader mpngReader = PNGReader(fileContents);
  mpngReader.verifyChunkOrder();
  mpngReader.extractData;
  mpngReader.decompress;
  auto data = mpngReader.decode();
  writeln(data[0..12]);
}
