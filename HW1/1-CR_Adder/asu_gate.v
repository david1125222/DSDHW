module asu_gate (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;

/*Write your code here*/
wire [7:0] adder;
wire [7:0] shifter;
wire carry1;
reg zero=0;

adder_gate adder_1(x, y, carry1, adder);
barrel_shifter_gate shifter_1(x, y[2:0], shifter);
assign #2.5 out[7:0] = (mode==1'b1) ?   adder[7:0]: shifter[7:0];
assign #2.5 carry = (mode==1'b1) ? carry1 : 1'b0;
 


/*End of code*/


endmodule

module mux_2 (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not  n0(sel_i,sel);
and  a1(w1,a,sel_i);
and  a2(w2,b,sel);
or   #2.5  o1(x,w1,w2);

endmodule
