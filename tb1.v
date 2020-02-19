module tb1;
reg clk;
reg reset;
reg [31:0] in;
wire [31:0] out;
reg EN_get;
reg EN_put;
wire RDY_get;
wire RDY_put;
reg [31:0] out_reg;
reg temp_EN_get;
//--------------- dump -----------------------
// initial begin
//     $dumpfile("dumpVCD.vcd");
//     $dumpvars(10);
// end
initial begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    forever    begin
        #5 clk= ~clk;
    end
end
initial begin
  // reset=0;
  // #5 reset =1;
  // EN_get =1;
  #1000;
  $finish;
end
initial begin
  $dumpfile("testCpu.vcd");
  $dumpvars(0,tb1);
end
mkHardware DUTT(.put_datas(in),.CLK(clk),.RST_N(reset),.get(out),.EN_get(EN_get),.EN_put(EN_put),.RDY_get(RDY_get),.RDY_put(RDY_put));

// -- Transmitter Side -- //
reg [3:0] addr;
always @(posedge clk) begin: sender
    if (!reset)begin
        addr <= 0;
        in<=0;
    end else if(reset==1)begin
        if (addr < 6) begin
            if (EN_put && RDY_put) begin
                addr <= addr + 1;
                in<=in+4;
            end
    end
    end
end

always@(*)
begin
EN_put = reset && (addr < 6) ;//? 1'b1 : 1'b0
end
// assign in_bit = in_bits_vec[addr];

//-- Receiver Side -- //


always @(posedge clk) begin: receiver
    if (!reset) begin
        temp_EN_get <= 0;
    end
    else if(reset)begin
        temp_EN_get <= $urandom_range(0, 1); // some randomness on the receiver, otherwise, we won't see if our DUT behaves correctly in case of ready=0
        // out_reg <= out;
        // $display("random output    **************  %d",$urandom_range(0, 1));

    end
end
always@(*)
begin
EN_get = RDY_get;
end
always @(posedge clk) begin
if(EN_get && RDY_get)
  $display("out %d",out);

end
//---------------clock generator-----------------------
reg [3:0] cnt;
initial cnt=0;
always @(posedge clk)begin
    if (cnt<5) begin
        reset= 0;
        cnt=cnt+1;
    end else  reset=1;
end

// ----------- reset logic -----------//



endmodule
