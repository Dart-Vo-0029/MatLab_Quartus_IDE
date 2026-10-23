module DVI_TX (
    input I_clk_serial,
    input I_clk_RGB,
    input rst_n,
    input I_hs,
    input I_vs,
    input I_de,
    input [23:0] I_data,
    output O_tmds_clk_p,
    output O_tmds_clk_n,
    output [2:0]O_tmds_data_p,
    output [2:0]O_tmds_data_n
);
wire [7:0] rgb_r= I_data [23:16];
wire [7:0] rgb_g= I_data [15:8];
wire [7:0] rgb_b= I_data [7:0];
wire data_r,data_b,data_g;
wire [2:0] tmds_da;

tmds_encoder B_encode(
    .I_clk(I_clk_RGB),
    .serial_clk(I_clk_serial),
    .rst_n(rst_n),
    .I_data(rgb_b),
    .C0 (I_hs),
    .C1 (I_vs),
    .De (I_de),
    .O_channel(data_b)
);
tmds_encoder g_encode(
    .I_clk(I_clk_RGB),
    .serial_clk(I_clk_serial),
    .rst_n(rst_n),
    .I_data(rgb_g),
    .C0 (1'b0),
    .C1 (1'b0),
    .De (I_de),
    .O_channel(data_g)
);
tmds_encoder r_encode(
    .I_clk(I_clk_RGB),
    .serial_clk(I_clk_serial),
    .rst_n(rst_n),
    .I_data(rgb_r),
    .C0 (1'b0),
    .C1 (1'b0),
    .De (I_de),
    .O_channel(data_r)
);
assign O_tmds_data_p ={data_b,data_b,data_r};
assign O_tmds_data_n =~ O_tmds_data_p;
assign O_tmds_clk_p =I_clk_serial;
assign O_tmds_clk_n = ~I_clk_serial;
endmodule
