`timescale 1ns/1ps
module shift_register #(
    parameter WIDTH = 8,
    parameter DEPTH = 4,
    parameter DIR   = 1
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  en,
    input  wire                  load,
    input  wire                  serial_in,
    input  wire [WIDTH-1:0]      parallel_in,
    output wire [WIDTH-1:0]      parallel_out,
    output wire                  serial_out
);

    reg [WIDTH-1:0] stage [0:DEPTH-1];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1)
                stage[i] <= {WIDTH{1'b0}};
        end else if (en) begin
            if (load) begin
                stage[0] <= parallel_in;
                for (i = 1; i < DEPTH; i = i + 1)
                    stage[i] <= stage[i-1];
            end else begin
                if (DIR) begin
                    stage[0] <= {stage[0][WIDTH-2:0], serial_in};
                end else begin
                    stage[0] <= {serial_in, stage[0][WIDTH-1:1]};
                end
                for (i = 1; i < DEPTH; i = i + 1)
                    stage[i] <= stage[i-1];
            end
        end
    end

    assign parallel_out = stage[DEPTH-1];
    assign serial_out   = DIR ? stage[DEPTH-1][WIDTH-1] : stage[DEPTH-1][0];

endmodule