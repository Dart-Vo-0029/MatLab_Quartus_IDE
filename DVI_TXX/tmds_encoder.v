module tmds_encoder (
    input        I_clk,
    input        serial_clk,
    input        rst_n,
    input  [7:0]  I_data,
    input        C0,
    input        C1,
    input        De,
    output reg   O_channel
);

localparam [9:0] M_0 = 10'b0010101011;
localparam [9:0] M_1 = 10'b1101010100;
localparam [9:0] M_2 = 10'b0010101010;
localparam [9:0] M_3 = 10'b1101010101;

reg  [9:0] Out_data;
reg  [9:0] ready;
reg  [5:0] disparity;

wire [3:0] din_1s;
wire       use_xnor;
wire [7:0] proc_data;
wire [3:0] ones_O_da;
wire signed [4:0] diff_O_da;
reg         inv_O_da;
reg         flag;

assign din_1s  = cnt_1s(I_data);

assign use_xnor =
        (din_1s > 4) ||
        ((din_1s == 4) && (I_data[0] == 1'b0));

assign proc_data = q_m(I_data, use_xnor);

assign ones_O_da = cnt_1s(proc_data);

assign diff_O_da = (ones_O_da << 1) - 5'd8;

always @(*) begin
    inv_O_da = 1'b0;
    flag     = 1'b0;

    if (disparity == 0 && ones_O_da == 4) begin
        inv_O_da = use_xnor;
        flag     = 1'b0;
    end
    else begin
        flag = 1'b1;

        if ((disparity > 0 && ones_O_da > 4) ||
            (disparity < 0 && ones_O_da < 4))
            inv_O_da = 1'b1;
        else
            inv_O_da = 1'b0;
    end
end


always @(posedge I_clk or negedge rst_n) begin
    if (!rst_n) begin
        Out_data  <= 10'b0;
        disparity <= 6'sd0;
    end
    else begin
        if (De) begin
            Out_data <= {
                inv_O_da,
                ~use_xnor,
                (use_xnor ? ~proc_data : proc_data)
            };

            if (inv_O_da)
                disparity <= disparity - diff_O_da;
            else
                disparity <= disparity + diff_O_da;

        end
        else begin

            disparity <= 6'sd0;

            case ({C1, C0})
                2'b00: Out_data <= M_0;
                2'b01: Out_data <= M_1;
                2'b10: Out_data <= M_2;
                2'b11: Out_data <= M_3;
            endcase
        end
    end
end



always @(posedge serial_clk) begin
    ready <=Out_data;
    if (De) begin
        O_channel <= ready[0];
        ready     <= {1'b0, ready[9:1]};
    end
end


function [3:0] cnt_1s(input [7:0] data);
    integer i;
    begin
        cnt_1s = 4'd0;

        for (i = 0; i < 8; i = i + 1)
            cnt_1s = cnt_1s + data[i];
    end
endfunction


function [3:0] cnt_0s(input [7:0] data);
    integer i;
    begin
        cnt_0s = 4'd0;

        for (i = 0; i < 8; i = i + 1)
            cnt_0s = cnt_0s + ~data[i];
    end
endfunction


function [7:0] q_m(
    input [7:0] data,
    input       sel
);
    integer i;

    begin
        q_m[0] = data[0];

        if (!sel) begin
            for (i = 1; i < 8; i = i + 1)
                q_m[i] = q_m[i-1] ^ data[i];
        end
        else begin
            for (i = 1; i < 8; i = i + 1)
                q_m[i] = ~(q_m[i-1] ^ data[i]);
        end
    end
endfunction

endmodule

/*module tmds_encoder(
    input I_clk,
    input serial_clk,
    input rst_n,
    input [7:0] I_data,
    input C0,
    input C1,
    input De,
    output O_channel
) ;
localparam M_0= 10'b0010101011;
localparam M_1= 10'b1101010100;
localparam M_2= 10'b0010101010;
localparam M_3= 10'b1101010101;

reg [9:0] Out_data;
reg [9:0] ready;
reg expo_da;
wire [7:0] proc_data;
wire [3:0] din_1s;
wire use_xnor;
wire [5:0] disparity=6'd32;
wire [3:0] ones_O_da;
wire [4:0] diff_O_da;
wire inv_O_da;
wire flag;

assign din_1s    =cnt_1s(I_data);
assign use_xnor   =din_1s >4 || din_1s ==4 && I_data[0]==0;
assign proc_data =q_m(I_data, use_xnor);
assign ones_O_da =cnt1s(q_m);
assign diff_O_da = ones_O_da<<1 -5'd8;

assign O_channel =expo_da;
always @(*) begin
    if(disparity -32 ==0 & ones_O_data==4) begin
        inv_O_da =use_xnor;
            flag = 1'b0;
    end else begin 
        inv_O_da = disparity-32>0 && ones_O_da>4 || disparity-32 <0 & ones_O_da<4;
        flag =1'b1;
    end
end
always @(posedge I_clk or negedge rst_n) begin
    if(rst_n) begin
        Out_data <=0;
        disparity <=0;
    end else begin
        if(De) begin 
            Out_data <= {inv_O_da,~use_xnor, use_xnor?~ proc_data:proc_data};
            disparity<= disparity+ (inv_O_da ? -diff_O_da : diff_O_da)+(~use_xnor && inv_O_da && flag? 6'd2: use_xnor && ~inv_O_da && flag?- 6'd2:0); 
        end else begin
            disparity <=0;
            case(C1,C0) begin 
                00: Out_data <= M_0;
                01: Out_data <= M_1;
                10: Out_data <= M_2;
                11: Out_data <= M_3;
            endcase
        end
    end 
end 
always @(posedge serial_clk) begin 
    ready <=Out_data;
    if (De) begin 
        ready <= {1'b0,ready[9:1]};
        expo_da <=ready[0];
    end  
end
    
function [3:0] cnt_1s(input [7:0]data); 
    begin cnt1s=4'd0;
    genvar i;
    for (i=0;i<8;i=i+1) begin  
        cnt1s=cnt1s+data[i];
        end
    end
endfunction
function [3:0] cnt_0s(input [7:0]data); 
    begin cnt1s=4'd0;
    genvar i;
    for (i=0;i<8;i=i+1) begin  
        cnt1s=cnt1s+ ~data[i];
        end
    end
endfunction

function [7:0] q_m (input [7:0] data, input sel);
    begin q_m[0]=data[0];
    genvar i;
    if(!sel) begin
        for (i =1;i<8;i=i+1) begin 
            q_m[i]=q_m[i-1] ^ data[i];
        end
    end else begin 
         for (i =1;i<8;i=i+1) begin 
            q_m[i]=~(q_m[i-1] ^ data[i]);
        end
    end
    endfunction
endmodule
*/
        
    
