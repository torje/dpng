import std.stdio;
import coordinates;

auto limitstester(string del, T)(T lower, T middle, T upper ){
  import std.conv;
  return stringOfLimits!del(lower, middle, upper) ~ " " ~limits!del(lower, middle, upper).to!string;
}
unittest{
  writeln(limitstester!"()"(1,2,3));
  writeln(limitstester!"[)"(1,2,3));
  writeln(limitstester!"[]"(1,2,3));
  writeln(limitstester!"(]"(1,2,3));

  writeln(limitstester!"()"(1,1,3));
  writeln(limitstester!"[)"(1,1,3));
  writeln(limitstester!"[]"(1,1,3));
  writeln(limitstester!"(]"(1,1,3));

  writeln(limitstester!"()"(1,3,3));
  writeln(limitstester!"[)"(1,3,3));
  writeln(limitstester!"[]"(1,3,3));
  writeln(limitstester!"(]"(1,3,3));
}