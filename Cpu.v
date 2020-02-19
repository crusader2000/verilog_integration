`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

`ifdef BSV_ASYNC_RESET
 `define BSV_ARESET_EDGE_META or `BSV_RESET_EDGE RST
`else
 `define BSV_ARESET_EDGE_META
`endif

`ifdef BSV_RESET_FIFO_HEAD
 `define BSV_ARESET_EDGE_HEAD `BSV_ARESET_EDGE_META
`else
 `define BSV_ARESET_EDGE_HEAD
`endif
module mkCpu(put_datas,clk,reset,get,RDY_get,EN_get,RDY_put,EN_put);
input clk;
input reset;
input EN_get;
input EN_put;
(*keep = "True"*)input [31:0] put_datas;

output wire RDY_get;
output wire RDY_put;

output [31:0] get;
wire [31:0] get;

reg [5:0] cnt_in;
reg [31:0] in_arr [5:0];
reg [31:0] out_arr [5:0];
reg [5:0] cnt_out;
reg [31:0] out;
reg out_ready;
reg [2:0] next_state;
reg [2:0] state;

localparam Accumulate = 0;
localparam Compute = 1;
localparam Flush = 2;
`ifdef BSV_NO_INITIAL_BLOCKS
`else // not BSV_NO_INITIAL_BLOCKS
   // synopsys translate_off
   initial
     begin
        // data0_reg   = {((width + 1)/2) {2'b10}} ;
        // data1_reg  = {((width + 1)/2) {2'b10}} ;
        // empty_reg = 1'b0;
        // full_reg  = 1'b1;
        cnt_in<= 1'b0;
        out<=0;
        out_ready<=1'b0;

     end // initial begin
   // synopsys translate_on
`endif
always @(posedge clk `BSV_ARESET_EDGE_META)begin
if (reset == `BSV_RESET_VALUE)
        begin
           // empty_reg <= `BSV_ASSIGNMENT_DELAY 1'b0;
           // full_reg  <= `BSV_ASSIGNMENT_DELAY 1'b1;
           cnt_in<=`BSV_ASSIGNMENT_DELAY 1'b0;
           cnt_out<=`BSV_ASSIGNMENT_DELAY 1'b0;
           // out_arr[0]<=0;
           // out_arr[1]<=0;
           // out_arr[2]<=0;
           // out_arr[3]<=0;
           // out_arr[4]<=0;
           // out_arr[5]<=0;
           // in_arr[0]<=0;
           // in_arr[1]<=0;
           // in_arr[2]<=0;
           // in_arr[3]<=0;
           // in_arr[4]<=0;
           // in_arr[5]<=0;
           out<=`BSV_ASSIGNMENT_DELAY 32'b0;
           out_ready<=`BSV_ASSIGNMENT_DELAY 1'b0;
           state<=Accumulate;
           next_state<=Accumulate;
        end // if (RST == `BSV_RESET_VALUE)

  // if(!reset)begin
  //   cnt_in<=0;
  //   cnt_out<=0;
  //   out_arr[0]<=0;
  //   out_arr[1]<=0;
  //   out_arr[2]<=0;
  //   out_arr[3]<=0;
  //   out_arr[4]<=0;
  //   out_arr[5]<=0;
  //   in_arr[0]<=0;
  //   in_arr[1]<=0;
  //   in_arr[2]<=0;
  //   in_arr[3]<=0;
  //   in_arr[4]<=0;
  //   in_arr[5]<=0;
  //   out<=0;
  //   out_ready<=0;
  //   state<=Accumulate;
  //   next_state<=Accumulate;
  //
  // end
  else begin
    state <= next_state;
  end
end
always@(*)begin
  if(!reset) begin

  end
  else begin
  // next_state=state;
  case(state)
        Accumulate:
            begin
                if(EN_put && RDY_put && cnt_in<5)begin
                    next_state=Accumulate;
                end
                else if(cnt_in==5)begin
                    next_state=Compute;
                end
            end
        Compute:
            begin
                next_state=Flush;
            end

        Flush:
          begin
              if(EN_get && cnt_out<6)begin
                  next_state=Flush;
              end
              if(EN_get && cnt_out==6) begin
                  next_state=Accumulate;
              end
          end
      endcase
    end
  end
always @(posedge clk)begin
case(state)
    Accumulate:
     begin
        if(EN_put && RDY_put && cnt_in<6)begin
            cnt_in<=cnt_in+1;
            in_arr[cnt_in]<=put_datas;
        end
     end
    Compute:
        begin
            out_arr[0]<=in_arr[0]+10;
            out_arr[1]<=in_arr[1]+10;
            out_arr[2]<=in_arr[2]+10;
            out_arr[3]<=in_arr[3]+10;
            out_arr[4]<=in_arr[4]+10;
            out_arr[5]<=in_arr[5]+10;
        end
    Flush:
        begin
            //if(EN_get && cnt_out<5)begin
              out<=out_arr[cnt_out];
              if(cnt_out==5)
                out_ready<=0;
              else if(cnt_out<5)begin
                out_ready<=1;
                cnt_out<=cnt_out+1;
              end

           //end
        end
  endcase
end

assign RDY_put = 1;//(cnt_in<6)?1:0;
assign RDY_get = out_ready;
assign get = out;

endmodule
