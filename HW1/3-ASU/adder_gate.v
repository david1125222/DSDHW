module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;



/*Write your code here*/
wire carry_mid;


    reg cin= 0;
    fourBitPFA four_bit_adder1(x[3:0],y[3:0],cin,out[3:0],carry_mid);
    fourBitPFA four_bit_adder2(x[7:4],y[7:4],carry_mid,out[7:4],carry);



/*End of code*/

endmodule



module pfa(a,b,p,g);  //A one PFA. I need 16 of them5
    //wire w;
    //reg a,b,c;
    //wire sum,p,g;
    input a,b;
    output p,g;

    //xor (w,a,b);     //repeated P. May need it may not. 
    and (g,a,b);  //Gi
    xor (p,a,b);   //Pi
    //xor (sum,w,c);  //sum 
endmodule
                //input    output   
module fourBitPFA(A,B,Cin,S,Carry);
    input [3:0] A,B;
    input Cin;
    output [3:0] S;
    output Carry;    
    wire [3:0] P,G;
    wire p0,g0;
    wire b1,b2,b3;
    wire w,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12;
    wire c1,c2,c3;

        pfa PFA0(A[0],B[0],P[0],G[0]),
            PFA1(A[1],B[1],P[1],G[1]),    
            PFA2(A[2],B[2],P[2],G[2]),
            PFA3(A[3],B[3],P[3],G[3]);
        //propagate
        //and (p0,P[3],P[2],P[1],P[0]);

        //GENERATE
        //and (w,P[3],G[2]);
        //and (w1,P[3],P[2],G[1]);
        //and (w2,P[3],P[2],P[1],G[0]);
        //or (w,w1,w2);
//CLA 


        and (w3,P[0],Cin);
        or (c1,G[0],w3);
        and (w4,P[1],G[0]);
        and (w5,P[1],P[0],Cin);
        or (c2,G[1],w4,w5);
        and (w6,P[2],G[1]);
        and (w7,P[2],P[1],G[0]);
        and (w8,P[2],P[1],P[0],Cin);
        or (c3,G[2],w6,w7,w8);
        and (w9,P[3],G[2]);
        and (w10,P[3],P[2],G[1]);
        and (w11,P[3],P[2],P[1],G[0]);
        and (w12,P[3],P[2],P[1],P[0],Cin);
        or(Carry,G[3],w9,w10,w11,w12);
        xor(S[0],P[0],Cin);
        xor(S[1],P[1],c1);
        xor(S[2],P[2],c2);
        xor(S[3],P[3],c3);
endmodule