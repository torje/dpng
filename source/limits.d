auto stringOfLimits(string delimitors, T)(T lower, T middle, T upper ){
  static import std.regex;
  import std.conv;
  auto filter = std.regex.ctRegex!(`\s*(<|\(|\[)\s*(>|\]|\))\s*`);
  auto mMatch = std.regex.match(delimitors , filter);
  if ( mMatch.empty ) {
    throw new std.exception.Exception("Delimitors invalid, apologies for not making this compiletime, please change template string to something like \"<)\" or \"[>\"");
    //std.stdio.writeln("not a matching set of delimitors");
  }else{
    if ( limits!delimitors(lower, middle, upper) ){
      return middle.to!string ~ " ∈ "~ mMatch.captures[1] ~lower.to!string ~","~upper.to!string~mMatch.captures[2];
    }else{
      return middle.to!string ~ " ∉ "~ mMatch.captures[1] ~lower.to!string ~","~upper.to!string~mMatch.captures[2];      
    }
  }
}

struct Limit ( ) {
  
}

auto limits (string delimitors, T)(T lower, T middle, T upper ){
  string errors;
  if ( lower > middle ) {
    errors ~= "enforce: lower <= middle failed";
  }
  if(  middle > upper){
    errors ~= "enforce: lower <= middle failed";
  }
  if ( errors.length > 0 ){
    static import std.exception;
    std.exception.enforce(0,errors);
  }
  static import std.regex;
  auto filter = std.regex.ctRegex!(`\s*(<|\(|\[)\s*(>|\]|\))\s*`);
  auto mMatch = std.regex.match(delimitors , filter);
  if ( mMatch.empty ) {
    throw new std.exception.Exception("Delimitors invalid, apologies for not making this compiletime, please change template string to something like \"<)\" or \"[>\"");
    //std.stdio.writeln("not a matching set of delimitors");
  }else{
    bool withinLimits = true;
    if ( mMatch.captures[1] == "(" || mMatch.captures[1] == "<"){
      withinLimits = lower <middle;
    }else if (  mMatch.captures[1] == "[" ){
      withinLimits = lower <=middle;
      
    }else{
      throw new Exception( "Oups! I thought this was an unreachable statement, submit bug report please.  Error is in start part of limits.");
    }


    if ( mMatch.captures[2] == ")" || mMatch.captures[2] == ">"){
      withinLimits &=  middle < upper;  
    }else if (  mMatch.captures[2] == "]" ){
      withinLimits &=  middle <= upper;        
    }else{
      throw new Exception( "Oups! I thought this was an unreachable statement, submit bug report please. Error is in end part of limits");
    }
    return withinLimits;
  }
}
  