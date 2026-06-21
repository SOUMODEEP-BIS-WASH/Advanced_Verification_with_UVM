`timescale 1ns/1ps 
`timescale 1ns / 1ps


module adder(
    input [3:0]a,b,
    input cin,
    output [3:0]sum,
    output cout
    );
    
    wire c1,c2,c3;
    
    fa f1(a[0],b[0],cin,sum[0],c1);
    fa f2(a[1],b[1],c1,sum[1],c2);
    fa f3(a[2],b[2],c2,sum[2],c3);
    fa f4(a[3],b[3],c3,sum[3],cout);
    
endmodule


module fa(input x,y,z, output s,c);

assign s = x^y^z;
assign c = (x&y)|(z&(x^y)) ;
endmodule