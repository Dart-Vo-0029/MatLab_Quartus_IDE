module Single_p #(
    parameter Addr_Width  = 21600,
    parameter Data_Width = 8
)(
    input clk, rst,
    input oce, ce,
    input [$clog2(Addr_Width) - 1:0] ad,
    input we,
    input [Data_Width-1:0] Din,
    output [Data_Width-1:0] Dout
);

reg [Data_Width-1:0] mem [0:Addr_Width-1];

reg [Data_Width-1:0] Do_pipe;
reg [Data_Width-1:0] Do;

initial begin
    $readmemh("image3.mem", mem);
end

always @(negedge clk) begin
    if (rst) begin
        Do_pipe <= 16'd0;
    end else if (ce) begin
        if (we) begin
            mem[ad] <= Din;
            Do_pipe <= Din;        // write-through
        end else begin
            Do_pipe <= mem[ad];   // read
        end

    end
end
always @(posedge clk) begin //output delay 1 cycle
            if (oce)
            Do <= Do_pipe;
end

assign Dout = Do;


endmodule