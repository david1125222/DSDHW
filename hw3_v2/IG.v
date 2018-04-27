module IG ( clk , reset, done, img_wr, img_rd, img_addr, img_di, img_do, 
            grad_wr, grad_rd, grad_addr, grad_do, grad_di);

input clk, reset;
input [7:0] img_di;
input [19:0] grad_di;
output done, img_wr, img_rd, grad_wr, grad_rd;
output [15:0] img_addr, grad_addr;
output [7:0] img_do;
output [19:0] grad_do;

//------------------------------------------------------------------
// reg & wire
reg [15:0] counter,counter_1, counter_256;

reg [7:0] x_1, x_2, x_3;
wire [19:0] grad;
reg ctrl;
reg cal;
reg rd,wr,init;
reg [15:0] img_addr_reg,grad_addr_reg;
reg done_reg;
wire signed[9:0] gx, gy;




//------------------------------------------------------------------
// combinational part
assign img_rd=rd;
assign grad_wr=wr;
assign img_addr=img_addr_reg;
assign grad_addr=grad_addr_reg;
assign done=done_reg;

assign gx = x_2-x_1;
assign gy = x_3-x_1;
assign grad = {gx,gy};
assign grad_do=grad;
//reset
always@(negedge reset) begin
    cal = 1'b0;
    ctrl=1'b0;
    done_reg=1'b0;
    counter=16'h0000;

end
//------------------------------------------------------------------
// sequential part
always@(negedge reset) begin
    rd<=1'b1;
    init<=1'b1;
end
//initial
always@(posedge clk) begin

        if(init) begin
            if(counter<3) begin
                img_addr_reg<=counter;
                counter<=counter+1;
                case (counter)
                    16'h0001:img_addr_reg<=0;
                    16'h0002:img_addr_reg<=1;
                    16'h0003:img_addr_reg<=256;
                default:  img_addr_reg<= 0;
                endcase
            end
            else begin
                counter<=0;
                init<=1'b0;
            end
        end
        else begin
            if(counter<65279) begin
                if(cal) begin
                    img_addr_reg<=counter+1;
                    counter<=counter+1;
                    cal<=0;
                end
                else begin
                    img_addr_reg<=counter+256;
                    cal<=1;
                end
            end
            else begin
                done_reg=1'b1;
            end
        end
end

always@(negedge clk) begin

        if(init) begin
            if(counter<2) begin
                case (counter)
                    16'h0001:x_1=img_di;
                    16'h0002:x_2=img_di;

                endcase
            end
            else if(counter == 3) begin
                x_3=img_di;
                grad_addr_reg=0;           
            end
            else begin
                counter<=0;
                init<=1'b0;
            end
        end
        else begin
            if(counter<65279) begin
                if(cal) begin
                    x_2=img_di;
                    wr=1'b1;
                    grad_addr_reg=counter-1;
                end
                else begin
                    x_3=img_di;
                    x_1=x_2;
                    wr=1'b0;
                end
            end
        end       


end


endmodule

