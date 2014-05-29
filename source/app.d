import std.stdio, std.file, std.conv, std.bitmanip;
import dpng;

ubyte[3] stuff(){
  return [0,1,2];
}/+
ubyte[4] rgb_To_argb( T t)( ubyte[3] data){
  return [ 0, data[2], data[1], data[0]];
}+/

ubyte[4] foo ( ubyte[3] a ){ 
  return [ 0, a[2], a[1], a[0]];
} 

void main(string[] args)
{ 
  ubyte[3] a = [5,6,7];
  writeln(a);
  writeln(a.ptr);
  a = stuff();b
  writeln(a);
  writeln(a.ptr);
  
  auto fileContents = cast(ubyte[])read(args[1]);
  PNGReader mpngReader = PNGReader(fileContents);
  mpngReader.verifyChunkOrder();
  mpngReader.extractData;
  mpngReader.decompress;
  auto data = mpngReader.decode();
  writeln(data[0..12]);
}
