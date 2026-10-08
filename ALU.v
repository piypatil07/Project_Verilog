module alu #(
    parameter N = 8                 // data width: change to 4, 16, 32...
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire [2:0]   op,
    output reg  [N-1:0] y,
    output reg          carry,
    output reg          overflow,
    output wire         zero,
    output wire         negative
);
    // opcodes
    localparam ADD = 3'b000, SUB = 3'b001, AND_ = 3'b010,
               OR_ = 3'b011, XOR_ = 3'b100, SLL = 3'b101, SRL = 3'b110;

    // number of bits needed to express a shift amount 0..N-1
    localparam SHW = (N > 1) ? $clog2(N) : 1;

    // ---- shared adder/subtractor ----
    wire         sub  = (op == SUB);
    wire [N-1:0] bx   = b ^ {N{sub}};          // invert B when subtracting
    wire [N:0]   asum = {1'b0, a} + {1'b0, bx} + sub;  // N+1 bits keeps carry-out
    // asum[N] = carry out, asum[N-1:0] = N-bit result

    always @* begin
        // defaults (prevents accidental latches)
        y        = {N{1'b0}};
        carry    = 1'b0;
        overflow = 1'b0;

        case (op)
            ADD, SUB: begin
                y        = asum[N-1:0];
                carry    = asum[N];
                // overflow: operands (as seen by the adder) share a sign,
                // but the result's sign differs
                overflow = (a[N-1] == bx[N-1]) && (y[N-1] != a[N-1]);
            end
            AND_: y = a & b;
            OR_:  y = a | b;
            XOR_: y = a ^ b;
            SLL:  y = a << b[SHW-1:0];
            SRL:  y = a >> b[SHW-1:0];
            default: y = {N{1'b0}};
        endcase
    end

    assign zero     = (y == {N{1'b0}});
    assign negative = y[N-1];
endmodule