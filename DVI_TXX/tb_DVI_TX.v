`timescale 1ns/1ps

module tb_DVI_TX;

reg         I_clk_RGB;
reg         I_clk_serial;
reg         rst_n;

reg         I_hs;
reg         I_vs;
reg         I_de;
reg  [23:0] I_data;

wire        O_tmds_clk_p;
wire        O_tmds_clk_n;
wire [2:0]  O_tmds_data_p;
wire [2:0]  O_tmds_data_n;


/* DUT */
DVI_TX dut (
    .I_clk_serial   (I_clk_serial),
    .I_clk_RGB      (I_clk_RGB),
    .rst_n          (rst_n),
    .I_hs           (I_hs),
    .I_vs           (I_vs),
    .I_de           (I_de),
    .I_data         (I_data),

    .O_tmds_clk_p   (O_tmds_clk_p),
    .O_tmds_clk_n   (O_tmds_clk_n),
    .O_tmds_data_p  (O_tmds_data_p),
    .O_tmds_data_n  (O_tmds_data_n)
);


/*
 * RGB pixel clock
 *
 * 27 MHz
 * Period = 37.037 ns
 */
initial begin
    I_clk_RGB = 1'b0;

    forever
        #18.518 I_clk_RGB = ~I_clk_RGB;
end


/*
 * Serial clock
 *
 * 270 MHz
 * Period = 3.7037 ns
 *
 * This is approximately 10x the RGB clock.
 */
initial begin
    I_clk_serial = 1'b0;

    forever
        #1.85185 I_clk_serial = ~I_clk_serial;
end


/*
 * Test sequence
 */
initial begin

    rst_n   = 1'b0;

    I_hs    = 1'b0;
    I_vs    = 1'b0;
    I_de    = 1'b0;
    I_data  = 24'h000000;

    /* Reset */
    #100;

    rst_n = 1'b1;

    /*
     * ------------------------------------------------
     * Test 1: Blank period
     * ------------------------------------------------
     */
    @(posedge I_clk_RGB);

    I_de   = 1'b0;
    I_hs   = 1'b0;
    I_vs   = 1'b0;
    I_data = 24'h000000;

    repeat (4)
        @(posedge I_clk_RGB);


    /*
     * ------------------------------------------------
     * Test 2: Control period
     * HS = 1
     * VS = 0
     *
     * Expected blue TMDS control code:
     * C1 C0 = 01
     * M_1 = 1101010100
     * ------------------------------------------------
     */

    I_de = 1'b0;
    I_hs = 1'b1;
    I_vs = 1'b0;

    repeat (4)
        @(posedge I_clk_RGB);


    /*
     * ------------------------------------------------
     * Test 3: First RGB pixel
     * ------------------------------------------------
     */

    I_de   = 1'b1;
    I_hs   = 1'b0;
    I_vs   = 1'b0;

    I_data = 24'hFF0000;       // RED

    @(posedge I_clk_RGB);


    /*
     * ------------------------------------------------
     * Test 4: GREEN
     * ------------------------------------------------
     */

    I_data = 24'h00FF00;

    @(posedge I_clk_RGB);


    /*
     * ------------------------------------------------
     * Test 5: BLUE
     * ------------------------------------------------
     */

    I_data = 24'h0000FF;

    @(posedge I_clk_RGB);


    /*
     * ------------------------------------------------
     * Test 6: WHITE
     * ------------------------------------------------
     */

    I_data = 24'hFFFFFF;

    @(posedge I_clk_RGB);


    /*
     * ------------------------------------------------
     * Test 7: BLACK
     * ------------------------------------------------
     */

    I_data = 24'h000000;

    @(posedge I_clk_RGB);


    /*
     * ------------------------------------------------
     * End active video
     * ------------------------------------------------
     */

    I_de = 1'b0;

    repeat (10)
        @(posedge I_clk_RGB);


    /*
     * Finish
     */

    #100;

    $finish;

end


/*
 * Monitor RGB-side signals
 */
always @(posedge I_clk_RGB) begin

    $display(
        "TIME=%0t | DE=%b HS=%b VS=%b RGB=%h | TMDS=%b",
        $time,
        I_de,
        I_hs,
        I_vs,
        I_data,
        O_tmds_data_p
    );

end


/*
 * VCD waveform
 */
initial begin

    $dumpfile("tb_DVI_TX.vcd");

    $dumpvars(0, tb_DVI_TX);

end

endmodule