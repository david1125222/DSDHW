module asu (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;

/*Write your code here*/
reg [7:0] adder;
reg [7:0] shifter;
reg carry1;

adder adder_1(x, y, carry1, adder);
barrel_shifter shifter_1(x, y[2:0], shifter);
assign out[7:0] = (mode==1'b1) ?   adder[7:0]: shifter[7:0];
assign carry = (mode==1'b1) ? carry1 : 1'b0;


/*End of code*/


endmodule