module axi_slv_responder #(
    //if>>>
    parameter always_ready=0,
    parameter AXI_ADDR_W = 32,
    //主机输入ID宽度
    parameter AXI_ID_W  =4,
    parameter AXI_DATA_W = 32,

    //OSTD REQ NUM
    parameter SLV_OSTDREQ_NUM = 4,
    //The data size of each OSTD REG
    parameter SLV_OSTDREQ_SIZE = 8,

    parameter AWCH_W = 51,
    parameter WCH_W  = 47,
    parameter BCH_W  = 12,
    parameter ARCH_W = 51,
    parameter RCH_W  = 45,


    parameter clk_period = 5
    )(
    //interface 
    input  logic  aclk,
    input  logic  aresetn,
    input  logic  srst,
    //AW Channel
    //input logic o_awvalid,
    output  logic  out_awready,

    //W Channel
    input logic in_wvalid,
    output  logic  out_wready,
    input logic in_wlast,
    input logic [AXI_ID_W   - 1 : 0] in_wid,
    // input logic [AXI_DATA_W - 1 : 0] o_wdata,
    // input logic [4          - 1 : 0] o_wstrb,
    //B Channel
    output  logic  out_bvalid,
    input logic in_bready,
    output  logic  [AXI_ID_W    - 1 : 0] out_bid,
    output  logic  [2           - 1 : 0] out_bresp
    ,


    // //AR Channel
    input logic in_arvalid,
    output  logic  out_arready,
    // input logic [AXI_ADDR_W  - 1 : 0] o_araddr,
    input logic [4           - 1 : 0] in_arlen,
    // input logic [3           - 1 : 0] o_arsize,
    // input logic [2           - 1 : 0] o_arburst,
    input logic [AXI_ID_W    - 1 : 0] in_arid,
    // input logic [2           - 1 : 0] o_arlock,
    //R Channel
    output  logic  out_rvalid,
    input logic in_rready,
    
    input                   ecc_error,

    output  logic  [AXI_ID_W    - 1 : 0] out_rid,
    output  logic  [2           - 1 : 0] out_rresp,
    output  logic  [AXI_DATA_W  - 1 : 0] out_rdata,
    output  logic  [AXI_DATA_W  - 2 : 0] out_rdata_databit,
    output  logic  out_rlast  
    );
    //if<<<

    //para>>>
    parameter DATA_BITS = 26;
parameter  PARITY_BITS = 6     ;
parameter k = DATA_BITS;
parameter r = PARITY_BITS;
//<<<
//vari def>>>
//counter 
    logic [2**4-1:0]                    rdata_cnt;
    logic [$clog2(SLV_OSTDREQ_NUM)+1-1:0]req_remain_cnt;
    logic [$clog2(SLV_OSTDREQ_NUM)-1:0] arlen_rd_ptr;
    logic [$clog2(SLV_OSTDREQ_NUM)-1:0] arlen_wr_ptr;
    logic [$clog2(SLV_OSTDREQ_NUM)-1:0] arid_rd_ptr;
    logic [$clog2(SLV_OSTDREQ_NUM)-1:0] arid_wr_ptr;

    logic [AXI_ID_W-1:0] rsp_remain_cnt;
    logic [AXI_ID_W-1:0] bresp_rd_ptr;
    logic [AXI_ID_W-1:0] bresp_wr_ptr;
    logic [AXI_ID_W-1:0] bid_rd_ptr;
    logic [AXI_ID_W-1:0] bid_wr_ptr;
//reg
    logic [2          - 1 : 0] bresp_now;
    logic [AXI_ID_W           - 1 : 0] bid_now;
    logic [AXI_ID_W           - 1 : 0] arid_now;
    // logic   out_wlast_prev;
    // logic   out_wvalid_prev;
// //queue 
//     queue [4-1:0]awlen_que[$];

//distributed ram
    logic  [2-1:0]bresp_ram[2**AXI_ID_W-1:0];
    logic  [4-1:0]bid_ram[2**AXI_ID_W-1:0];

    logic  [7-1:0]arlen_now;
    logic  [7-1:0]arlen_ram[SLV_OSTDREQ_NUM-1:0];
    logic  [7-1:0]arid_ram[SLV_OSTDREQ_NUM-1:0];

    //<<<

//function>>>
    function automatic  logic [31:0] hanming(logic [k:1] Data ,int errbit ); 

	// declare the signals and local parameters   
  
   reg [k:1] Data_in_08p;
	 reg [k:1] Data_out_10p; // only data bits
	 reg [r:1] Parity_out_10p; // only parity bits
	 reg [k+r:1] DataParity_out_10p;
	 reg DataParity_valid_10p;
	
	// intermediate signals
	reg [r:1] Parity;
	reg [k+r:1] DataParity;
	reg data_valid_int; // internal enable signal for output FFs


	// combinational logic: Parity trees
	reg [k+r-1:1] data_parity_i; // this will use only r-1:1 bits of parity vector
	integer i,j,l,cnt;
	reg a;
		  
	  // find the interspersed vector
	  j = 1; l = 1;
	  while ( (j<k+r) || (l<=k)) begin
	    if ( j == ((~j+1)&j)) begin	//check if it is a parity bit position
	      data_parity_i[j] = 1'b0;
	      j = j+1;
	    end
	    else begin
	      data_parity_i[j] = Data[l];
	      j = j+1; l = l+1;
	    end
	  end
	  
	  // find the parity bits r-1 to 1
	  for(i=1;i<r;i=i+1) begin
	  	cnt = 1;
		  a = cnt[i-1] & data_parity_i[1];
		  for(cnt=2;cnt<(k+r);cnt=cnt+1) begin
		  	a = a ^ (data_parity_i[cnt] & cnt[i-1]);
		  end
		  Parity[i]	= a;
	  end 

	  Parity[r] = (^Parity[r-1:1])^(^data_parity_i); // this bit used for double error detection 

		DataParity = {	Parity[6],
						Data[26:12],		//[17:31]
						Parity[5],			//[16]
						Data[11:5],			//[9:15]
						Parity[4],			//[8]
						Data[4:2],			//[5:7]
						Parity[3],			//[4]
						Data[1],			//[3]
						Parity[2:1]}; 		//[2][1]

        if (errbit==0)                
            ; 
        else
            DataParity[errbit]=~DataParity[errbit]; 

        return DataParity;
endfunction
                
//func<<<  
//comb>>>
    assign bresp_now=bresp_ram[bresp_rd_ptr];
    assign bid_now=bid_ram[bid_rd_ptr];


    assign arlen_now=arlen_ram[arlen_rd_ptr];
    assign arid_now=arid_ram[arid_rd_ptr];

    //<<<
//sequential>>>

//counter>>>
    always_ff @( posedge  aclk or negedge aresetn) begin : __rsp_remain_cnt
        if(!aresetn)
            rsp_remain_cnt<=0;
        else if( (in_wlast && in_wvalid && out_wready) && (out_bvalid && in_bready))
            rsp_remain_cnt<=rsp_remain_cnt;
        else if(out_bvalid && in_bready)
            rsp_remain_cnt<=rsp_remain_cnt-1;
        else if(in_wlast && in_wvalid && out_wready)
            rsp_remain_cnt<=rsp_remain_cnt+1; 
        
    end

always_ff @( posedge  aclk or negedge aresetn) begin : __req_remain_cnt
    if(!aresetn)
        req_remain_cnt<=0;
    else if(in_arvalid && out_arready && out_rlast)
        req_remain_cnt<=req_remain_cnt;
    else if(in_arvalid && out_arready)
        req_remain_cnt<=req_remain_cnt+1;
    else if(out_rlast && out_rvalid && in_rready)
        req_remain_cnt<=req_remain_cnt-1; 
end

always_ff @( posedge  aclk or negedge aresetn) begin : __rdata_cnt
    if(!aresetn)
        rdata_cnt<=0;
    else if(out_rlast && out_rvalid && in_rready)
        rdata_cnt<=0;
    else if(out_rvalid && in_rready)
        rdata_cnt<=rdata_cnt+1;
    
end

//<<<
  
//ram

//rsp>>>
always_ff @( posedge  aclk or negedge aresetn) begin : __bresp_rd_ptr
    if(!aresetn)
        bresp_rd_ptr <= 'b0; 
    else if(out_bvalid&&in_bready)
        bresp_rd_ptr <= bresp_rd_ptr+1;
    end
always_ff @( posedge  aclk or negedge aresetn) begin : __bresp_wr_ptr
    if(!aresetn)
        bresp_wr_ptr <= 'b0;
    else if(in_wlast && out_rvalid && in_rready)
        bresp_wr_ptr <= bresp_wr_ptr+1;
    end
always_ff @( posedge  aclk or negedge aresetn) begin : __bresp_ram
    if(!aresetn)
    for (integer i = 0; i < 2**AXI_ID_W; i = i + 1) begin
        bresp_ram[i] <= 'b0;
      end
    else if(in_wlast)
        bresp_ram[bresp_wr_ptr]<= 2'b00;//均默认接收正常
    end
    
    always_ff @( posedge  aclk or negedge aresetn) begin : __bid_rd_ptr
        if(!aresetn)
            bid_rd_ptr <= 'b0;
        else if(out_bvalid&&in_bready)
            bid_rd_ptr <= bid_rd_ptr+1;
        end
    always_ff @( posedge  aclk or negedge aresetn) begin : __bid_wr_ptr
        if(!aresetn)
            bid_wr_ptr <= 'b0;
        else if(in_wlast && in_wvalid && out_wready)
            bid_wr_ptr <= bid_wr_ptr+1;
        end
    always_ff @( posedge  aclk or negedge aresetn) begin : __bid_ram
        if(!aresetn)
        for (integer i = 0; i < 2**AXI_ID_W; i = i + 1) begin
            bid_ram[i] <= 'b0;
          end
        else if(in_wlast && in_wvalid && out_wready)
            bid_ram[bid_wr_ptr]<= in_wid;
        end
//<<<

//id 、 len>>>
        always_ff @( posedge  aclk or negedge aresetn) begin : __arlen_rd_ptr
            if(!aresetn)
                arlen_rd_ptr <= 'b0;
            else if(out_rlast && (out_rvalid && in_rready) )
                arlen_rd_ptr <= arlen_rd_ptr+1;
            end
        
        always_ff @( posedge  aclk or negedge aresetn) begin : __arlen_wr_ptr
            if(!aresetn)
                arlen_wr_ptr <= 'b0;
            else if(in_arvalid && out_arready)
                arlen_wr_ptr <= arlen_wr_ptr+1;
            end
        
        always_ff @( posedge  aclk or negedge aresetn) begin : __arlen_ram
            if(!aresetn)
            for (integer i = 0; i < SLV_OSTDREQ_NUM; i = i + 1) begin
                arlen_ram[i] <= 'b0;
              end
            else if(in_arvalid && out_arready)
                arlen_ram[arlen_wr_ptr]<= in_arlen;
            end
            
        always_ff @( posedge  aclk or negedge aresetn) begin : __arid_rd_ptr
            if(!aresetn)
                arid_rd_ptr <= 'b0;
            else if(out_rlast && (out_rvalid && in_rready))
                arid_rd_ptr <= arlen_rd_ptr+1;
            end
        
        always_ff @( posedge  aclk or negedge aresetn) begin : __arid_wr_ptr
            if(!aresetn)
                arid_wr_ptr <= 'b0;
            else if(in_arvalid && out_arready)
                arid_wr_ptr <= arlen_wr_ptr+1;
            end
        
        always_ff @( posedge  aclk or negedge aresetn) begin : __arid_ram
            if(!aresetn)
            for (integer i = 0; i < SLV_OSTDREQ_NUM; i = i + 1) begin
                arid_ram[i] <= 'b0;
                end
            else if(in_arvalid && out_arready)
                arid_ram[arlen_wr_ptr]<= in_arid;
            end       
        //<<<
//output:>>>
assign #(clk_period/5) out_rvalid= (req_remain_cnt!=0);
assign #(clk_period/5) out_rlast= (rdata_cnt==arlen_now) && out_rvalid;
assign #(clk_period/5) out_rid=arid_now;//!!!!fixme !!!!未考虑交织！！！！
assign #(clk_period/5) out_bvalid= (rsp_remain_cnt!=0);
assign #(clk_period/5) out_bid=bid_now;//!!!!fixme !!!!未考虑交织！！！！
assign #(clk_period/5) out_bresp=bresp_now;

assign #(clk_period/5)  out_rdata=hanming(out_rdata_databit,ecc_error?out_rdata_databit:0);   

// always @( posedge  aclk or negedge aresetn) begin : __rdata//!!!fix me!!!can't syn 考虑prbs
//     if(!aresetn)
//         out_rdata= #(clk_period/5) 'b0;
//     else if(out_rvalid && in_rready)
//         out_rdata= #(clk_period/5) out_rdata+1;    
// end

always @( posedge  aclk or negedge aresetn) begin : __rdata_databit//!!!fix me!!!can't syn 考虑prbs
    if(!aresetn)
        out_rdata_databit= #(clk_period/5) 'b0;
    else if(out_rvalid && in_rready)
        out_rdata_databit= #(clk_period/5) out_rdata_databit+1;    
end

always @( posedge  aclk or negedge aresetn) begin : __rresp//!!!fix me!!!can't syn 考虑prbs
    if(!aresetn)
        out_rresp= #(clk_period/5) 2'b00;
    else if(out_rvalid && in_rready)
        out_rresp= #(clk_period/5) 2'b00;    
end
always_ff @( posedge  aclk or negedge aresetn) begin : __out_awready
    if(!aresetn)
        out_awready <= #(clk_period/5) 'b0;
    else if(always_ready)
        out_awready<= #(clk_period/5) 1;
    else 
        out_awready<=#(clk_period/5)  $random;//!!!!fixme !!!!完全随机！！！！
    end

always_ff @( posedge  aclk or negedge aresetn) begin : __out_wready
    if(!aresetn)
        out_wready <= #(clk_period/5) 'b0;
    else if(always_ready)
        out_wready<= #(clk_period/5) 1;
    else
        out_wready<=#(clk_period/5)  $random;//!!!!fixme !!!!完全随机！！！！
    end

always_ff @( posedge  aclk or negedge aresetn) begin : __out_arready
    if(!aresetn)
        out_arready <= #(clk_period/5) 'b0;
    else 
        out_arready<=#(clk_period/5)  $random;//!!!!fixme !!!!完全随机！！！！
    end
//<<<

endmodule
