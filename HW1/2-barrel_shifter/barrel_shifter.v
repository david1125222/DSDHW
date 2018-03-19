module barrel_shifter(in, shift, out);
input  [7:0] in;
input  [2:0] shift;
output [7:0] out;

/*Write your code here*/
reg zero= 0;
/*wire  [7:0] x1;
wire  [7:0] x2;
reg zero= 0;
assign x1[7:1]=(in[7:1] & ~shift[0]) | (in[6:0] & shift[0]);
assign x1[0]=(in[0] & ~shift[0]);

assign x2[7:2]=(x1[7:2] & ~shift[1]) | (x1[5:0] & shift[1]);
assign x2[1:0]=(x1[1:0] & ~shift[1]) ;

assign out[7:4]=(x2[7:4] & ~shift[2]) | (x2[3:0] & shift[2]);
assign out[3:0]=(x2[3:0] & ~shift[2]) ;
*/
assign x1 =(shift[0]==1'b1) ?   in[7:0]* 2'b10: in[7:0];
assign x2 =(shift[1]==1'b1) ?   x1[7:0]* 3'b100 : x1[7:0];
assign out =(shift[2]==1'b1) ?   x2[7:0]* 5'b10000 : x2[7:0];
/*End of code*/
endmodule