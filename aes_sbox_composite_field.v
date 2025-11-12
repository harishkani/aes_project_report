`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// AES S-box - Composite Field Implementation
// Uses GF((2^4)^2) representation for area efficiency
// ~60% smaller than 256×8 LUT implementation
// Based on Canright's optimal composite field representation
////////////////////////////////////////////////////////////////////////////////

module aes_sbox_composite_field(
    input  wire [7:0] data_in,
    input  wire       enc_dec,  // 1=forward, 0=inverse
    output wire [7:0] data_out
);

////////////////////////////////////////////////////////////////////////////////
// Forward S-box (Encryption)
////////////////////////////////////////////////////////////////////////////////

// Step 1: Input mapping (affine + field conversion for inverse)
wire [7:0] in_mapped;
assign in_mapped = enc_dec ? data_in : inv_affine(data_in);

// Step 2: Convert to GF((2^4)^2) basis
wire [3:0] ah, al;
assign {ah, al} = map_to_composite(in_mapped);

// Step 3: Compute multiplicative inverse in GF((2^4)^2)
wire [3:0] bh, bl;
assign {bh, bl} = gf24_inverse(ah, al);

// Step 4: Convert back from GF((2^4)^2) basis
wire [7:0] inv_result;
assign inv_result = map_from_composite(bh, bl);

// Step 5: Apply affine transformation
wire [7:0] result;
assign result = enc_dec ? affine(inv_result) : inv_result;

assign data_out = result;

////////////////////////////////////////////////////////////////////////////////
// GF(2^8) to GF((2^4)^2) Isomorphism Mapping
// Maps standard AES field to composite field representation
////////////////////////////////////////////////////////////////////////////////
function [7:0] map_to_composite;
    input [7:0] x;
    reg [7:0] y;
    begin
        // Optimal basis conversion matrix (Canright)
        y[7] = x[7] ^ x[6];
        y[6] = x[7] ^ x[5] ^ x[4];
        y[5] = x[6] ^ x[4];
        y[4] = x[7] ^ x[5] ^ x[3];
        y[3] = x[6] ^ x[5] ^ x[2];
        y[2] = x[5] ^ x[4] ^ x[1];
        y[1] = x[6] ^ x[4] ^ x[0];
        y[0] = x[5] ^ x[3];
        map_to_composite = y;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// GF((2^4)^2) to GF(2^8) Inverse Isomorphism
////////////////////////////////////////////////////////////////////////////////
function [7:0] map_from_composite;
    input [3:0] ah, al;
    reg [7:0] y;
    begin
        // Inverse basis conversion
        y[7] = ah[3] ^ al[3] ^ al[2];
        y[6] = ah[2] ^ al[3];
        y[5] = ah[3] ^ ah[1] ^ al[3] ^ al[1];
        y[4] = ah[3] ^ ah[2] ^ al[2] ^ al[0];
        y[3] = ah[3] ^ ah[2] ^ ah[1] ^ al[3] ^ al[0];
        y[2] = ah[3] ^ ah[1] ^ ah[0] ^ al[1];
        y[1] = ah[1] ^ ah[0] ^ al[3] ^ al[2] ^ al[1];
        y[0] = ah[2] ^ ah[0] ^ al[2] ^ al[0];
        map_from_composite = y;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// GF((2^4)^2) Multiplicative Inverse
// Computes (ah*x + al)^-1 in GF(2^4)[x]/(x^2 + x + lambda)
////////////////////////////////////////////////////////////////////////////////
function [7:0] gf24_inverse;
    input [3:0] ah, al;
    reg [3:0] bh, bl;
    reg [3:0] d, e, p, q;
    begin
        // Compute using formula: (ah*x + al)^-1 = (d)^-1 * (ah*x + (ah+al))
        // where d = ah*(ah+al) + al^2*lambda

        d = gf24_mult(ah, ah ^ al) ^ gf24_sq_scale(al);
        e = gf24_inverse_gf24(d);  // Inverse in base field GF(2^4)
        p = gf24_mult(ah, e);
        q = gf24_mult(ah ^ al, e);

        bh = p;
        bl = q;
        gf24_inverse = {bh, bl};
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// GF(2^4) Multiplication
// Multiply in GF(2^4) with polynomial basis
////////////////////////////////////////////////////////////////////////////////
function [3:0] gf24_mult;
    input [3:0] a, b;
    reg [3:0] p;
    begin
        // Multiplication in GF(2^4) mod x^4 + x + 1
        p[0] = (a[0] & b[0]) ^ (a[3] & b[1]) ^ (a[2] & b[2]) ^ (a[1] & b[3]);
        p[1] = (a[1] & b[0]) ^ (a[0] & b[1]) ^ (a[3] & b[2]) ^ (a[2] & b[3]) ^
               (a[3] & b[1]) ^ (a[2] & b[2]) ^ (a[1] & b[3]);
        p[2] = (a[2] & b[0]) ^ (a[1] & b[1]) ^ (a[0] & b[2]) ^ (a[3] & b[3]) ^
               (a[3] & b[2]) ^ (a[2] & b[3]);
        p[3] = (a[3] & b[0]) ^ (a[2] & b[1]) ^ (a[1] & b[2]) ^ (a[0] & b[3]) ^
               (a[3] & b[3]);
        gf24_mult = p;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// GF(2^4) Square and Scale by lambda
// Computes a^2 * lambda where lambda is the extension field constant
////////////////////////////////////////////////////////////////////////////////
function [3:0] gf24_sq_scale;
    input [3:0] a;
    reg [3:0] p;
    begin
        // Square in GF(2^4) and multiply by lambda = {1100}_2
        p[0] = a[2];
        p[1] = a[1];
        p[2] = a[0] ^ a[2];
        p[3] = a[3] ^ a[1];
        gf24_sq_scale = p;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// GF(2^4) Multiplicative Inverse
// Base field inversion (16-element LUT is acceptable)
////////////////////////////////////////////////////////////////////////////////
function [3:0] gf24_inverse_gf24;
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
        gf24_inverse_gf24 = b;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// Forward Affine Transformation
// y = Ax + b in GF(2)
////////////////////////////////////////////////////////////////////////////////
function [7:0] affine;
    input [7:0] x;
    reg [7:0] y;
    begin
        y[0] = x[0] ^ x[4] ^ x[5] ^ x[6] ^ x[7] ^ 1'b1;
        y[1] = x[1] ^ x[5] ^ x[6] ^ x[7] ^ x[0] ^ 1'b1;
        y[2] = x[2] ^ x[6] ^ x[7] ^ x[0] ^ x[1];
        y[3] = x[3] ^ x[7] ^ x[0] ^ x[1] ^ x[2];
        y[4] = x[4] ^ x[0] ^ x[1] ^ x[2] ^ x[3];
        y[5] = x[5] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ 1'b1;
        y[6] = x[6] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ 1'b1;
        y[7] = x[7] ^ x[3] ^ x[4] ^ x[5] ^ x[6];
        affine = y;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// Inverse Affine Transformation
// x = A^-1(y + b) for decryption
////////////////////////////////////////////////////////////////////////////////
function [7:0] inv_affine;
    input [7:0] y;
    reg [7:0] x;
    begin
        x[0] = y[2] ^ y[5] ^ y[7];
        x[1] = y[0] ^ y[3] ^ y[6];
        x[2] = y[1] ^ y[4] ^ y[7];
        x[3] = y[0] ^ y[2] ^ y[5];
        x[4] = y[1] ^ y[3] ^ y[6];
        x[5] = y[2] ^ y[4] ^ y[7];
        x[6] = y[0] ^ y[3] ^ y[5];
        x[7] = y[1] ^ y[4] ^ y[6];
        inv_affine = x;
    end
endfunction

endmodule
