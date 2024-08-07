`include "macro.vh"
module ahb_slv_responder #(
    //para>>>
    parameter always_ready=0,
    parameter AXI_ADDR_W = 32,
    //主机输入ID宽度
    parameter AXI_ID_W  =4,
    parameter AXI_DATA_W = 32,

    //OSTD REQ NUM
    parameter SLV_OSTDREQ_NUM = 4,
    //The data size of each OSTD REG
    parameter SLV_OSTDREQ_SIZE = 8,

    parameter AWCH_W = 53,
    parameter WCH_W  = 47,
    parameter BCH_W  = 12,
    parameter ARCH_W = 53,
    parameter RCH_W  = 45,
    
    parameter clk_period = 5
    
    )
    //para<<<
    //if>>>
    (
    //clk & rst
    input hclk,
    input hresetn,
    //ahb_side
	//ahb input
	input 		[31:0]		haddr,
	input 		[1:0]		htrans, 
	input 					hwrite,
	input 		[2:0]		hsize,
	input 		[2:0]		hburst,
	input 	 	[63:0]		hwdata,
	input 	 				hbusreq, 
	input 					hlock,

    input       [1:0]            ecc_error,
	//ahb input
	output	logic	[31:0]		hrdata,
	output	logic				hready,
	output	logic	[1:0]		hresp,
	output	logic				hgrant,
	output	logic	[3:0]		hmaster
    );
parameter DATA_BITS = 26;
parameter  PARITY_BITS = 6     ;
parameter k = DATA_BITS;
parameter r = PARITY_BITS;

    //if<<<
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
    else if(errbit==1)
        DataParity[1]=~DataParity[1]; 
        else if(errbit==2)
            DataParity[2:1]=~DataParity[2:1];
            else
                ;


    return DataParity;
endfunction
            
//func<<<  

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
    logic	[26-1:0]		hrdata_databit;
    // logic   out_wlast_prev;
    // logic   out_wvalid_prev;
// //queue 
//     queue [4-1:0]awlen_que[$];

//distributed ram
    logic  [2-1:0]bresp_ram[2**AXI_ID_W-1:0];
    logic  [4-1:0]bid_ram[2**AXI_ID_W-1:0];


    logic  [4-1:0]arlen_ram[SLV_OSTDREQ_NUM-1:0];
    logic  [4-1:0]arid_ram[SLV_OSTDREQ_NUM-1:0];

    //<<<

    always @( posedge  hclk or negedge hresetn) begin : __rdata//!!!fixme!!!can't syn 考虑prbs
        if(!hresetn )
            hrdata_databit<=  'b0;
        else if(!hwrite &&( (htrans==`NONSEQ) || (htrans==`SEQ)) && hready)
            hrdata_databit<=  hrdata_databit+1;
    end

 //output>>>   
//arbiter>>>
always_ff @( posedge  hclk or negedge hresetn) begin : __hgrant
        if(!hresetn)
            hgrant<=#(clk_period/5) 0;
        else if( hbusreq) //fixme 只适用总线上只有一对主从机的情况
            hgrant<=#(clk_period/5) 1;

        //fixme hgrant 又拉低的情况
    end

always_ff @( posedge  hclk or negedge hresetn) begin : __hmaster
        if(!hresetn)
            hmaster<=#(clk_period/5) 0;
        else if( hgrant && hready)
            hmaster<=#(clk_period/5) 1;

    end


//assign #(clk_period/5)  hrdata=hanming(hrdata_databit,ecc_error?hrdata_databit:0);
    assign #(clk_period/5)  hrdata=hanming(hrdata_databit,ecc_error);

always_ff @( posedge  hclk or negedge hresetn) begin : __hready
    if(!hresetn)
        hready <= #(clk_period/5) 'b0;
    else if(always_ready)
        hready <=#(clk_period/5)  1;
    else 
        hready<= 1;//!!!!fixme !!!!不考虑没有ready的情况！！！！
    end

always_ff @( posedge  hclk or negedge hresetn) begin : __hresp
    if(!hresetn)
        hresp<= #(clk_period/5) 'b0;
    else
        hresp<= #(clk_period/5) 'b0;
    // else if(always_ready)
    //     hresp <= 1;
    // else 
    //     hresp<= 1;//!!!!fixme !!!!不考虑没有ready的情况！！！！
    end

//output<<<    

endmodule