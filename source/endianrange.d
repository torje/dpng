import std.range, std.bitmanip, std.conv, std.stdio;
class EndianRange{
  private ubyte[] data;
  private size_t offset = 0; 
  
  this()
  {
  }
  
  this(U)(U[] data) 
  if (U.sizeof == ubyte.sizeof) 
  {
    ubyte[] intermediate = cast(ubyte[]) data;
    this.data = intermediate;
  }
  
  ubyte[] opSlice(size_t a, size_t b)
  {
    return data[offset+a..offset+b];
  }
  
  private void fixAlignment(){
    size_t alignment = 8;
    auto popof = offset / alignment;
    auto offset = offset % alignment;
    data.popFrontN(popof);
  }
  
  void setSource( ubyte[] data)
  {
    this.data = data;
  }
  
  @property bool empty()
  {
    return data.empty;
  }

  @property auto front()
  {
    return data.front;
  }

  @property auto frontN( size_t n)
  {
    return  data[0..n];
  }
  @property U[] frontN(U)( size_t n)
  {
    auto retval = new U[n];
    auto intermediate = data[0..U.sizeof*n];
    foreach(i ; 0..n){
      retval[i] = bigEndianToNative!U(intermediate[0..U.sizeof]);
      intermediate.popFront;
    }
    return  retval;
  }
  
  void popFront()
  {
    data.popFront();
  }

  void popFront(size_t n)
  {
    data.popFrontN(n*ubyte.sizeof);
  }

  void popBack()
  {
    data.popBack();
  }

  void popBackN(size_t n)
  {
    data.popBackN( n);
  }
  
  @property U back(U)()
  {
    ubyte[U.sizeof] intermediate = data[$-U.sizeof..$];
    return bigEndianToNative!(U)(intermediate);
  }
  
  void popFront(U)()
  {
    data.popFrontN(U.sizeof);
  }

  
  void popFrontN(U)(size_t n)
  {
    data.popFrontN(n*U.sizeof);
  }

  void popBack(U)(){
    data.popBackN(U.sizeof);
  }

  void popBackN(U)(size_t n)
  {
    data.popBackN(n*U.sizeof);
  }

  private auto tupleMutilator( T...)( ubyte[] bytes)
  {
    import std.traits, std.array, std.typecons;
    Tuple!(T) retval;
    size_t start = 0;
    alias thisType = typeof( T.init[0][0]);
    foreach(i; 0..T.init[0].length){
      if ( thisType.sizeof != 1){ 
	ubyte[thisType.sizeof] shit = bytes[start..start+thisType.sizeof];
	retval[0][i] = 
	  bigEndianToNative!
	  (thisType)
	  ( shit);
      }else{
	retval[0][i] = cast(char)bytes[start];
      }
      start+=thisType.sizeof;

    }
    // foreach(i, t; T.init){
    //   pragma(msg,t.init[0]);
    //   pragma(msg, typeof(bytes));
    //   ubyte[t.init[0].sizeof] shit = bytes[start..start+t.init[0].sizeof];
    //   writeln("this is shit: ",shit);
    //   retval[i] = bigEndianToNative!(typeof(t.init[0]))( shit);
    //   bytes =bytes [ t.init[0].sizeof ..$];
    //   //bytes.popFrontN(t.init[0].sizeof);
    //   //start+=t.init[0].sizeof;
    // }
    //return "";
    return retval;
  }

  auto front(T...)()
  {
    import std.traits, std.array, std.typecons;
    size_t byteSize = 0;
    foreach( t; T){
      writeln(t.stringof);
      byteSize += t.sizeof;
    }
    auto intermediate = data[0..byteSize];
    std.typecons.Tuple!T retval;
    size_t start = 0;
    foreach( i, t; T)
    {
      static if( !isStaticArray!(t) ) {
	ubyte[t.sizeof] shit = intermediate[start..start+t.sizeof];
	retval[i] = bigEndianToNative!(t)( shit);
      }else if ( isStaticArray!(t) ) {
	auto a = tupleMutilator!(t)( data[start..start+t.sizeof]);
	retval[i] = a[0];
      }
      start += t.sizeof;
    }
    return retval;
  }

  void popFront(T...)()
  {
    foreach( i, t; T)
    {
      data.popFrontN( t.sizeof );
    }
  }

}

unittest{
}