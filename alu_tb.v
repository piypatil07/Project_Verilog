`timescale 1ns/1ps
module alu_tb;
    parameter N = 8;
    localparam SHW = (N > 1) ? $clog2(N) : 1;

    reg  [N-1:0] a, b;
    reg  [2:0]   op;
    wire [N-1:0] y;
    wire carry, overflow, zero, negative;

    alu #(.N(N)) dut (.a(a), .b(b), .op(op), .y(y),
                      .carry(carry), .overflow(overflow),
                      .zero(zero), .negative(negative));

    reg [N-1:0] expected;
    integer i, errors;

    initial begin
        errors = 0;
        for (i = 0; i < 5000; i = i + 1) begin
            a  = $urandom;
            b  = $urandom;
            op = $urandom % 7;
            #1;
            case (op)
                3'b000: expected = a + b;
                3'b001: expected = a - b;
                3'b010: expected = a & b;
                3'b011: expected = a | b;
                3'b100: expected = a ^ b;
                3'b101: expected = a << b[SHW-1:0];
                3'b110: expected = a >> b[SHW-1:0];
                default: expected = 0;
            endcase
            if (y !== expected || zero !== (expected == 0)) begin
                errors = errors + 1;
                $display("FAIL op=%b a=%0d b=%0d y=%0d exp=%0d", op, a, b, y, expected);
            end
        end
        if (errors == 0) $display("PASS: N=%0d, all tests OK", N);
        $finish;
    end
endmodule