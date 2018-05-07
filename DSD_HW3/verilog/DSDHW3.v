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
    output [31:0] IR_addr, RF_writedata;
    //-------- data memory --------------------------------
    input  [31:0] ReadDataMem;  // read_data from memory
    output        CEN;  // chip_enable, 0 when you read/write data from/to memory
    output        WEN;  // write_enable, 0 when you write data into SRAM & 1 when you read data from SRAM
    output  [6:0] A;  // address
    output [31:0] ReadData2;  // write_data to memory
    output        OEN;  // output_enable, 0

//==== reg/wire declaration ===============================
    wire [25:0] Inst_25_0;
    wire [4:0] Inst_25_21;
    wire [4:0] Inst_20_16;
    wire [4:0] Inst_15_11;
    wire [15:0] Inst_15_0;
    //wire [31:0] shamt; //Shift Amount for SLL and SRL??
    wire [31:0] pc;        //Program Counter
    wire [5:0] opcode;
    wire [5:0] funct;
    //wire bcond;
    wire RegDst;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite; 
    wire MemRead;
    wire MemWrite;
    wire Jump;
    wire ALUOp;
    wire Branch;
    //wire PCSrc1;
    wire zero;
    //wire PCSrc2;
    wire [3:0] ALU_control;
    wire [31:0] ALU_Result;
    wire [31:0] ALU_data1;
    wire [31:0] ALU_data2;
    wire [4:0] register_rd_addr1;
    wire [4:0] register_rd_addr2;
    wire [4:0] register_wr_addr;
    wire [31:0] register_wr_data;
    wire [31:0] register_rd_data1;
    wire [31:0] register_rd_data2;
    wire [31:0] Add_result;
    wire [31:0] mem_alu_data_out;
    wire [31:0] pc_plus_4;        //PC + 8 to be written to GPR[31] on JAL
    //wire isJAL;    //Set when Instruction is JAL
    //wire isSLL_SRL;//Set when Instruction is SLL or SRL
    wire [31:0] Inst_15_0_sign_extend,Inst_15_0_sign_extend_shift_2; 
    wire [31:0] br_signext_sl2;
    wire [31:0] JumpAddr;
    wire [31:0] Mux_sel_a,Mux_out_a;

    assign opcode = IR[31:26];
    assign Inst_5_0  = IR[5:0];
    assign Inst_25_0   = IR[25:0];
    assign Inst_25_21  = IR[25:21];
    assign Inst_20_16  = IR[20:16];
    assign Inst_15_11  = IR[15:11];
    assign Inst_15_0   = IR[15:0];
    assign Inst_15_0_sign_extend_shift_2 = Inst_15_0_sign_extend<<2;
    assign Mux_sel_a = Branch & zero;
    assign WEN =   (~MemWrite) | MemRead;
    assign CEN = MemRead | MemWrite;
    assign OEN = 0;
    assign A = ALU_data2;
    assign ReadData2=register_rd_data2;
    assign IR_addr=pc;
    assign RF_writedata=register_wr_data;
    always@(posedge clk)begin
        $display("PC=%h,IR_addr=%h,pc_plus_4=%h,Mux_out_a=%h,PCnext=%h",pc,IR_addr,pc_plus_4,Mux_out_a,PCnext);
    end

SignExtend SignExtend_0(Inst_15_0,Inst_15_0_sign_extend);

Alu_control Alu_control_0(
    .instruction_5_0(Inst_5_0),
    .ALUOp(ALUOp),
    .Alu_control(Alu_control)
);

Registers Registers_0(
    .clk(clk),
    .rst_n(rst_n),
    .RegWrite(RegWrite),
    .read_register_1(register_rd_addr1),
    .read_register_2(register_rd_addr2),
    .write_register(register_wr_addr),
    .write_data(register_wr_data),
    .read_data_1(register_rd_data1),
    .read_data_2(register_rd_data2)
);
   
Alu Alu_0(
    .alu_data1(ALU_data1),
    .alu_data2(ALU_data2),
    .alu_ctrl(Alu_control),
    .zero(zero),
    .alu_result(ALU_Result)
);

Add_4 Add_4_0(
    .add_in(pc),
    .add_out(pc_plus_4)
);

Control Control_0(
    .instruction(opcode),
    .RegDst(RegDst),
    .Jump(Jump),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemToReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
);

Add Add_0(
    .add_in1(pc_plus_4),
    .add_in2(Inst_15_0_sign_extend_shift_2),
    .add_out(Add_result)
);

mux_2x1 mux_2x1_a(
    .ip1(Add_result), 
    .ip0(pc_plus_4), 
    .sel(Mux_sel_a), 
    .out(Mux_out_a)
);

mux_2x1 mux_2x1_b(
    .ip1(JumpAddr), 
    .ip0(Mux_out_a), 
    .sel(Jump), 
    .out(PCnext)
);

mux_2x1 mux_2x1_c(
    .ip1(ReadDataMem), 
    .ip0(ALU_Result), 
    .sel(Jump), 
    .out(register_wr_data)
);

mux_2x1 mux_2x1_d(
    .ip1(Inst_15_11), 
    .ip0(Inst_20_16), 
    .sel(RegDst), 
    .out(register_wr_addr)
);

PC PC_0(
    .clk(clk),
    .rst_n(rst_n),
    .PCin(PCnext),
    .PCnext(pc)
);
//==== combinational part =================================


//==== sequential part ====================================


//=========================================================
endmodule

module Registers(
    clk,
    rst_n,
    RegWrite,
    read_register_1,
    read_register_2,
    write_register,
    write_data,
    read_data_1,
    read_data_2
);
    input RegWrite;
    input clk,rst_n;
    input [4:0] read_register_1,read_register_2,write_register;
    input [31:0] write_data;
    output [31:0] read_data_1,read_data_2;
    reg [31:0] read_data_1_reg,read_data_2_reg;
    reg [31:0] register_file [4:0];

    always@(posedge clk)  
    begin 
        read_data_1_reg<=register_file[read_register_1];
        read_data_2_reg<=register_file[read_register_2];
        if(RegWrite) begin
            register_file[write_register]<=write_data;
        end
    end

    always@(negedge rst_n)
    begin
            register_file[0]<=32'b0;
            register_file[1]<=32'b0;
            register_file[2]<=32'b0;
            register_file[3]<=32'b0;
            register_file[4]<=32'b0;
            register_file[5]<=32'b0;
            register_file[6]<=32'b0;
            register_file[7]<=32'b0;
            register_file[8]<=32'b0;
            register_file[9]<=32'b0;
            register_file[10]<=32'b0;
            register_file[11]<=32'b0;
            register_file[12]<=32'b0;
            register_file[13]<=32'b0;
            register_file[14]<=32'b0;
            register_file[15]<=32'b0;
            register_file[16]<=32'b0;
            register_file[17]<=32'b0;
            register_file[18]<=32'b0;
            register_file[19]<=32'b0;
            register_file[20]<=32'b0;
            register_file[21]<=32'b0;
            register_file[22]<=32'b0;
            register_file[23]<=32'b0;
            register_file[24]<=32'b0;
            register_file[25]<=32'b0;
            register_file[26]<=32'b0;
            register_file[27]<=32'b0;
            register_file[28]<=32'b0;
            register_file[29]<=32'b0;
            register_file[30]<=32'b0;
            register_file[31]<=32'b0;
    end



endmodule



module Add_4(
    add_in,
    add_out
);
    input [31:0] add_in;
    output [31:0] add_out;
    reg [31:0] add_value;
    
    assign add_out=add_value;
    
    
    always@(*)
    begin
        add_value=add_in+4;
    end

endmodule

module Add(
    add_in1,
    add_in2,
    add_out
);
    input [31:0] add_in1,add_in2;
    output [31:0] add_out;
    reg [31:0] add_value;
    
    assign add_out=add_value;
    
    
    always@(*)
    begin
        add_value=add_in1+add_in2;
    end

endmodule



module Control(
    instruction,
    RegDst,
    Jump,
    Branch,
    MemRead,
    MemToReg,
    ALUOp,
    MemWrite,
    ALUSrc,
    RegWrite
);

input [5:0] instruction;
output RegDst,Jump,Branch,MemRead,MemToReg,MemWrite,ALUSrc,RegWrite;
output [1:0] ALUOp;
reg RegDst_reg,Jump_reg,Branch_reg,MemRead_reg,MemToReg_reg,MemWrite_reg,ALUSrc_reg,RegWrite_reg;
reg ALUOp_reg[1:0];

`define BEQ  6'b000100
`define LB   6'b100000
`define LW   6'b100011
`define SB   6'b101000
`define SW   6'b101011
`define JR   6'b001000
`define J    6'b000010
`define JAL  6'b000011

assign RegDst= (instruction==6'b0);
assign Jump=(instruction==`J)   || (instruction==`JAL);
assign Branch=(instruction==`BEQ);
assign MemRead=(instruction==`LW)  || (instruction==`LB);
assign MemToReg=(instruction==`LW) || (instruction==`LB);
assign MemWrite=(instruction==`SW)  || (instruction==`SB);
assign ALUSrc=(instruction!=6'b0)&& (instruction!=`BEQ);
assign RegWrite=(instruction!=`SW)   &&  (instruction!=`SB)  &&  (instruction!=`BEQ)  && (instruction!=`J)    &&  (!((instruction==6'd0) ));
assign ALUOp[1]=(instruction==6'b0);
assign ALUOp[0]=(instruction==`BEQ);



endmodule

module Alu(
    alu_data1,
    alu_data2,
    alu_ctrl,
    zero,
    alu_result
);

    input [31:0] alu_data1,alu_data2;
    input [3:0] alu_ctrl;
    output zero;
    output [31:0] alu_result;
    reg [31:0] result;

    always@(*)  
    begin  
        case (alu_ctrl)  
            4'b0010: result = alu_data1+alu_data2;
            4'b0110: result = alu_data1-alu_data2;
            4'b0000: result = alu_data1 & alu_data2;
            4'b0001: result = alu_data1 | alu_data2;
            4'b0111: begin
                if(alu_data1<alu_data2) 
                    result=1;
                else
                    result=0;
            end
            default: result=0;
        endcase
    end

    assign alu_result=result;
endmodule

module Alu_control(
    instruction_5_0,
    ALUOp,
    Alu_control
);

    input [5:0] instruction_5_0;
    input [1:0] ALUOp;
    output Alu_control;
    reg Alu_control_reg;

    assign Alu_control=Alu_control_reg;

    always@(*)  
    begin  
        case (ALUOp)
            2'b00: Alu_control_reg=0010;
            2'b01: Alu_control_reg=0110;
            2'b10: begin
                case(instruction_5_0)
                    6'b100000:Alu_control_reg=0010;
                    6'b100010:Alu_control_reg=0110;
                    6'b100100:Alu_control_reg=0000;
                    6'b100101:Alu_control_reg=0001; //or
                    6'b101010:Alu_control_reg=0111;
                    default: Alu_control_reg=0010;
                endcase
                end
            default: Alu_control_reg=0010;
        endcase
    end
endmodule

module PC(
    clk,
    rst_n,
    PCin,
    PCnext
);
    reg [31:0] PC_value;
    input clk,rst_n;
    input [31:0] PCin;
    output [31:0] PCnext;
    assign PCnext=PC_value;

    always@(negedge rst_n)
    begin
        PC_value<=31'b0;
    end
    always@(posedge clk)
    begin
        PC_value<=PCin;
    end

endmodule

module SignExtend(
    instruction,
    instruction_out
);
    input [15:0] instruction;
    output [31:0] instruction_out;
    reg [31:0] instruction_value;
    always@(*)
    begin
        instruction_value[15:0] <= { {16{instruction[15]}}, instruction[15:0]};
    end
endmodule

module mux_2x1 (
    ip1, 
    ip0, 
    sel, 
    out
);

input [31:0] ip1;
input [31:0] ip0;
input sel;
output reg [31:0] out;

always@(*) begin
  if (sel==1'b1) begin
   out = ip1;
  end 
  else begin 
   out = ip0;
  end
end

endmodule

module mux_2x1_5bit (
    ip1, 
    ip0, 
    sel, 
    out
);

input [4:0] ip1;
input [4:0] ip0;
input sel;
output reg [4:0] out;

always@(*) begin
  if (sel==1'b1) begin
   out = ip1;
  end 
  else begin 
   out = ip0;
  end
end

endmodule