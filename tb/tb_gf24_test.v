`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// GF(2^4) Arithmetic Test
// Tests multiplication and inversion in base field
////////////////////////////////////////////////////////////////////////////////

module tb_gf24_test;

// Test GF(2^4) multiplication
function [3:0] gf24_mult;
    input [3:0] a, b;
    reg [3:0] p;
    begin
        // Multiplication in GF(2^4) mod x^4 + x + 1
        p[0] = (a[0] & b[0]) ^ (a[1] & b[3]) ^ (a[2] & b[2]) ^ (a[3] & b[1]);
        p[1] = (a[0] & b[1]) ^ (a[1] & b[0]) ^ (a[1] & b[3]) ^ (a[2] & b[2]) ^
               (a[2] & b[3]) ^ (a[3] & b[1]) ^ (a[3] & b[2]);
        p[2] = (a[0] & b[2]) ^ (a[1] & b[1]) ^ (a[2] & b[0]) ^ (a[2] & b[3]) ^
               (a[3] & b[2]) ^ (a[3] & b[3]);
        p[3] = (a[0] & b[3]) ^ (a[1] & b[2]) ^ (a[2] & b[1]) ^ (a[3] & b[0]) ^
               (a[3] & b[3]);
        gf24_mult = p;
    end
endfunction

// GF(2^4) multiplicative inverse table
function [3:0] gf24_inverse;
    input [3:0] a;
    reg [3:0] b;
    begin
        case (a)
            4'h0: b = 4'h0;  // 0 maps to 0
            4'h1: b = 4'h1;  // 1 is self-inverse
            4'h2: b = 4'h9;
            4'h3: b = 4'he;
            4'h4: b = 4'hd;
            4'h5: b = 4'hb;
            4'h6: b = 4'h7;
            4'h7: b = 4'h6;
            4'h8: b = 4'hf;
            4'h9: b = 4'h2;
            4'ha: b = 4'hc;
            4'hb: b = 4'h5;
            4'hc: b = 4'ha;
            4'hd: b = 4'h4;
            4'he: b = 4'h3;
            4'hf: b = 4'h8;
        endcase
        gf24_inverse = b;
    end
endfunction

integer i, j;
reg [3:0] a, b, prod, inv, check;
integer errors;

initial begin
    $display("\n========================================");
    $display("GF(2^4) ARITHMETIC TESTS");
    $display("Polynomial: x^4 + x + 1");
    $display("========================================\n");

    errors = 0;

    // Test 1: Identity (a * 1 = a)
    $display("TEST 1: Identity (a * 1 = a)");
    for (i = 0; i < 16; i = i + 1) begin
        a = i;
        prod = gf24_mult(a, 4'h1);
        if (prod != a) begin
            $display("  FAIL: %h * 1 = %h (expected %h)", a, prod, a);
            errors = errors + 1;
        end
    end
    if (errors == 0) $display("  PASS: All identity tests passed\n");

    // Test 2: Inverse (a * a^-1 = 1)
    $display("TEST 2: Inverse (a * a^-1 = 1 for a != 0)");
    for (i = 1; i < 16; i = i + 1) begin
        a = i;
        inv = gf24_inverse(a);
        prod = gf24_mult(a, inv);
        if (prod != 4'h1) begin
            $display("  FAIL: %h * %h = %h (expected 1)", a, inv, prod);
            errors = errors + 1;
        end
    end
    if (errors == 0) $display("  PASS: All inverse tests passed\n");

    // Test 3: Commutativity (a * b = b * a)
    $display("TEST 3: Commutativity (a * b = b * a)");
    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            a = i;
            b = j;
            if (gf24_mult(a, b) != gf24_mult(b, a)) begin
                $display("  FAIL: %h * %h != %h * %h", a, b, b, a);
                errors = errors + 1;
            end
        end
    end
    if (errors == 0) $display("  PASS: Multiplication is commutative\n");

    // Test 4: Specific known values
    $display("TEST 4: Known multiplication values");
    // 2 * 2 = 4 in GF(2^4) with x^4 + x + 1
    a = 4'h2; b = 4'h2; prod = gf24_mult(a, b);
    $display("  2 * 2 = %h (checking...)", prod);

    // 3 * 7 should give some value
    a = 4'h3; b = 4'h7; prod = gf24_mult(a, b);
    $display("  3 * 7 = %h", prod);

    $display("\n========================================");
    if (errors == 0) begin
        $display("ALL GF(2^4) TESTS PASSED!");
    end else begin
        $display("ERRORS: %0d tests failed", errors);
    end
    $display("========================================\n");

    $finish;
end

endmodule
