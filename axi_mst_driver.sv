`include "macro.vh"
module axi_mst_driver #(
    parameter AXI_ADDR_W = 32,
    //主机输入ID宽度
    parameter AXI_ID_W  =4,
    parameter AXI_DATA_W = 32,

    //OSTD REQ NUM
    parameter MST_OSTDREQ_NUM = 4,//2**n!!!!
    //The data size of each OSTD REG
    parameter MST_OSTDREQ_SIZE = 8,

    parameter AWCH_W = 53,
    parameter WCH_W  = 47, 
    parameter BCH_W  = 12,
    parameter ARCH_W = 53,
    parameter RCH_W  = 45
    
    // ,
    
    // parameter [AXI_ID_W - 1 : 0] MST_ID_MASK = 'b0100
    )(
    input  logic  aclk,
    input  logic  aresetn,
    input  logic  srst,
    //interface from mst
    //aw channel
    input  logic  in_awvalid,
    input logic in_awready,
    // output  logic  [AXI_ADDR_W - 1 : 0] out_awaddr,
    input  logic  [8          - 1 : 0] in_awlen_real,
    output logic  [8          - 1 : 0] awlen,
    input  logic  [AXI_ID_W   - 1 : 0] in_awid,//高两位为主机掩码：1,2,3；低两位为读写id，0,1,2,3，支持outstanding的能力为4
    // output  logic  [2          - 1 : 0] out_awlock,
    //w channel
    output  logic  out_wvalid,
    input   logic  in_wready,
    output  logic  out_wlast,
    output  logic  [AXI_ID_W   - 1 : 0] out_wid,
    output  logic  [AXI_DATA_W - 1 : 0] out_wdata,
    output  logic  [4          - 1 : 0] out_wstrb,
    input  logic  narrow,
    //B channel
    // input logic in_bvalid,
    output  logic  out_bready,
    // ,
    // input logic [AXI_ID_W   - 1 : 0] in_bid,
    // input logic [2          - 1 : 0] in_bresp,
    // AR channel
    // output  logic  out_arvalid,
    // input logic out_arready,
    // output  logic  [AXI_ADDR_W - 1 : 0] out_araddr,
    // output  logic  [4          - 1 : 0] out_arlen,
    // output  logic  [3          - 1 : 0] out_arsize,
    // output  logic  [2          - 1 : 0] out_arburst,
    // output  logic  [AXI_ID_W   - 1 : 0] out_arid,
    // output  logic  [2          - 1 : 0] out_arlock,
    // //R channel
    // input logic out_rvalid,
    output  logic  out_rready
    // input logic [AXI_ID_W   - 1 : 0] out_rid,
    // input logic [2          - 1 : 0] out_rresp,
    // input logic [AXI_DATA_W - 1 : 0] out_rdata,
    // input logic out_rlast
    );
//vari def>>>
//counter 
    logic [2**4-1:0]                    wdata_cnt;//fixme!!!!!!
    logic [$clog2(MST_OSTDREQ_NUM)+1-1:0]req_remain_cnt;
    logic [$clog2(MST_OSTDREQ_NUM)-1:0] awlen_rd_ptr;
    logic [$clog2(MST_OSTDREQ_NUM)-1:0] awlen_wr_ptr;
    logic [$clog2(MST_OSTDREQ_NUM)-1:0] awid_rd_ptr;
    logic [$clog2(MST_OSTDREQ_NUM)-1:0] awid_wr_ptr;

    

//reg
    logic [256          - 1 : 0] awlen_now;
    logic [4          - 1 : 0] awid_now;
    logic   out_wlast_prev;
    logic   out_wvalid_prev;
    logic [32          - 1 : 0]  wstrb32;
// //queue 
//     queue [4-1:0]awlen_que[$];

//distributed ram

    logic  [256 -1:0]awlen_ram[MST_OSTDREQ_NUM-1:0];
    logic  [4-1:0]awid_ram[MST_OSTDREQ_NUM-1:0];
    //<<<


//comb>>>

    assign awlen_now=awlen_ram[awlen_rd_ptr];
    assign awid_now=awid_ram[awid_rd_ptr];
    assign awlen= (in_awlen_real > 15)?15 :in_awlen_real;
    //<<<
//sequential>>>

//counter>>>


always_ff @( posedge aclk or negedge aresetn) begin : __req_remain_cnt
    if(!aresetn)
        req_remain_cnt<=0;
    else if(in_awvalid && in_awready && out_wlast)
        req_remain_cnt<=req_remain_cnt;
    else if(in_awvalid && in_awready)
        req_remain_cnt<=req_remain_cnt+1;
    else if(out_wlast && out_wvalid && in_wready)
        req_remain_cnt<=req_remain_cnt-1; 
    
end

always_ff @( posedge aclk or negedge aresetn) begin : __wdata_cnt
    if(!aresetn)
        wdata_cnt<=0;
    else if(out_wlast && out_wvalid && in_wready)
        wdata_cnt<=0;
    else if(out_wvalid && in_wready)
        wdata_cnt<=wdata_cnt+1;
    
end
//<<<
//reg
always_ff @( posedge aclk or negedge aresetn) begin : __wvalid_prev
    if(!aresetn)
        out_wvalid_prev<=0;
    else 
        out_wvalid_prev<=out_wvalid;
    end

always_ff @( posedge aclk or negedge aresetn) begin : __wlast_prev
    if(!aresetn)
        out_wlast_prev<=0;
    else 
        out_wlast_prev<=out_wlast;
    end
    //<<<
  
//ram

    //len id    
always_ff @( posedge aclk or negedge aresetn) begin : __awlen_rd_ptr
    if(!aresetn)
        awlen_rd_ptr <= 'b0;
    else if(out_wlast && out_wvalid && in_wready)
        awlen_rd_ptr <= awlen_rd_ptr+1;
    end

always_ff @( posedge aclk or negedge aresetn) begin : __awlen_wr_ptr
    if(!aresetn)
        awlen_wr_ptr <= 'b0;
    else if(in_awvalid && in_awready)
        awlen_wr_ptr <= awlen_wr_ptr+1;
    end

always_ff @( posedge aclk or negedge aresetn) begin : __awlen_ram
    if(!aresetn)
    for (integer i = 0; i < MST_OSTDREQ_NUM; i = i + 1) begin
        awlen_ram[i] <= 'b0;
      end
    else if(in_awvalid && in_awready)
        awlen_ram[awlen_wr_ptr]<= in_awlen_real;
    end
    
always_ff @( posedge aclk or negedge aresetn) begin : __awid_rd_ptr
    if(!aresetn)
        awid_rd_ptr <= 'b0;
    else if(out_wlast)
        awid_rd_ptr <= awlen_rd_ptr+1;
    end

always_ff @( posedge aclk or negedge aresetn) begin : __awid_wr_ptr
    if(!aresetn)
        awid_wr_ptr <= 'b0;
    else if(in_awvalid && in_awready)
        awid_wr_ptr <= awlen_wr_ptr+1;
    end

always_ff @( posedge aclk or negedge aresetn) begin : __awid_ram
    if(!aresetn)
    for (integer i = 0; i < MST_OSTDREQ_NUM; i = i + 1) begin
        awid_ram[i] <= 'b0;
        end
    else if(in_awvalid && in_awready)
        awid_ram[awlen_wr_ptr]<= in_awid;
    end
 

//output:>>>
assign out_wvalid= (req_remain_cnt!=0);
assign out_wlast= (wdata_cnt==awlen_now) && out_wvalid;
assign out_wid=awid_now;//!!!!fixme !!!!未考虑交织！！！！
always @( posedge aclk or negedge aresetn) begin : __wdata//!!!fix me!!!can't syn 考虑prbs
    if(!aresetn)
        out_wdata=#1 'b0;
    else if(out_wvalid && in_wready)
        out_wdata=#1 narrow? $random & wstrb32 :$random ;    
end
always_ff @( posedge aclk or negedge aresetn) begin : __out_bready
    if(!aresetn)
        out_bready <= 'b0;
    else 
        out_bready<= $random;//!!!!fixme !!!!完全随机！！！！
    end

    always_ff @( posedge aclk or negedge aresetn) begin : __out_rready
        if(!aresetn)
            out_rready <= 'b0;
        else 
            out_rready<= $random;//!!!!fixme !!!!完全随机！！！！
        end
always_comb begin : __out_wstrb
    if(out_wvalid)
    begin
        if(narrow)
        begin
            out_wstrb='b0;
            out_wstrb[wdata_cnt%4]=1;
        end
        else 
            out_wstrb={4{1'b1}};
    end
    else
        out_wstrb='b0;
end
assign wstrb32={{8{out_wstrb[3]}},{8{out_wstrb[2]}},{8{out_wstrb[1]}},{8{out_wstrb[0]}}};
//<<<



endmodule