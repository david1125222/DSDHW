`timescale 1ns/10ps
`define SDFFILE    "IG_syn.sdf"	  // Modify your sdf file name
`define CYCLE      10.0          	  // Modify your clock period here
`define End_CYCLE  100000000             // Modify cycle times once your design need more cycle times!

`define PAT   "./dat/image.dat"    
`define GRADEXP "./dat/gradient.dat"

module testfixture;

parameter N_PAT = 65536;

reg   [19:0]   exp_grad    [0:N_PAT];
initial	$readmemb (`GRADEXP, exp_grad);

`ifdef SDF
	initial $sdf_annotate(`SDFFILE, u_dut);
`endif

wire 	    done;
wire 	    img_wr;
wire 	    img_rd;
wire [15:0] img_addr;
wire [7:0]  img_do;
wire [7:0]  img_di;
wire 	    grad_wr;
wire 	    grad_rd;
wire [15:0] grad_addr;
wire [19:0] grad_do;
wire [19:0] grad_di;

integer		i, gx_err, gy_err;

reg	        grad_chk; 
reg	[19:0]	exp_pat, rel_pat;

reg		clk = 0;
reg		reset;


IG u_dut(.clk( clk ), .reset( reset ),
        .done( done ),
        .img_wr( img_wr ),
        .img_rd( img_rd ),
        .img_addr( img_addr ),
        .img_di( img_di ),
        .img_do( img_do ),
        .grad_wr( grad_wr ),
        .grad_rd( grad_rd ),
        .grad_addr( grad_addr ),
        .grad_do( grad_do ),
        .grad_di( grad_di ) );
			
img_RAM   u_img_RAM(.reset(reset), .rd(img_rd), .wr(gimg_wr), .addr(img_addr), .datain(img_do), .dataout(img_di), .clk(clk));   
grad_RAM  u_grad_RAM(.rd(grad_rd), .wr(grad_wr), .addr(grad_addr), .datain(grad_do), .dataout(grad_di), .clk(clk));   


always begin #(`CYCLE/2) clk = ~clk; end


initial begin
//	$fsdbDumpfile("IG.fsdb");
//	$fsdbDumpvars;
//  $fsdbDumpMDA(u_img_RAM.M);
//  $fsdbDumpMDA(u_grad_RAM.M);
    $dumpfile("IG.vcd");
    $dumpvars(0,testfixture); 
end

initial begin
	$display("-----------------------------------------------------\n");
 	$display("START!!! Simulation Start .....\n");
 	$display("-----------------------------------------------------\n");
    #1; reset = 1'b0; 
    @(negedge clk) #1; reset = 1'b1; 
    #(`CYCLE*3);    
    @(negedge clk) #1;  reset = 1'b0; 
end

initial begin
	#(`End_CYCLE);
	$display("-----------------------------------------------------\n");
	$display("      Error!!! Running out of time!                  \n");
	$display("      There is something wrong with your code!       \n");
 	$display("--------The test result is .....FAIL ----------------\n");
 	$display("-----------------------------------------------------\n");
 	$finish;
end


initial begin 
grad_chk = 0;
	#(`CYCLE*3);
	wait( done ) ;
	grad_chk = 1;
	gx_err = 0;
	gy_err = 0;
	for (i=0; i <N_PAT-256 ; i=i+1) begin
        if(i%256!=255) begin
            exp_pat = exp_grad[i]; 
            rel_pat = u_grad_RAM.M[i];
            if (exp_pat[19:10] == rel_pat[19:10])
                gx_err = gx_err;
            else begin 
                gx_err = gx_err+1;
                if (gx_err <= 50) $display(" Gradient x of pixel %d is wrong! Your gradient x is %h, but expected gradient x is %h", i, rel_pat[19:10], exp_pat[19:10]);
                if (gx_err + gy_err == 100) begin 
                    $display(" There are more than 100 errors!, Please check the code .....\n");
                end
            end

            if (exp_pat[9:0] == rel_pat[9:0])
                gy_err = gy_err;
            else begin 
                gy_err = gy_err+1;
                if (gy_err <= 50) $display(" Gradient y of pixel %d is wrong! Your gradient y is %h, but expected gradient y is %h", i, rel_pat[9:0], exp_pat[9:0]);
                if (gx_err + gy_err == 100) begin 
                    $display(" There are more than 100 errors!, Please check the code .....\n");
                end
            end
        end
        
        
        if( ((i%1000) == 999) || (i == 65536)) begin  
            if ( (gx_err == 0) && (gy_err == 0))
                $display(" Gradient of pixel: 0 ~ %d are correct!\n", i);
            else
                $display(" Gradient of Pixel: 0 ~ %d are wrong ! The wrong pixel reached a total of %d or more ! \n", i, gx_err+gy_err);
        end					
    end
end

initial begin
    @(posedge grad_chk)  #1;    
    if( gx_err == 0 && gy_err == 0 ) begin
        $display("=======================The test result is ..... PASS=========================");
        $display("\n");
        $display("        *************************************************              ");
        $display("        **                                             **      /|__/|");
        $display("        **             Congratulations !!              **     / O,O  \\");
        $display("        **                                             **    /_____   \\");
        $display("        **  All data have been generated successfully! **   /^ ^ ^ \\  |");
        $display("        **                                             **  |^ ^ ^ ^ |w|");
        $display("        *************************************************   \\m___m__|_|");
        $display("\n");
        $display("============================================================================");
        $finish;
    end
    else begin
        $display("------------------------------------------------------------\n");
	    $display("    FAIL! There are %d errors at functional simulation !    \n", gx_err+gy_err);
	    $display("---------- The test result is ..... FAIL -------------------\n");
    end
    #(`CYCLE/3); $finish;
end
   
endmodule


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
module img_ROM (sti_rd, sti_data, sti_addr, clk, reset);
input		sti_rd;
input	[9:0] 	sti_addr;
output	[15:0]	sti_data;
input		clk, reset;

reg [15:0] sti_M [0:1023];
integer i;

reg	[15:0]	sti_data;



always@(negedge clk) 
	if (sti_rd) sti_data <= sti_M[sti_addr];
	
endmodule



//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
module img_RAM (reset, rd, wr, addr, datain, dataout, clk);
    input           reset, rd, wr;
    input  [15:0]   addr;
    input  [7:0]    datain;
    output [7:0]    dataout;
    input           clk;
    
    reg [7:0] M [0:65535];
    
    integer i;
    
    initial begin
        @ (negedge reset) $readmemh (`PAT , M);
    end
    
    reg [7:0] dataout;
    
    always@(negedge clk)   // read data at negedge clock
        if (rd) dataout <= M[addr];
    
    always@(posedge clk)   // write data at posedge clock
        if (wr) M[addr] <= datain;
    
endmodule

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

module grad_RAM (rd, wr, addr, datain, dataout, clk);
    input           rd, wr;
    input  [15:0]   addr;
    input  [19:0]    datain;
    output [19:0]    dataout;
    input           clk;
    
    reg [19:0] M [0:65535];
    
    integer i;
    
    initial for(i=0;i<=65535;i=i+1) M[i] = 20'h0;
    
    reg [19:0] dataout;
    
    always@(negedge clk)   // read data at negedge clock
        if (rd) dataout <= M[addr];
    
    always@(posedge clk)   // write data at posedge clock
        if (wr) M[addr] <= datain;
    
endmodule



