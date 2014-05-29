

auto transform(ubyte[24] rgb){
  ubyte[32] rgba;
  rgba[0] = rgb[0];
  rgba[1] = rgb[1];
  rgba[2] = rgb[2];
  rgba[3] = 0;
  rgba[4] = rgb[3];
  rgba[5] = rgb[4];
  rgba[6] = rgb[5];
  rgba[7] = 0;
  rgba[8] = rgb[6];
  rgba[9] = rgb[7];
  rgba[10] = rgb[8];
  rgba[11] = 0;
  rgba[12] = rgb[9];
  rgba[13] = rgb[10];
  rgba[14] = rgb[11];
  rgba[15] = 0;
  rgba[16] = rgb[12];
  rgba[17] = rgb[13];
  rgba[18] = rgb[14];
  rgba[19] = 0;
  rgba[20] = rgb[15];
  rgba[21] = rgb[16];
  rgba[22] = rgb[17];
  rgba[23] = 0;
  rgba[24] = rgb[18];
  rgba[25] = rgb[19];
  rgba[26] = rgb[20];
  rgba[27] = 0;
  rgba[28] = rgb[21];
  rgba[29] = rgb[22];
  rgba[30] = rgb[23];
  rgba[31] = 0;
  return rgba;
}