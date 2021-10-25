module HalfAdde(
    output Cnext,
    output Sthis, 
    input xn,
    input am,
    input Slast,
    input Cthis);

  wire t;
  and (t, xn, am);
  xor (Sthis, t, Slast, Cthis);
  xor (t1, Slast, Cthis);
  and (t2, t, t1);
  and (t3, Cthis, Slast);
  or (Cnext, t2, t3);

endmodule

module FullAdde(
    output Cnext,
    output Sthis,
    input xn,
    input am,
    input Cthis);
  
  wire t1, t2, t3;
  xor (t1, am, xn);
  and (t2, t1, Cthis);
  and (t3, am, xn);
  or (Cnext, t2, t3);
  xor (Sthis, t1, Cthis);

endmodule

module ArrayMultiplier(
    output [32 + 32 - 1 : 0] product,
    input [32 - 1 : 0] a,
    input [32 - 1 : 0] x
);

  wire c_partial[32 * 32 : 0];
  wire s_partial[32 * 32 : 0];
  
  // first line of the multiplier
  genvar i;
  generate
    for(i = 0; i < 32; i = i + 1)
    begin
      HalfAdde c_first(.Cnext(c_partial[i]), .Sthis(s_partial[i]),
                   .xn(x[0]), .am(a[i]), .Slast(1'b0), .Cthis(1'b0));
    end
  endgenerate
  
  // middle lines of the multiplier - except last column
  genvar j, k;
  generate
    for(k = 0; k < 32 - 1; k = k + 1)
    begin
      for(j = 0; j < 32 - 1; j = j + 1)
      begin
        HalfAdde c_middle(c_partial[32 * (k + 1) + j], s_partial[32 * (k + 1) + j],
                      x[k + 1], a[j], s_partial[32 * (k + 1)+ j - 32 + 1], c_partial[32 * (k + 1) + j - 32]);
      end
    end
  endgenerate
  
  // middle lines of the multiplier - only last column
  genvar z;
  generate
    for(z = 0; z < 32 - 1; z = z + 1)
    begin
      HalfAdde c_middle_last_col(c_partial[32 * (z + 1) + (32 - 1)], s_partial[32 * (z + 1) + (32 - 1)],
                             x[z + 1], a[+ (32 - 1)], 1'b0, c_partial[32 * (z + 1) + (32 - 1) - 32]);
    end
  endgenerate
  
  // last line of the multiplier
  wire c_last_partial[32 - 1 : 0] ;
  wire s_last_partial[32 - 2 : 0] ;
  buf (c_last_partial[0], 0);
  
  genvar l;
  generate
    for(l = 0; l < 32 - 1; l = l + 1)
    begin
      FullAdde c_last(c_last_partial[l + 1], s_last_partial[l],
                    c_partial[(32 - 1) * 32 + l], s_partial[(32 - 1) * 32 + l + 1], c_last_partial[l]);
    end
  endgenerate
  
  // product bits from first and middle cells
  generate
    for(i = 0; i < 32; i = i + 1)
    begin
      buf (product[i], s_partial[32 * i]);
    end
  endgenerate
  
  // product bits from the last line of cells
  generate
    for(i = 32; i < 32 + 32 - 1; i = i + 1)
    begin
      buf (product[i], s_last_partial[i - 32]);
    end
  endgenerate

  // msb of product
  buf (product[32 + 32 - 1], c_last_partial[32 - 2]);

endmodule
