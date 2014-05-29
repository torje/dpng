uint abs( int number ){
  if ( number < 0 ){
    return -number;
  } else {
    return number;
  }
}
uint PaethPredictor( ubyte a, ubyte b, ubyte c){
  uint p = a + b - c;
  int pa = abs(p - a);
  int pb = abs(p - b);
  int pc = abs(p - c);
  uint Pr;
  if ( (pa <= pb) && (pa <= pc)){
    Pr = a;
  }else if ((pb <= pc)){
    Pr = b;
  } else{
    Pr = c;
  }
  return Pr;
}
ubyte ReconPaeth(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)((x + PaethPredictor( a, b, c))%256);
}
ubyte FilterPaeth(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)((x - PaethPredictor( a, b, c))%256 );
}
ubyte ReconNone(ubyte x, ubyte a, ubyte b, ubyte c ){
  return x;
}
ubyte FilterNone( ubyte x, ubyte a, ubyte b, ubyte c ){
  return x;
}
ubyte ReconSub(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)(x+a);
}
ubyte FilterSub(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)(x-a);
}
ubyte ReconUp(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)(x+b);
}
ubyte FilterUp(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)(x-b);
}
ubyte ReconAverage(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)(x + ((a + b) / 2));
}
ubyte FilterAverage(ubyte x, ubyte a, ubyte b, ubyte c ){
  return cast(ubyte)(x - ((a + b) / 2));
} 

