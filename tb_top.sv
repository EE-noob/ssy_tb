`include "macro.vh"
//111112
module tb_top();

//localparam >>>

localparam clk_period=20 ;
localparam testnum =4 ;
//localpara half_clk_period=2.5 ;
//<<<
// Parameters>>>

parameter AXI_ID_W   = 4;
parameter AXI_DATA_W = 32;
parameter AXI_ADDR_W = 32;

parameter MST_NB     = 3;
parameter SLV_NB     = 3;

parameter MST_PIPELINE = 1;
parameter SLV_PIPELINE = 1;

//Master0 Configuration
parameter MST0_OSTDREQ_NUM = 4;
parameter MST0_OSTDREQ_SIZE = 8;
parameter MST0_PRIORITY = 0;
parameter [SLV_NB-1:0] MST0_ROUTES = 3'b1_1_1;
parameter [AXI_ID_W-1:0] MST0_ID_MASK = 4'b01_00;

//Master1 Configuration
parameter MST1_OSTDREQ_NUM = 4;
parameter MST1_OSTDREQ_SIZE = 8;
parameter MST1_PRIORITY = 0;
parameter [SLV_NB-1:0] MST1_ROUTES = 3'b1_1_1;
parameter [AXI_ID_W-1:0] MST1_ID_MASK = 4'b10_00;

//Master2 Configuration
parameter MST2_OSTDREQ_NUM = 4;
parameter MST2_OSTDREQ_SIZE = 8;
parameter MST2_PRIORITY = 0;
parameter [SLV_NB-1:0] MST2_ROUTES = 3'b1_1_1;
parameter [AXI_ID_W-1:0] MST2_ID_MASK = 4'b11_00;

//SLV0 Configuration
parameter SLV0_START_ADDR = 0;
parameter SLV0_END_ADDR = 4095;
parameter SLV0_OSTDREQ_NUM = 4;
parameter SLV0_OSTDREQ_SIZE = 8;
parameter SLV0_PRIORITY = 0;

//SLV1 Configuration
parameter SLV1_START_ADDR = 4096;
parameter SLV1_END_ADDR = 8191;
parameter SLV1_OSTDREQ_NUM = 4;
parameter SLV1_OSTDREQ_SIZE = 8;
parameter SLV1_PRIORITY = 0;

//SLV2 Configuration
parameter SLV2_START_ADDR = 8192;
parameter SLV2_END_ADDR = 12287;
parameter SLV2_OSTDREQ_NUM = 4;
parameter SLV2_OSTDREQ_SIZE = 8;
parameter SLV2_PRIORITY = 0;

// Channels' width (concatenated)
parameter AWCH_W = 47;  //2+2+3+4+4+32
parameter WCH_W  = 40;  //4+32+4
parameter BCH_W  = 6;   //2+4
parameter ARCH_W = 47;  //2+2+3+4+4+32
parameter RCH_W  = 38;  //32+2+4   
//CAM parameters
parameter CAM_ADDR_WIDTH = 4  ;

//para<<<
//vari>>>
integer  err_count;
integer  test_status;
logic [1:0]  wr_req_id;
logic [1:0]  rd_req_id;
integer  wr_rsp_success_cnt;
integer  rd_rsp_success_cnt;
logic    mst0_narrow;
logic    mst1_narrow;
logic    mst2_narrow;

logic [8-1 :0] mst0_awlen_real;
logic [8-1 :0] mst1_awlen_real;
logic [8-1 :0] mst2_awlen_real;

logic [8-1 :0] mst0_arlen_real;
logic [8-1 :0] mst1_arlen_real;
logic [8-1 :0] mst2_arlen_real;
//<<<
//Ports>>>
logic  aclk;
logic  aresetn;
logic  srst;
logic  mst0_aclk;
logic  mst0_aresetn;
logic  mst0_srst;
logic  mst0_awvalid;
logic  mst0_awready;
logic   [AXI_ADDR_W    -1:0] mst0_awaddr;
logic   [4             -1:0] mst0_awlen;
logic   [3             -1:0] mst0_awsize;
logic   [2             -1:0] mst0_awburst;
logic   [2             -1:0] mst0_awlock;
logic   [AXI_ID_W      -1:0] mst0_awid;
logic  mst0_wvalid;
logic  mst0_wready;
logic  mst0_wlast;
logic   [AXI_DATA_W    -1:0] mst0_wdata;
logic   [AXI_DATA_W/8  -1:0] mst0_wstrb;
logic   [AXI_ID_W      -1:0] mst0_wid;
logic  mst0_bvalid;
logic  mst0_bready;
logic [AXI_ID_W      -1:0] mst0_bid;
logic [2             -1:0] mst0_bresp;
logic  mst0_arvalid;
logic  mst0_arready;
logic   [AXI_ADDR_W    -1:0] mst0_araddr;
logic   [4             -1:0] mst0_arlen;
logic   [3             -1:0] mst0_arsize;
logic   [2             -1:0] mst0_arburst;
logic   [2             -1:0] mst0_arlock;
logic   [AXI_ID_W      -1:0] mst0_arid;
logic  mst0_rvalid;
logic  mst0_rready;
logic [AXI_ID_W      -1:0] mst0_rid;
logic [2             -1:0] mst0_rresp;
logic [AXI_DATA_W    -1:0] mst0_rdata;
logic  mst0_rlast;
logic  mst1_aclk;
logic  mst1_aresetn;
logic  mst1_srst;
logic  mst1_awvalid;
logic  mst1_awready;
logic   [AXI_ADDR_W    -1:0] mst1_awaddr;
logic   [4             -1:0] mst1_awlen;
logic   [3             -1:0] mst1_awsize;
logic   [2             -1:0] mst1_awburst;
logic   [2             -1:0] mst1_awlock;
logic   [AXI_ID_W      -1:0] mst1_awid;
logic  mst1_wvalid;
logic  mst1_wready;
logic  mst1_wlast;
logic   [AXI_DATA_W    -1:0] mst1_wdata;
logic   [AXI_DATA_W/8  -1:0] mst1_wstrb;
logic   [AXI_ID_W      -1:0] mst1_wid;
logic  mst1_bvalid;
logic  mst1_bready;
logic [AXI_ID_W      -1:0] mst1_bid;
logic [2             -1:0] mst1_bresp;
logic  mst1_arvalid;
logic  mst1_arready;
logic   [AXI_ADDR_W    -1:0] mst1_araddr;
logic   [4             -1:0] mst1_arlen;
logic   [3             -1:0] mst1_arsize;
logic   [2             -1:0] mst1_arburst;
logic   [2             -1:0] mst1_arlock;
logic   [AXI_ID_W      -1:0] mst1_arid;
logic  mst1_rvalid;
logic  mst1_rready;
logic [AXI_ID_W      -1:0] mst1_rid;
logic [2             -1:0] mst1_rresp;
logic [AXI_DATA_W    -1:0] mst1_rdata;
logic  mst1_rlast;
logic  mst2_aclk;
logic  mst2_aresetn;
logic  mst2_srst;
logic  mst2_awvalid;
logic  mst2_awready;
logic  [AXI_ADDR_W    -1:0] mst2_awaddr;
logic  [4             -1:0] mst2_awlen;
logic  [3             -1:0] mst2_awsize;
logic  [2             -1:0] mst2_awburst;
logic  [2             -1:0] mst2_awlock;
logic  [AXI_ID_W      -1:0] mst2_awid;
logic  mst2_wvalid;
logic  mst2_wready;
logic  mst2_wlast;
logic   [AXI_DATA_W    -1:0] mst2_wdata;
logic   [AXI_DATA_W/8  -1:0] mst2_wstrb;
logic   [AXI_ID_W      -1:0] mst2_wid;
logic  mst2_bvalid;
logic  mst2_bready;
logic [AXI_ID_W      -1:0] mst2_bid;
logic [2             -1:0] mst2_bresp;
logic  mst2_arvalid;
logic  mst2_arready;
logic   [AXI_ADDR_W    -1:0] mst2_araddr;
logic   [4             -1:0] mst2_arlen;
logic   [3             -1:0] mst2_arsize;
logic   [2             -1:0] mst2_arburst;
logic   [2             -1:0] mst2_arlock;
logic   [AXI_ID_W      -1:0] mst2_arid;
logic  mst2_rvalid;
logic  mst2_rready;
logic [AXI_ID_W      -1:0] mst2_rid;
logic [2             -1:0] mst2_rresp;
logic [AXI_DATA_W    -1:0] mst2_rdata;
logic  mst2_rlast;
logic  slv0_aclk;
logic  slv0_aresetn;
logic  slv0_srst;
logic  slv0_awvalid;
logic  slv0_awready;
logic [AXI_ADDR_W    -1:0] slv0_awaddr;
logic [4             -1:0] slv0_awlen;
logic [3             -1:0] slv0_awsize;
logic [2             -1:0] slv0_awburst;
logic [2             -1:0] slv0_awlock;
logic [AXI_ID_W      -1:0] slv0_awid;
logic  slv0_wvalid;
logic  slv0_wready;
logic  slv0_wlast;
logic [AXI_DATA_W    -1:0] slv0_wdata;
logic [AXI_DATA_W/8  -1:0] slv0_wstrb;
logic [AXI_ID_W      -1:0] slv0_wid;
logic  slv0_bvalid;
logic  slv0_bready;
logic   [AXI_ID_W      -1:0] slv0_bid;
logic   [2             -1:0] slv0_bresp;
logic  slv0_arvalid;
logic  slv0_arready;
logic [AXI_ADDR_W    -1:0] slv0_araddr;
logic [4             -1:0] slv0_arlen;
logic [3             -1:0] slv0_arsize;
logic [2             -1:0] slv0_arburst;
logic [2             -1:0] slv0_arlock;
logic [AXI_ID_W      -1:0] slv0_arid;
logic  slv0_rvalid;
logic  slv0_rready;
logic   [AXI_ID_W      -1:0] slv0_rid;
logic   [2             -1:0] slv0_rresp;
logic   [AXI_DATA_W    -1:0] slv0_rdata;
logic  slv0_rlast;
logic  slv1_aclk;
logic  slv1_aresetn;
logic  slv1_srst;
logic  slv1_awvalid;
logic  slv1_awready;
logic [AXI_ADDR_W    -1:0] slv1_awaddr;
logic [4             -1:0] slv1_awlen;
logic [3             -1:0] slv1_awsize;
logic [2             -1:0] slv1_awburst;
logic [2             -1:0] slv1_awlock;
logic [AXI_ID_W      -1:0] slv1_awid;
logic  slv1_wvalid;
logic  slv1_wready;
logic  slv1_wlast;
logic [AXI_DATA_W    -1:0] slv1_wdata;
logic [AXI_DATA_W/8  -1:0] slv1_wstrb;
logic [AXI_ID_W      -1:0] slv1_wid;
logic  slv1_bvalid;
logic  slv1_bready;
logic   [AXI_ID_W      -1:0] slv1_bid;
logic   [2             -1:0] slv1_bresp;
logic  slv1_arvalid;
logic  slv1_arready;
logic [AXI_ADDR_W    -1:0] slv1_araddr;
logic [4             -1:0] slv1_arlen;
logic [3             -1:0] slv1_arsize;
logic [2             -1:0] slv1_arburst;
logic [2             -1:0] slv1_arlock;
logic [AXI_ID_W      -1:0] slv1_arid;
logic  slv1_rvalid;
logic  slv1_rready;
logic   [AXI_ID_W      -1:0] slv1_rid;
logic   [2             -1:0] slv1_rresp;
logic   [AXI_DATA_W    -1:0] slv1_rdata;
logic  slv1_rlast;
logic  slv2_aclk;
logic  slv2_aresetn;
logic  slv2_srst;
logic  slv2_awvalid;
logic  slv2_awready;
logic [AXI_ADDR_W    -1:0] slv2_awaddr;
logic [4             -1:0] slv2_awlen;
logic [3             -1:0] slv2_awsize;
logic [2             -1:0] slv2_awburst;
logic [2             -1:0] slv2_awlock;
logic [AXI_ID_W      -1:0] slv2_awid;
logic  slv2_wvalid;
logic  slv2_wready;
logic  slv2_wlast;
logic [AXI_DATA_W    -1:0] slv2_wdata;
logic [AXI_DATA_W/8  -1:0] slv2_wstrb;
logic [AXI_ID_W      -1:0] slv2_wid;
logic  slv2_bvalid;
logic  slv2_bready;
logic   [AXI_ID_W      -1:0] slv2_bid;
logic   [2             -1:0] slv2_bresp;
logic  slv2_arvalid;
logic  slv2_arready;
logic [AXI_ADDR_W    -1:0] slv2_araddr;
logic [4             -1:0] slv2_arlen;
logic [3             -1:0] slv2_arsize;
logic [2             -1:0] slv2_arburst;
logic [2             -1:0] slv2_arlock;
logic [AXI_ID_W      -1:0] slv2_arid;
logic  slv2_rvalid;
logic  slv2_rready;
logic  [AXI_ID_W      -1:0] slv2_rid;
logic   [2             -1:0] slv2_rresp;
logic   [AXI_DATA_W    -1:0] slv2_rdata;
logic  slv2_rlast;
//<<<

//dut>>>
axi_crossbar_top # (
  .AXI_ID_W(AXI_ID_W),
  .AXI_DATA_W(AXI_DATA_W),
  .AXI_ADDR_W(AXI_ADDR_W),
  .MST_NB(MST_NB),
  .SLV_NB(SLV_NB),
  .MST_PIPELINE(MST_PIPELINE),
  .SLV_PIPELINE(SLV_PIPELINE),
  .MST0_OSTDREQ_NUM(MST0_OSTDREQ_NUM),
  .MST0_OSTDREQ_SIZE(MST0_OSTDREQ_SIZE),
  .MST0_PRIORITY(MST0_PRIORITY),
  .MST1_OSTDREQ_NUM(MST1_OSTDREQ_NUM),
  .MST1_OSTDREQ_SIZE(MST1_OSTDREQ_SIZE),
  .MST1_PRIORITY(MST1_PRIORITY),
  .MST2_OSTDREQ_NUM(MST2_OSTDREQ_NUM),
  .MST2_OSTDREQ_SIZE(MST2_OSTDREQ_SIZE),
  .MST2_PRIORITY(MST2_PRIORITY),
  .SLV0_START_ADDR(SLV0_START_ADDR),
  .SLV0_END_ADDR(SLV0_END_ADDR),
  .SLV0_OSTDREQ_NUM(SLV0_OSTDREQ_NUM),
  .SLV0_OSTDREQ_SIZE(SLV0_OSTDREQ_SIZE),
  .SLV0_PRIORITY(SLV0_PRIORITY),
  .SLV1_START_ADDR(SLV1_START_ADDR),
  .SLV1_END_ADDR(SLV1_END_ADDR),
  .SLV1_OSTDREQ_NUM(SLV1_OSTDREQ_NUM),
  .SLV1_OSTDREQ_SIZE(SLV1_OSTDREQ_SIZE),
  .SLV1_PRIORITY(SLV1_PRIORITY),
  .SLV2_START_ADDR(SLV2_START_ADDR),
  .SLV2_END_ADDR(SLV2_END_ADDR),
  .SLV2_OSTDREQ_NUM(SLV2_OSTDREQ_NUM),
  .SLV2_OSTDREQ_SIZE(SLV2_OSTDREQ_SIZE),
  .SLV2_PRIORITY(SLV2_PRIORITY),
  .AWCH_W(AWCH_W),
  .WCH_W(WCH_W),
  .BCH_W(BCH_W),
  .ARCH_W(ARCH_W),
  .RCH_W(RCH_W),
  .CAM_ADDR_WIDTH(CAM_ADDR_WIDTH)
)
axi_crossbar_top_inst (
  .aclk(aclk),
  .aresetn(aresetn),
  .srst(srst),
  .mst0_aclk(aclk),
  .mst0_aresetn(aresetn),
  .mst0_srst(srst),
  .mst0_awvalid(mst0_awvalid),
  .mst0_awready(mst0_awready),
  .mst0_awaddr(mst0_awaddr),
  .mst0_awlen(mst0_awlen),
  .mst0_awsize(mst0_awsize),
  .mst0_awburst(mst0_awburst),
  .mst0_awlock(mst0_awlock),
  .mst0_awid(mst0_awid),
  .mst0_wvalid(mst0_wvalid),
  .mst0_wready(mst0_wready),
  .mst0_wlast(mst0_wlast),
  .mst0_wdata(mst0_wdata),
  .mst0_wstrb(mst0_wstrb),
  .mst0_wid(mst0_wid),
  .mst0_bvalid(mst0_bvalid),
  .mst0_bready(mst0_bready),
  .mst0_bid(mst0_bid),
  .mst0_bresp(mst0_bresp),
  .mst0_arvalid(mst0_arvalid),
  .mst0_arready(mst0_arready),
  .mst0_araddr(mst0_araddr),
  .mst0_arlen(mst0_arlen),
  .mst0_arsize(mst0_arsize),
  .mst0_arburst(mst0_arburst),
  .mst0_arlock(mst0_arlock),
  .mst0_arid(mst0_arid),
  .mst0_rvalid(mst0_rvalid),
  .mst0_rready(mst0_rready),
  .mst0_rid(mst0_rid),
  .mst0_rresp(mst0_rresp),
  .mst0_rdata(mst0_rdata),
  .mst0_rlast(mst0_rlast),
  .mst1_aclk(aclk),
  .mst1_aresetn(aresetn),
  .mst1_srst(srst),
  .mst1_awvalid(mst1_awvalid),
  .mst1_awready(mst1_awready),
  .mst1_awaddr(mst1_awaddr),
  .mst1_awlen(mst1_awlen),
  .mst1_awsize(mst1_awsize),
  .mst1_awburst(mst1_awburst),
  .mst1_awlock(mst1_awlock),
  .mst1_awid(mst1_awid),
  .mst1_wvalid(mst1_wvalid),
  .mst1_wready(mst1_wready),
  .mst1_wlast(mst1_wlast),
  .mst1_wdata(mst1_wdata),
  .mst1_wstrb(mst1_wstrb),
  .mst1_wid(mst1_wid),
  .mst1_bvalid(mst1_bvalid),
  .mst1_bready(mst1_bready),
  .mst1_bid(mst1_bid),
  .mst1_bresp(mst1_bresp),
  .mst1_arvalid(mst1_arvalid),
  .mst1_arready(mst1_arready),
  .mst1_araddr(mst1_araddr),
  .mst1_arlen(mst1_arlen),
  .mst1_arsize(mst1_arsize),
  .mst1_arburst(mst1_arburst),
  .mst1_arlock(mst1_arlock),
  .mst1_arid(mst1_arid),
  .mst1_rvalid(mst1_rvalid),
  .mst1_rready(mst1_rready),
  .mst1_rid(mst1_rid),
  .mst1_rresp(mst1_rresp),
  .mst1_rdata(mst1_rdata),
  .mst1_rlast(mst1_rlast),
  .mst2_aclk(aclk),
  .mst2_aresetn(aresetn),
  .mst2_srst(srst),
  .mst2_awvalid(mst2_awvalid),
  .mst2_awready(mst2_awready),
  .mst2_awaddr(mst2_awaddr),
  .mst2_awlen(mst2_awlen),
  .mst2_awsize(mst2_awsize),
  .mst2_awburst(mst2_awburst),
  .mst2_awlock(mst2_awlock),
  .mst2_awid(mst2_awid),
  .mst2_wvalid(mst2_wvalid),
  .mst2_wready(mst2_wready),
  .mst2_wlast(mst2_wlast),
  .mst2_wdata(mst2_wdata),
  .mst2_wstrb(mst2_wstrb),
  .mst2_wid(mst2_wid),
  .mst2_bvalid(mst2_bvalid),
  .mst2_bready(mst2_bready),
  .mst2_bid(mst2_bid),
  .mst2_bresp(mst2_bresp),
  .mst2_arvalid(mst2_arvalid),
  .mst2_arready(mst2_arready),
  .mst2_araddr(mst2_araddr),
  .mst2_arlen(mst2_arlen),
  .mst2_arsize(mst2_arsize),
  .mst2_arburst(mst2_arburst),
  .mst2_arlock(mst2_arlock),
  .mst2_arid(mst2_arid),
  .mst2_rvalid(mst2_rvalid),
  .mst2_rready(mst2_rready),
  .mst2_rid(mst2_rid),
  .mst2_rresp(mst2_rresp),
  .mst2_rdata(mst2_rdata),
  .mst2_rlast(mst2_rlast),
  .slv0_aclk(aclk),
  .slv0_aresetn(aresetn),
  .slv0_srst(srst),
  .slv0_awvalid(slv0_awvalid),
  .slv0_awready(slv0_awready),
  .slv0_awaddr(slv0_awaddr),
  .slv0_awlen(slv0_awlen),
  .slv0_awsize(slv0_awsize),
  .slv0_awburst(slv0_awburst),
  .slv0_awlock(slv0_awlock),
  .slv0_awid(slv0_awid),
  .slv0_wvalid(slv0_wvalid),
  .slv0_wready(slv0_wready),
  .slv0_wlast(slv0_wlast),
  .slv0_wdata(slv0_wdata),
  .slv0_wstrb(slv0_wstrb),
  .slv0_wid(slv0_wid),
  .slv0_bvalid(slv0_bvalid),
  .slv0_bready(slv0_bready),
  .slv0_bid(slv0_bid),
  .slv0_bresp(slv0_bresp),
  .slv0_arvalid(slv0_arvalid),
  .slv0_arready(slv0_arready),
  .slv0_araddr(slv0_araddr),
  .slv0_arlen(slv0_arlen),
  .slv0_arsize(slv0_arsize),
  .slv0_arburst(slv0_arburst),
  .slv0_arlock(slv0_arlock),
  .slv0_arid(slv0_arid),
  .slv0_rvalid(slv0_rvalid),
  .slv0_rready(slv0_rready),
  .slv0_rid(slv0_rid),
  .slv0_rresp(slv0_rresp),
  .slv0_rdata(slv0_rdata),
  .slv0_rlast(slv0_rlast),
  .slv1_aclk(aclk),
  .slv1_aresetn(aresetn),
  .slv1_srst(srst),
  .slv1_awvalid(slv1_awvalid),
  .slv1_awready(slv1_awready),
  .slv1_awaddr(slv1_awaddr),
  .slv1_awlen(slv1_awlen),
  .slv1_awsize(slv1_awsize),
  .slv1_awburst(slv1_awburst),
  .slv1_awlock(slv1_awlock),
  .slv1_awid(slv1_awid),
  .slv1_wvalid(slv1_wvalid),
  .slv1_wready(slv1_wready),
  .slv1_wlast(slv1_wlast),
  .slv1_wdata(slv1_wdata),
  .slv1_wstrb(slv1_wstrb),
  .slv1_wid(slv1_wid),
  .slv1_bvalid(slv1_bvalid),
  .slv1_bready(slv1_bready),
  .slv1_bid(slv1_bid),
  .slv1_bresp(slv1_bresp),
  .slv1_arvalid(slv1_arvalid),
  .slv1_arready(slv1_arready),
  .slv1_araddr(slv1_araddr),
  .slv1_arlen(slv1_arlen),
  .slv1_arsize(slv1_arsize),
  .slv1_arburst(slv1_arburst),
  .slv1_arlock(slv1_arlock),
  .slv1_arid(slv1_arid),
  .slv1_rvalid(slv1_rvalid),
  .slv1_rready(slv1_rready),
  .slv1_rid(slv1_rid),
  .slv1_rresp(slv1_rresp),
  .slv1_rdata(slv1_rdata),
  .slv1_rlast(slv1_rlast),
  .slv2_aclk(aclk),
  .slv2_aresetn(aresetn),
  .slv2_srst(srst),
  .slv2_awvalid(slv2_awvalid),
  .slv2_awready(slv2_awready),
  .slv2_awaddr(slv2_awaddr),
  .slv2_awlen(slv2_awlen),
  .slv2_awsize(slv2_awsize),
  .slv2_awburst(slv2_awburst),
  .slv2_awlock(slv2_awlock),
  .slv2_awid(slv2_awid),
  .slv2_wvalid(slv2_wvalid),
  .slv2_wready(slv2_wready),
  .slv2_wlast(slv2_wlast),
  .slv2_wdata(slv2_wdata),
  .slv2_wstrb(slv2_wstrb),
  .slv2_wid(slv2_wid),
  .slv2_bvalid(slv2_bvalid),
  .slv2_bready(slv2_bready),
  .slv2_bid(slv2_bid),
  .slv2_bresp(slv2_bresp),
  .slv2_arvalid(slv2_arvalid),
  .slv2_arready(slv2_arready),
  .slv2_araddr(slv2_araddr),
  .slv2_arlen(slv2_arlen),
  .slv2_arsize(slv2_arsize),
  .slv2_arburst(slv2_arburst),
  .slv2_arlock(slv2_arlock),
  .slv2_arid(slv2_arid),
  .slv2_rvalid(slv2_rvalid),
  .slv2_rready(slv2_rready),
  .slv2_rid(slv2_rid),
  .slv2_rresp(slv2_rresp),
  .slv2_rdata(slv2_rdata),
  .slv2_rlast(slv2_rlast)
);
//<<<

//mst>>>
axi_mst_driver # (
    .AXI_ADDR_W(AXI_ADDR_W),
    .AXI_ID_W(AXI_ID_W),
    .AXI_DATA_W(AXI_DATA_W),
    .MST_OSTDREQ_NUM(MST0_OSTDREQ_NUM),
    .MST_OSTDREQ_SIZE(MST0_OSTDREQ_SIZE),
    .AWCH_W(AWCH_W),
    .WCH_W(WCH_W),
    .BCH_W(BCH_W),
    .ARCH_W(ARCH_W),
    .RCH_W(RCH_W)
  )
  axi_mst0_driver_inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .srst(srst),
    .in_awvalid(mst0_awvalid),
    .in_awready(mst0_awready),
    .in_awlen_real(mst0_awlen_real),
    .awlen(mst0_awlen),
    .in_awid(mst0_awid),
    
    .out_wvalid(mst0_wvalid),
    .in_wready(mst0_wready),
    .out_wlast(mst0_wlast),
    .out_wid(mst0_wid),
    .out_wdata(mst0_wdata),
    .out_wstrb(mst0_wstrb),
    .narrow(mst0_narrow),
    .out_rready(mst0_rready),
    .out_bready(mst0_bready)
  );

  axi_mst_driver # (
    .AXI_ADDR_W(AXI_ADDR_W),
    .AXI_ID_W(AXI_ID_W),
    .AXI_DATA_W(AXI_DATA_W),
    .MST_OSTDREQ_NUM(MST0_OSTDREQ_NUM),
    .MST_OSTDREQ_SIZE(MST0_OSTDREQ_SIZE),
    .AWCH_W(AWCH_W),
    .WCH_W(WCH_W),
    .BCH_W(BCH_W),
    .ARCH_W(ARCH_W),
    .RCH_W(RCH_W)
  )
  axi_mst1_driver_inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .srst(srst),
    .in_awvalid(mst1_awvalid),
    .in_awready(mst1_awready),
    .in_awlen_real(mst1_awlen_real),
    .awlen(mst1_awlen),
    .in_awid(mst1_awid),
  
    .out_wvalid(mst1_wvalid),
    .in_wready(mst1_wready),
    .out_wlast(mst1_wlast),
    .out_wid(mst1_wid),
    .out_wdata(mst1_wdata),
    .out_wstrb(mst1_wstrb),
    .narrow(mst1_narrow),
    .out_rready(mst1_rready),
    .out_bready(mst1_bready)
  );

  axi_mst_driver # (
    .AXI_ADDR_W(AXI_ADDR_W),
    .AXI_ID_W(AXI_ID_W),
    .AXI_DATA_W(AXI_DATA_W),
    .MST_OSTDREQ_NUM(MST0_OSTDREQ_NUM),
    .MST_OSTDREQ_SIZE(MST0_OSTDREQ_SIZE),
    .AWCH_W(AWCH_W),
    .WCH_W(WCH_W),
    .BCH_W(BCH_W),
    .ARCH_W(ARCH_W),
    .RCH_W(RCH_W)
  )
  axi_mst2_driver_inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .srst(srst),
    .in_awvalid(mst2_awvalid),
    .in_awready(mst2_awready),
    .in_awlen_real(mst2_awlen_real),
    .awlen(mst2_awlen),
    .in_awid(mst2_awid),

    .out_wvalid(mst2_wvalid),
    .in_wready(mst2_wready),
    .out_wlast(mst2_wlast),
    .out_wid(mst2_wid),
    .out_wdata(mst2_wdata),
    .out_wstrb(mst2_wstrb),
    .narrow(mst2_narrow),
    .out_rready(mst2_rready),
    .out_bready(mst2_bready)
  );
//<<<

//slv>>>
  axi_slv_responder # (
    .AXI_ADDR_W(AXI_ADDR_W),
    .AXI_ID_W(AXI_ID_W),
    .AXI_DATA_W(AXI_DATA_W),
    .SLV_OSTDREQ_NUM(SLV0_OSTDREQ_NUM),
    .SLV_OSTDREQ_SIZE(SLV0_OSTDREQ_SIZE),
    .AWCH_W(AWCH_W),
    .WCH_W(WCH_W),
    .BCH_W(BCH_W),
    .ARCH_W(ARCH_W),
    .RCH_W(RCH_W)
  )
  axi_slv0_responder_inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .srst(srst),
    .out_awready(slv0_awready),
    .out_wready(slv0_wready),
    .in_wvalid(slv0_wvalid),
    .in_wlast(slv0_wlast),
    .in_wid(slv0_wid),
    .out_bvalid(slv0_bvalid),
    .in_bready(slv0_bready),
    .out_bid(slv0_bid),
    .out_bresp(slv0_bresp),

    .in_arvalid(slv0_arvalid),
    .out_arready(slv0_arready),
    .in_arlen(slv0_arlen),
    .in_arid(slv0_arid),
    .out_rvalid(slv0_rvalid),
    .out_rresp(slv0_rresp),
    .in_rready(slv0_rready),

    .out_rid(slv0_rid),
    .out_rdata(slv0_rdata),
    .out_rlast(slv0_rlast)  
  );

  axi_slv_responder # (
    .AXI_ADDR_W(AXI_ADDR_W),
    .AXI_ID_W(AXI_ID_W),
    .AXI_DATA_W(AXI_DATA_W),
    .SLV_OSTDREQ_NUM(SLV0_OSTDREQ_NUM),
    .SLV_OSTDREQ_SIZE(SLV0_OSTDREQ_SIZE),
    .AWCH_W(AWCH_W),
    .WCH_W(WCH_W),
    .BCH_W(BCH_W),
    .ARCH_W(ARCH_W),
    .RCH_W(RCH_W)
  )
  axi_slv1_responder_inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .srst(srst),
    .out_awready(slv1_awready),
    .in_wvalid(slv1_wvalid),
    .out_wready(slv1_wready),
    .in_wlast(slv1_wlast),
    .in_wid(slv1_wid),
    .out_bvalid(slv1_bvalid),
    .in_bready(slv1_bready),
    .out_bid(slv1_bid),
    .out_bresp(slv1_bresp),

    .in_arvalid(slv1_arvalid),
    .out_arready(slv1_arready),
    .in_arlen(slv1_arlen),
    .in_arid(slv1_arid),
    .out_rvalid(slv1_rvalid),
    .out_rresp(slv1_rresp),
    .in_rready(slv1_rready),

    .out_rid(slv1_rid),
    .out_rdata(slv1_rdata),
    .out_rlast(slv1_rlast)  
  );

  axi_slv_responder # (
    .AXI_ADDR_W(AXI_ADDR_W),
    .AXI_ID_W(AXI_ID_W),
    .AXI_DATA_W(AXI_DATA_W),
    .SLV_OSTDREQ_NUM(SLV2_OSTDREQ_NUM),
    .SLV_OSTDREQ_SIZE(SLV2_OSTDREQ_SIZE),
    .AWCH_W(AWCH_W),
    .WCH_W(WCH_W),
    .BCH_W(BCH_W),
    .ARCH_W(ARCH_W),
    .RCH_W(RCH_W)
  )
  axi_slv2_responder_inst (
    .aclk(aclk),
    .aresetn(aresetn),
    .srst(srst),
    .out_awready(slv2_awready),
    .in_wvalid(slv2_wvalid),
    .out_wready(slv2_wready),
    .in_wlast(slv2_wlast),
    .in_wid(slv2_wid),
    .out_bvalid(slv2_bvalid),
    .in_bready(slv2_bready),
    .out_bid(slv2_bid),
    .out_bresp(slv2_bresp),

    .in_arvalid(slv2_arvalid),
    .out_arready(slv2_arready),
    .in_arlen(slv2_arlen),
    .in_arid(slv2_arid),
    .out_rvalid(slv2_rvalid),
    .out_rresp(slv2_rresp),
    .in_rready(slv2_rready),

    .out_rid(slv2_rid),
    .out_rdata(slv2_rdata),
    .out_rlast(slv2_rlast)  
  );
//<<<

//task>>>
task aw_req_clr(
    input [1:0] mst_id
);  

begin
case (mst_id)
    2'b01: 
    begin
        mst0_awaddr='b0;
        mst0_awlen_real='b0;
        mst0_awsize='b0;//!!!!fix me !!!!未考虑窄带传输
        mst0_awburst='b0;
        mst0_awvalid='b0;
        mst0_awlock=2'b10;//默认赋值
        mst0_awid='b0;
        
    end 
    2'b10:
    begin
        mst1_awaddr='b0;
        mst1_awlen_real='b0;
        mst1_awsize='b0;//!!!!fix me !!!!未考虑窄带传输
        mst1_awburst='b0;
        mst1_awvalid='b0;
        mst1_awlock=2'b10;//默认赋值
        mst1_awid='b0;
       
    end 
    2'b11:
    begin
        mst2_awaddr='b0;
        mst2_awlen_real='b0;
        mst2_awsize='b0;//!!!!fix me !!!!未考虑窄带传输
        mst2_awburst='b0;
        mst2_awvalid='b0;
        mst2_awlock=2'b10;//默认赋值
        mst2_awid='b0;
       
    end 
    default: $display("error!!! 主机掩码不能为零!");
endcase
  //$display("Data: %h", data); // 在下一个时钟上升沿时显示 data 的值
end
endtask

task ar_req_clr(
    input [1:0] mst_id
);  

begin
case (mst_id)
    2'b01: 
    begin
        mst0_araddr='b0;
        mst0_arlen_real='b0;
        mst0_arsize='b0;//!!!!fix me !!!!未考虑窄带传输
        mst0_arburst='b0;
        mst0_arvalid='b0;
        mst0_arlock=2'b10;//默认赋值
        mst0_arid='b0;
    end 
    2'b10:
    begin
        mst1_araddr='b0;
        mst1_arlen_real='b0;
        mst1_arsize='b0;//!!!!fix me !!!!未考虑窄带传输
        mst1_arburst='b0;
        mst1_arvalid='b0;
        mst1_arlock=2'b10;//默认赋值
        mst1_arid='b0;
    end 
    2'b11:
    begin
        mst2_araddr='b0;
        mst2_arlen_real='b0;
        mst2_arsize='b0;//!!!!fix me !!!!未考虑窄带传输
        mst2_arburst='b0;
        mst2_arvalid='b0;
        mst2_arlock=2'b10;//默认赋值
        mst2_arid='b0;
    end 
    default: $display("error!!! 主机掩码不能为零!");
endcase
  //$display("Data: %h", data); // 在下一个时钟上升沿时显示 data 的值
end
endtask

task aw_INCR_req_random(
    input [1:0] mst_id,
    input [1:0] slv_id,
    input [1:0] req_id
);  

begin
    logic [AXI_ADDR_W    -1:0]awaddr;
case (slv_id)
2'b01: 
begin
    awaddr=$urandom_range(`SLV0_START_ADDR,`SLV0_END_ADDR); 
end 
2'b10: 
begin
    awaddr=$urandom_range(`SLV1_START_ADDR,`SLV1_END_ADDR); 
end 
2'b11:
    awaddr=$urandom_range(`SLV2_START_ADDR,`SLV2_END_ADDR); 
default: $display("error!!! 未知从机代码");
endcase

case (mst_id)
    2'b01: 
    begin
        mst0_awaddr=awaddr;
        mst0_awlen_real=$urandom_range(0,MST0_OSTDREQ_SIZE-1);//fix me !!!! 有可能超出边界，范围也有问题
        mst0_awsize=mst0_narrow ? 0 : 2;
        mst0_awburst=`INCR;
        mst0_awvalid=1'b1;
        mst0_awid={2'b00,req_id};
        $display("write to addr 0x%h,len=0d%d,req_id= 0d%d", awaddr,mst0_awlen_real,req_id);
    end 
    2'b10:
    begin
        mst1_awaddr=awaddr;
        mst1_awlen_real=$urandom_range(0,MST1_OSTDREQ_SIZE-1);
        mst1_awsize=mst1_narrow ? 0 : 2;
        mst1_awburst=`INCR;
        mst1_awvalid=1'b1;
        mst1_awid={2'b00,req_id};
        $display("write to addr 0x%h,len=0d%d,req_id= 0d%d", awaddr,mst1_awlen_real,req_id);
    end 
    2'b11:
    begin
        mst2_awaddr=awaddr;
        mst2_awlen_real=$urandom_range(0,MST2_OSTDREQ_SIZE-1);
        mst2_awsize=mst2_narrow ? 0 : 2;
        mst2_awburst=`INCR;
        mst2_awvalid=1'b1;
        mst2_awid={2'b00,req_id};
        $display("write to addr 0x%h,len=0d%d,req_id= 0d%d", awaddr,mst2_awlen_real,req_id);
    end 
    default: $display("error!!! 主机掩码不能为零!");
endcase
end
endtask

task ar_INCR_req_random(
    input [1:0] mst_id,
    input [1:0] slv_id,
    input [1:0] req_id

);  

begin
    logic [AXI_ADDR_W    -1:0]araddr;
case (slv_id)
2'b01: 
begin
    araddr=$urandom_range(`SLV0_START_ADDR,`SLV0_END_ADDR); 
end 
2'b10: 
begin
    araddr=$urandom_range(`SLV1_START_ADDR,`SLV1_END_ADDR); 
end 
2'b11:
    araddr=$urandom_range(`SLV2_START_ADDR,`SLV2_END_ADDR); 
default: $display("error!!! 未知从机代码");
endcase

case (mst_id)
    2'b01: 
    begin
        mst0_araddr=araddr;
        mst0_arlen_real=$urandom_range(0,SLV0_OSTDREQ_SIZE-1);
        mst0_arsize=5;//!!!!fix me !!!!未考虑窄带传输
        mst0_arburst=`INCR;
        mst0_arvalid=1'b1;
        mst0_arid={2'b00,req_id};
        $display("read from addr 0x%h,len=0d%d,req_id= 0d%d", araddr,mst0_arlen_real,req_id);
    end 
    2'b10:
    begin
        mst1_araddr=araddr;
        mst1_arlen_real=$urandom_range(0,SLV1_OSTDREQ_SIZE-1);
        mst1_arsize=5;//!!!!fix me !!!!未考虑窄带传输
        mst1_arburst=`INCR;
        mst1_arvalid=1'b1;
        mst1_arid={2'b00,req_id};
        $display("read from addr 0x%h,len=0d%d,req_id= 0d%d", araddr,mst1_arlen_real,req_id);
    end 
    2'b11:
    begin
        mst2_araddr=araddr;
        mst2_arlen_real=$urandom_range(0,SLV2_OSTDREQ_SIZE-1);
        mst2_arsize=5;//!!!!fix me !!!!未考虑窄带传输
        mst2_arburst=`INCR;
        mst2_arvalid=1'b1;
        mst2_arid={2'b00,req_id};
        $display("read from addr 0x%h,len=0d%d,req_id= 0d%d", araddr,mst2_arlen_real,req_id);
    end 
    default: $display("error!!! 主机掩码不能为零!");
endcase
end
endtask

task aw_req(    input [1:0] mst_id,    input [1:0] slv_id,    input [1:0] req_id,    input [1:0] awburst,    input [AXI_ADDR_W    -1:0]awaddr,       input [8-1:0] awlen
);  
begin
  
case (mst_id)
    2'b01: 
    begin
        mst0_awaddr=awaddr;
        mst0_awlen_real=awlen;
        mst0_awsize=mst0_narrow ? 0 : 2;
        mst0_awburst=awburst;
        mst0_awvalid=1'b1;
        mst0_awid={2'b00,req_id};
        $display("write to addr 0x%h,len=0d%d", awaddr,mst0_awlen_real);
    end 
    2'b10:
    begin
        mst1_awaddr=awaddr;
        mst1_awlen_real=awlen;
        mst1_awsize=mst1_narrow ? 0 : 2;
        mst1_awburst=awburst;
        mst1_awvalid=1'b1;
        mst1_awid={2'b00,req_id};
        $display("write to addr 0x%h,len=0d%d", awaddr,mst1_awlen_real);
    end 
    2'b11:
    begin
        mst2_awaddr=awaddr;
        mst2_awlen_real=awlen;
        mst2_awsize=mst2_narrow ? 0 : 2;
        mst2_awburst=awburst;
        mst2_awvalid=1'b1;
        mst2_awid={2'b00,req_id};
        $display("write to addr 0x%h,len=0d%d", awaddr,mst2_awlen_real);
    end 
    default: $display("error!!! 主机掩码不能为零!");
endcase
end
endtask


//<<<

//test case>>>
task axi_init();
begin
  aclk=0;
    aresetn=1;
    srst=0;
    aw_req_clr(`MST0);
    aw_req_clr(`MST1);
    aw_req_clr(`MST2);

    ar_req_clr(`MST0);
    ar_req_clr(`MST1);
    ar_req_clr(`MST2);

    mst0_narrow='b0;
    mst1_narrow='b0;
    mst2_narrow='b0;
    //@(negedge aclk);

    @(negedge aclk);
    aresetn =0 ; //复位
    @(negedge aclk);
    aresetn =1 ; //置位
    @(negedge aclk);

end
endtask

task mst0_or();
begin
  wr_req_id=0;
    rd_req_id=0;

    repeat(testnum)begin
      aw_INCR_req_random(`MST0,`SLV0,wr_req_id);
      wait(mst0_awvalid && mst0_awready);
      @(negedge aclk);
      wr_req_id+=1;
    end

     aw_req_clr(`MST0);
     
     repeat(testnum)begin
      ar_INCR_req_random(`MST0,`SLV0,rd_req_id);
      wait(mst0_arvalid && mst0_arready);
      @(negedge aclk);
      rd_req_id+=1;
    end

     ar_req_clr(`MST0);
end
endtask

task mst0_narrow_or();
begin
  mst0_narrow=1;
  wr_req_id=0;
    rd_req_id=0;

    repeat(testnum)begin
      aw_INCR_req_random(`MST0,`SLV0,wr_req_id);
      wait(mst0_awvalid && mst0_awready);
      @(negedge aclk);
      wr_req_id+=1;
    end

     aw_req_clr(`MST0);
     
     repeat(testnum)begin
      ar_INCR_req_random(`MST0,`SLV0,rd_req_id);
      wait(mst0_arvalid && mst0_arready);
      @(negedge aclk);
      rd_req_id+=1;
    end

     ar_req_clr(`MST0);
end
endtask

task mst0_256_burst();
begin
  mst0_narrow=0;
  wr_req_id=0;
  rd_req_id=0;

    
  aw_req(`MST0,`SLV0,wr_req_id,`INCR,0,255);
  @(negedge aclk);
  wait(mst0_awvalid && mst0_awready);
  
  wr_req_id+=1;
  aw_req_clr(`MST0);
  
    //  repeat(testnum)begin
    //   ar_INCR_req_random(`MST0,`SLV0,rd_req_id);
    //   wait(mst0_arvalid && mst0_arready);
    //   @(negedge aclk);
    //   rd_req_id+=1;
    // end

    //  ar_req_clr(`MST0);
end
endtask

task mst0_fixed_burst();
begin
  mst0_narrow=0;
  wr_req_id=0;
  rd_req_id=0;

    
  aw_req(`MST0,`SLV0,wr_req_id,`FIXED,8,10);
  @(negedge aclk);
  wait(mst0_awvalid && mst0_awready);
  
  wr_req_id+=1;
  aw_req_clr(`MST0);
  
    //  repeat(testnum)begin
    //   ar_INCR_req_random(`MST0,`SLV0,rd_req_id);
    //   wait(mst0_arvalid && mst0_arready);
    //   @(negedge aclk);
    //   rd_req_id+=1;
    // end

    //  ar_req_clr(`MST0);
end
endtask

task mst0_wrap_burst();
begin
  mst0_narrow=0;
  wr_req_id=0;
  rd_req_id=0;

    
  aw_req(`MST0,`SLV0,wr_req_id,`WRAP,4088,12);
  @(negedge aclk);
  wait(mst0_awvalid && mst0_awready);
  
  wr_req_id+=1;
  aw_req_clr(`MST0);
  
    //  repeat(testnum)begin
    //   ar_INCR_req_random(`MST0,`SLV0,rd_req_id);
    //   wait(mst0_arvalid && mst0_arready);
    //   @(negedge aclk);
    //   rd_req_id+=1;
    // end

    //  ar_req_clr(`MST0);
end
endtask

task multi2multi();
begin
  wr_req_id=0;
    rd_req_id=0;

fork
  begin
    aw_INCR_req_random(`MST0,`SLV0,0);
    wait(mst0_awvalid && mst0_awready);
    @(negedge aclk);
    aw_INCR_req_random(`MST0,`SLV1,1);
    wait(mst0_awvalid && mst0_awready);
    @(negedge aclk);
    aw_INCR_req_random(`MST0,`SLV2,2);
    wait(mst0_awvalid && mst0_awready);
    @(negedge aclk);
    aw_req_clr(`MST0);
  end
     
  begin
    aw_INCR_req_random(`MST1,`SLV2,0);
    wait(mst0_awvalid && mst0_awready);
    @(negedge aclk);
    aw_req_clr(`MST1);
  end     
 
  begin  
      ar_INCR_req_random(`MST0,`SLV0,0);
      wait(mst0_arvalid && mst0_arready);
      @(negedge aclk);
     ar_INCR_req_random(`MST0,`SLV1,1);
     wait(mst0_arvalid && mst0_arready);
     @(negedge aclk);
    ar_INCR_req_random(`MST0,`SLV2,2);
    wait(mst0_arvalid && mst0_arready);
    @(negedge aclk);
   ar_req_clr(`MST0);
end
join
end
endtask

task mst0_4kBound_burst();
begin
  mst0_narrow=0;
  wr_req_id=0;
  rd_req_id=0;

    
  aw_req(`MST0,`SLV0,wr_req_id,`INCR,4088,12);
  @(negedge aclk);
  wait(mst0_awvalid && mst0_awready);
  
  wr_req_id+=1;
  aw_req_clr(`MST0);
  
    //  repeat(testnum)begin
    //   ar_INCR_req_random(`MST0,`SLV0,rd_req_id);
    //   wait(mst0_arvalid && mst0_arready);
    //   @(negedge aclk);
    //   rd_req_id+=1;
    // end

    //  ar_req_clr(`MST0);
end
endtask

task mst0_mistroute();
begin
  mst0_narrow=0;
  wr_req_id=0;
  rd_req_id=0;

    
  aw_req(`MST0,2'b11,wr_req_id,`INCR,16383+32,8);
  @(negedge aclk);
  wait(mst0_awvalid && mst0_awready);
  
  wr_req_id+=1;
  aw_req_clr(`MST0);
  
    //  repeat(testnum)begin
    //   ar_INCR_req_random(`MST0,`SLV0,rd_req_id);
    //   wait(mst0_arvalid && mst0_arready);
    //   @(negedge aclk);
    //   rd_req_id+=1;
    // end

    //  ar_req_clr(`MST0);
end
endtask
//<<<

//dump、timeout、finish>>>
//fsdb
initial
begin
//if($test$plusargs("DUMP_FSDB"))
begin
$fsdbDumpfile("testname.fsdb");  //记录波形，波形名字testname.fsdb
$fsdbDumpvars("+all");  //+all参数，dump SV中的struct结构体
$fsdbDumpSVA();   //将assertion的结果存在fsdb中
$fsdbDumpMDA();  //dump memory arrays
//0: 当前级及其下面所有层级，如top.A, top.A.a，所有在top下面的多维数组均会被dump
//1: 仅仅dump当前组，也就是说，只dump top这一层的多维数组。
end
end

initial begin
    #(1e6*clk_period);
    $display ("!!!!!!ERROR Timeout !!!!!!!! at time %t", $time);
    
    $finish;
  end

  task Finish ();
  begin
      $display("%0t: %m: finishing simulation..", $time);
      //repeat (100) @(negedge top.i_osc_clk);
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Simulation ended, ERROR count: %0d", $time, err_count);
      $display("////////////////////////////////////////////////////////////////////////////\n");
          if (err_count == 0) begin
              $display("*********************************\n");
              $display("TEST PASSED!!!!!!!!!!!\n");
              $display("*********************************\n");
          end
          else
            begin
              $display("+++++++++++++++++++++++++++++++++\n");
              $display("Error!!!!!!!!!!!\n");
              $display("0d% Errors !!!!!!\n",err_count);
              $display("+++++++++++++++++++++++++++++++++\n");
          end
      $finish;
  end
  endtask

//<<<


  //always>>>
always #(clk_period/2)  aclk = ~ aclk ;
  //comb
//assign mst0 mst0_awlen_real;
//main>>>

//send req
initial begin
    test_status=0;
    axi_init();
    
    test_status=1;
    mst0_or();
    $display("\n *******outstanding test finish!!!******* \n");
    repeat(100) @(negedge aclk);

    test_status=2;
    mst0_narrow_or();
    $display("\n *******narrow test finish!!!******* \n");
    repeat(100) @(negedge aclk);

    test_status=3;
    mst0_256_burst();
    $display("\n *******256 length burst test finish!!!******* \n");
    repeat(500) @(negedge aclk);

    test_status=4;
    mst0_fixed_burst();
    $display("\n *******fixed burst test finish!!!******* \n");
    repeat(100) @(negedge aclk);

    test_status=5;
    mst0_wrap_burst();
    $display("\n ******* wrap burst test finish!!!******* \n");
    repeat(100) @(negedge aclk);

    test_status=6;
    multi2multi();
    $display("\n *******multi2multi burst test finish!!!******* \n");
    repeat(100) @(negedge aclk);

    test_status=7;
    mst0_4kBound_burst();
    $display("\n *******4k Bound test finish!!!******* \n");
    repeat(100) @(negedge aclk);

    test_status=8;
    mst0_mistroute();
    $display("\n *******mistroute test finish!!!******* \n");
    repeat(100) @(negedge aclk);

    $display("****************************************************************");
    $display ("*******all test case task done!!!!! at time %t*******", $time);
    $display("****************************************************************");
    $finish;



end

//rcv rsp

// always_ff @( negedge aclk or negedge aresetn ) begin : __err_count
//   if(!aresetn)
//     err_count<=testnum;
//   else if(mst0_bready && mst0_bvalid)
//     err_count<=err_count -1;
//   end

  always_ff @( negedge aclk or negedge aresetn ) begin : __wr_rsp_success_cnt
    if(!aresetn)
      wr_rsp_success_cnt<=testnum;
    else if(mst0_bready && mst0_bvalid)
      begin
        //$display("number %d wr_rsp recived successfully!!!",testnum-wr_rsp_success_cnt);
        wr_rsp_success_cnt<=wr_rsp_success_cnt -1;
      end
    end

    // always_ff @( negedge aclk or negedge aresetn ) begin : __rd_rsp_success_cnt
    //   if(!aresetn)
    //     rd_rsp_success_cnt<=testnum;
    //   else if(mst0_bready && mst0_bvalid)
    //     begin
    //       $display("number %d wr_rsp recived successfully!!!",testnum-wr_rsp_success_cnt)
    //       wr_rsp_success_cnt<=err_count -1;
    //     end
    //   end
// initial begin
//   if(err_count==0)
//     Finish();
// end
//<<<
endmodule