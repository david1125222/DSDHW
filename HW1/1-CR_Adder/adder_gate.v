module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;


/*Write your code here*/
    wire c1,c2,c3,c4,c5,c6,c7,c8;
    reg cin= 0;
    full_adder fa1(x[0],y[0],cin,out[0],c1);
    full_adder fa2(x[1],y[1],c1,out[1],c2);
    full_adder fa3(x[2],y[2],c2,out[2],c3);
    full_adder fa4(x[3],y[3],c3,out[3],c4);
    full_adder fa5(x[4],y[4],c4,out[4],c5);
    full_adder fa6(x[5],y[5],c5,out[5],c6);
    full_adder fa7(x[6],y[6],c6,out[6],c7);
    full_adder fa8(x[7],y[7],c7,out[7],carry);


/*End of code*/

endmodule

module full_adder(x1,y1,ci,sum,co);
    input x1, y1, ci;
    output co,sum;
    wire xy,yc,cx;

    and #1 g0(xy, x1, y1);
    and #1 g1(yc, y1, ci);
    and #1 g2(cx, x1, ci);ssh
    or #1 g3(co, xy, yc, cx);
    xor #1 g4(sum, x1,y1, ci);

endmodule

