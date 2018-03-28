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
mux_2 out_0(out[0], shifter[0], adder[0], mode);
mux_2 out_1(out[1], shifter[1], adder[1], mode);
mux_2 out_2(out[2], shifter[2], adder[2], mode);
mux_2 out_3(out[3], shifter[3], adder[3], mode);
mux_2 out_4(out[4], shifter[4], adder[4], mode);
mux_2 out_5(out[5], shifter[5], adder[5], mode);
mux_2 out_6(out[6], shifter[6], adder[6], mode);
mux_2 out_7(out[7], shifter[7], adder[7], mode);
mux_2 out_8(carry, zero, carry1, mode);
 


/*End of code*/


endmodule

module mux_2 (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not  n0(sel_i,sel);
and  a1(w1,a,sel_i);
and  a2(w2,b,sel);
or   o1(x,w1,w2);

endmodule
