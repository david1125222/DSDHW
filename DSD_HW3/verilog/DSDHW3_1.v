// Single Cycle MIPS
//=========================================================
// Input/Output Signals:
// positive-edge triggered         clk
// active low asynchronous reset   rst_n
// instruction memory interface    IR_addr, IR
// output for testing purposes     RF_writedata  
//=========================================================
// Wire/Reg Specifications:
// control signals             MemToReg, MemRead, MemWrite, 
//                             RegDST, RegWrite, Branch, 
//                             Jump, ALUSrc, ALUOp
// ALU control signals         ALUctrl
// ALU input signals           ALUin1, ALUin2
// ALU output signals          ALUresult, ALUzero
// instruction specifications  r, j, jal, jr, lw, sw, beq
// sign-extended signal        SignExtend
// MUX output signals          MUX_RegDST, MUX_MemToReg, 
//                             MUX_Src, MUX_Branch, MUX_Jump
// registers input signals     Reg_R1, Reg_R2, Reg_W, WriteData 
// registers                   Register
// registers output signals    ReadData1, ReadData2
// data memory contral signals CEN, OEN, WEN
// data memory output signals  ReadDataMem
// program counter/address     PCin, PCnext, JumpAddr, BranchAddr
//=========================================================

module SingleCycle_MIPS( 
    clk,
    rst_n,
    IR_addr,
    IR,
    RF_writedata,
    ReadDataMem,
    CEN,
    WEN,
    A,
    ReadData2,
    OEN
);

//==== in/out declaration =================================
    //-------- processor ----------------------------------
    input         clk, rst_n;
    input  [31:0] IR;
    output [31:0] IR_addr ,RF_writedata;
    //-------- data memory --------------------------------
    input  [31:0] ReadDataMem;  // read_data from memory
    output        CEN;  // chip_enable, 0 when you read/write data from/to memory
    output        WEN;  // write_enable, 0 when you write data into SRAM & 1 when you read data from SRAM
    output [6:0] A;  // address
    output [31:0] ReadData2;  // write_data to memory
    output        OEN;  // output_enable, 0

//==== reg/wire declaration ===============================
wire [25:0] Inst_25_0;
wire [4:0] Inst_25_21;
wire [4:0] Inst_20_16;
wire [4:0] Inst_15_11;
wire [15:0] Inst_15_0;
wire [31:0] shamt; 
wire [31:0] pc; 
wire [5:0] opcode;
wire [5:0] func;
wire RegDST;
wire ALUSrc;
wire MemToReg;
wire RegWrite; 
wire MemRead;
wire MemWrite;
wire Jump;
wire branch;
wire ALUzero;
wire [3:0]  ALU_Control;
wire [1:0]  ALUOp;
wire [31:0] ALU_Result;
wire [31:0] ALU_datain2_src0;
wire [31:0] ALU_datain2;
wire [4:0]  r_wr_addr;
wire [4:0]  r_rd_addr1;
wire [4:0]  r_wr_addr0;
wire [31:0] r_wr_data;
wire [31:0] r_rd_data1;
wire [31:0] r_rd_data2;
wire [31:0] r_wr_data0;
wire [31:0] pc_plus_4;        //PC + 8 to be written to GPR[31] on JAL
wire _JAL;    //Set when Instruction is JAL
wire _JR;     //Set when Instruction is JR
wire [31:0] Inst_15_0_signext; 
wire [31:0] br_signext_sl2;

assign opcode = IR[31:26];
assign func  = IR[5:0];
assign Inst_25_0   = IR[25:0];
assign Inst_25_21  = IR[25:21];
assign Inst_20_16  = IR[20:16];
assign Inst_15_11  = IR[15:11];
assign Inst_15_0   = IR[15:0];
assign shamt       = {27'd0,IR[10:6]};
assign OEN = 0;
assign WEN = !MemWrite;
assign CEN = (!opcode)? 1:0;
assign ReadData2 = r_rd_data2;

//==== combinational part =================================
//PC
pc pc_0 ( .clk              (clk           ),
          .rst              (rst_n         ), 
          .br_signextend_sl2(br_signext_sl2), 
          .Inst_25_0        (Inst_25_0     ),
          .Jump             (Jump          ), 
          .branch           (branch        ),
          .ALUzero          (ALUzero       ),
          .pc               (pc            ),
          .pc_plus_4        (pc_plus_4     ),
          ._JR              (_JR           ),
          .r_rd_data1         (r_rd_data1    )
         );

//Control Unit
Control_Unit Control_Unit_0( .opcode     (opcode     ),
                             .func       (func       ),
                             .RegDST     (RegDST     ),
                             .ALUSrc     (ALUSrc     ),
                             .MemToReg   (MemToReg   ),
                             .RegWrite   (RegWrite   ),
                             .MemRead    (MemRead    ),
                             .MemWrite   (MemWrite   ),
                             .Jump       (Jump       ),
                             .Branch     (branch     ),
                             .ALUOp      (ALUOp      ),
                             ._JAL       (_JAL       ),
                             ._JR        (_JR        )
                            );
//Register
Register register_0(.clk      (clk         ),
                    .rst      (rst_n       ),
                    .RegWrite (RegWrite    ),
                    .Reg_R1   (Inst_25_21  ),
                    .Reg_R2   (Inst_20_16  ),
                    .Reg_W    (r_wr_addr  ),
                    .WriteData(r_wr_data   ),
                    .ReadData1(r_rd_data1  ),
                    .ReadData2(r_rd_data2  )
                    );
//ALU_Control
ALUControl ALUControl_0(.ALUctrl    (ALU_Control),
	                      .ALUOp      (ALUOp      ),
	                      .ALU_CtrlIn (func       )
                        );

//ALU
ALU ALU_0(.ALUin1    (r_rd_data1  ),
	        .ALUin2    (ALU_datain2 ),
	        .ALUctrl   (ALU_Control ),
	        .ALUresult (ALU_Result  ),
	        .ALUzero   (ALUzero     )
         );

//Sign_extend
signextend signextend_0(.in  (Inst_15_0        ),
                        .out (Inst_15_0_signext)
                       );

//shift_left_2
shift br_lshift_0(.in(Inst_15_0_signext),
                  .out(br_signext_sl2   )
                 );

//Multiplexer to select write address of Register
mux_5 MUX_RegDST(.in0(Inst_20_16),//5
               .in1(Inst_15_11),//5
               .out(r_wr_addr0),//5
               .sel(RegDST    )
              );
mux_5 MUX_RegDST_1(.in0(r_wr_addr0),//5
                 .in1(5'd31     ),//5
                 .out(r_wr_addr ),//5
                 .sel(_JAL      )
                );


//ALU operand source Mux
mux_32 MUX_Src(.in0(r_rd_data2       ),//32
            .in1(Inst_15_0_signext),//32
            .out(ALU_datain2      ),//32
            .sel(ALUSrc           )
           );

//Multiplexer to select write back to Register from ALU or MEM
mux_32 MUX_MemToReg(.in0(ALU_Result ),//32
                 .in1(ReadDataMem),//32
                 .out(r_wr_data0 ),//32
                 .sel(MemToReg   )
                );
//Multiplexer selects this data and JAL address(PC+8)
mux_32 MUX_MemToReg_1(.in0(r_wr_data0),//32
                   .in1(pc_plus_4 ),//32
                   .out(r_wr_data ),//32
                   .sel(_JAL      )
                  );


assign IR_addr = pc;
assign RF_writedata = r_wr_data;
assign A = ALU_Result[8:2];
//==== sequential part ====================================


//=========================================================
endmodule

//ALU_Control
module ALUControl(ALUctrl, ALUOp, ALU_CtrlIn); 
output reg[3:0] ALUctrl;  
input [1:0] ALUOp;  
input [5:0] ALU_CtrlIn;

always@(ALUOp or ALU_CtrlIn)begin
//$display("ALUOp =%d",ALUOp);
if(ALUOp != 2'b10)begin
case (ALUOp)
  2'b00 : ALUctrl = 4'b0010; //lw,sw
  2'b01 : ALUctrl = 4'b0110; //beq
    default: ALUctrl = 4'b1111;
endcase
//$display("ALUctrl =%d",ALUctrl);
end
else begin
//$display("ALU_CtrlIn =%h",ALU_CtrlIn);
//$display("ALU_CtrlIn =%d",ALU_CtrlIn);
case(ALU_CtrlIn)
    6'b100000 : ALUctrl = 4'b0010; //add
    6'b100010 : ALUctrl = 4'b0110; //subtract
    6'b100100 : ALUctrl = 4'b0000; //and
    6'b100101 : ALUctrl = 4'b0001; //or
    6'b101010 : ALUctrl = 4'b0111; //slt
    default: ALUctrl = 4'b1111;
endcase
//$display("ALUctrl =%d",ALUctrl);
end
end
endmodule

//ALU
module ALU(ALUresult, ALUzero, ALUin1, ALUin2, ALUctrl);
input [31:0] ALUin1,ALUin2;
input [3:0] ALUctrl;
output  ALUzero;
output reg[31:0] ALUresult;

always@(ALUin1 or ALUin2 or ALUctrl)begin
//$display("ALUctrl =%d",ALUctrl);
//$display("ALUin1=%d, ALUin2=%d, AlUctrl=%d",ALUin1,ALUin2,ALUctrl);
case (ALUctrl)
    4'b0010 : ALUresult = ALUin1 + ALUin2;
    4'b0110 : ALUresult = ALUin1 - ALUin2;
    4'b0000 : ALUresult = ALUin1 & ALUin2;
    4'b0001 : ALUresult = ALUin1 | ALUin2;
    4'b0111 : ALUresult = (ALUin1 < ALUin2) ? 1 : 0;
  default: ALUresult = 0;
endcase
//$display("ALUresult =%d",ALUresult);
end
assign ALUzero = (ALUctrl == 4'b0110 && ALUresult == 0) ? 1 : 0;


endmodule

//MUX for 32 bits
module mux_32(out, sel, in0, in1);
input [31:0] in0, in1;
input sel;
output reg[31:0] out;

always @(in0 or in1 or sel)begin
if (sel==1'b1) begin
   out = in1;
  end 
  else begin 
   out = in0;
  end
end

endmodule

//MUX for 5bits
module mux_5(out, sel, in0, in1);
input [4:0] in0, in1;
input sel;
output reg[4:0] out;

always @(in0 or in1 or sel)begin
if (sel==1'b1) begin
   out = in1;
  end 
  else begin 
   out = in0;
  end
end

endmodule

//Control Unit
module Control_Unit(opcode, func, RegDST, Jump, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite,_JAL,_JR);
input[5:0] opcode;
input[5:0] func;
output RegDST;  //Write Destination register location
output Jump;
output Branch; //1 when opcode is beq
output MemRead; //Read from Data memory
output MemToReg; //Send ALU(0)/Load memory(1) output to register
output reg[1:0] ALUOp; //Defines the ALU operation
output MemWrite; //Write to Data Memory
output ALUSrc; //2nd input to ALU; ALUSrc=0-> Read data 2; ALUSrc=1->Immediate 
output RegWrite;
output _JAL; 
output _JR;

`define ADD  6'b100000
`define SUB  6'b100010
`define AND  6'b100100 
`define OR   6'b100101 
`define BEQ  6'b000100
`define SLT  6'b101010
`define LW   6'b100011
`define SW   6'b101011

`define J    6'b000010
`define JAL  6'b000011
`define JR   6'b001000

assign RegDST    = (opcode==6'b0);
assign ALUSrc    = (opcode!=6'b0) && (opcode!=`BEQ);
assign MemToReg  = (opcode==`LW);
assign RegWrite  = (opcode!=`SW) && (opcode!=`BEQ) && (opcode!=`J) && (!((opcode==6'd0) &&  (func==`JR))); 
assign MemRead   = (opcode==`LW);
assign MemWrite  = (opcode==`SW) && (opcode !=`J) && (opcode !=`JAL);
assign Jump      = (opcode==`J) || (opcode== `JAL);
assign Branch    = (opcode==`BEQ);
assign _JAL      = (opcode==`JAL);
assign _JR       = (opcode==6'b0) && (func==`JR);

always@(*)begin
    if(opcode == 6'b0) ALUOp = 2'b10;
    else begin
        if(opcode!=`BEQ)ALUOp = 2'b00;
        else ALUOp = 2'b01;
    end
end


endmodule

//shifter
module shift(in, out);
input [31:0] in;
output [31:0] out;
reg [31:0] shift;

always@(in)begin
shift = in << 2;
end

assign out = shift;
endmodule

module Register(clk,rst,RegWrite, Reg_R1, Reg_R2, Reg_W, WriteData, ReadData1, ReadData2);
input clk;
input rst;
input RegWrite;
input  [4:0] Reg_R1;
input  [4:0] Reg_R2;
input  [4:0] Reg_W;
input  [31:0] WriteData;
output [31:0] ReadData1;
output [31:0] ReadData2;

reg[31:0] register[1:31];



always@(posedge clk or negedge rst) begin
if(rst == 1'b0)begin
register[1]=0;
register[2]=0;
register[3]=0;
register[4]=0;
register[5]=0;
register[6]=0;
register[7]=0;
register[8]=0;
register[9]=0;
register[10]=0;
register[11]=0;
register[12]=0;
register[13]=0;
register[14]=0;
register[15]=0;
register[16]=0;
register[17]=0;
register[18]=0;
register[19]=0;
register[20]=0;
register[21]=0;
register[22]=0;
register[23]=0;
register[24]=0;
register[25]=0;
register[26]=0;
register[27]=0;
register[28]=0;
register[29]=0;
register[30]=0;
register[31]=0;
end
else if((RegWrite==1'b1) && (Reg_W!=5'd0)) begin
    register[Reg_W] = WriteData;
  end
end



assign ReadData1 = (Reg_R1==5'd0) ? 32'd0 : register[Reg_R1];   
assign ReadData2 = (Reg_R2==5'd0) ? 32'd0 : register[Reg_R2];


endmodule

module pc(clk, rst, br_signextend_sl2, Inst_25_0, Jump, branch, ALUzero, pc, pc_plus_4,_JR,r_rd_data1);
input clk, rst;
input [31:0] br_signextend_sl2;
input [25:0] Inst_25_0;
input Jump;
input branch;
input ALUzero;
input _JR;
input[31:0] r_rd_data1;
output [31:0] pc;
output [31:0] pc_plus_4;

reg  [31:0] pc_val;
wire [31:0] br_loc, pc_plus_8;
wire branch_EN;

assign pc_plus_4 = pc_val + 32'd4;       
assign pc_plus_8 = pc_val + 32'd8;
assign branch_EN = branch & ALUzero;
assign br_loc = pc_plus_4 + br_signextend_sl2;
assign pc = pc_val;
assign Inst_25_21 = Inst_25_0[25:21];

always @ (posedge clk or negedge rst) 
begin 
  if (rst==1'b0) begin
    pc_val = 31'd0;
    //$display("pc = %d",pc);
  end 
 else if (Jump==1'b1) begin
    pc_val = {pc_plus_4[31:28],Inst_25_0,2'b00};
    //$display("pc_val=%d",pc_val);
  end 
  else if (branch_EN==1'b1) begin
    pc_val = br_loc;
  end
  else if(_JR==1'b1)begin
    pc_val = r_rd_data1;
  end
  else begin
    pc_val = pc_plus_4;
  end
end


endmodule

module signextend(in, out);

input [15:0] in;
output [31:0] out;
reg [31:0] ext;

always @(*) begin
 ext [15:0]  = in;
 ext [31:16] = {16{in[15]}};
end

assign out = ext;
endmodule

