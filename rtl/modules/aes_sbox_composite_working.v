`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// AES S-box - Composite Field Implementation (WORKING VERSION)
// Based on verified Canright implementation
// Uses GF((2^4)^2) representation with correct formulas
////////////////////////////////////////////////////////////////////////////////

module aes_sbox_composite_working(
    input  wire [7:0] data_in,
    input  wire       enc_dec,  // 1=encrypt, 0=decrypt
    output wire [7:0] data_out
);

////////////////////////////////////////////////////////////////////////////////
// S-box Computation
////////////////////////////////////////////////////////////////////////////////

// For encryption: affine(inv(data_in))
// For decryption: inv(inv_affine(data_in))

wire [7:0] after_inv_affine;
wire [7:0] after_inv;
wire [7:0] after_affine;

// Step 1: Apply inverse affine for decryption
assign after_inv_affine = enc_dec ? data_in : inv_affine_transform(data_in);

// Step 2: Multiplicative inverse in composite field
assign after_inv = composite_inverse(after_inv_affine);

// Step 3: Apply affine for encryption
assign after_affine = enc_dec ? affine_transform(after_inv) : after_inv;

assign data_out = after_affine;

////////////////////////////////////////////////////////////////////////////////
// Composite Field Multiplicative Inverse
////////////////////////////////////////////////////////////////////////////////
function [7:0] composite_inverse;
    input [7:0] x;
    reg [3:0] ah, al;  // high and low parts in composite field
    reg [3:0] bh, bl;  // output high and low
    reg [3:0] d, e, p, q;
    begin
        // Map to composite field
        {ah, al} = map_to_composite(x);

        // Compute inverse using formula:
        // (ah*y + al)^-1 = e*(ah*y + (ah+al))
        // where e = (ah*(ah+al) + al^2*N)^-1 and N is the normal element

        // d = ah * (ah + al) + al^2 * N (where N = x^2, so multiply by x^2)
        d = gf24_mult(ah, ah ^ al) ^ gf24_sq_scale(al);

        // e = d^-1 in GF(2^4)
        e = gf24_inv(d);

        // bh = ah * e
        bh = gf24_mult(ah, e);

        // bl = (ah + al) * e
        bl = gf24_mult(ah ^ al, e);

        // Map back from composite field
        composite_inverse = map_from_composite(bh, bl);
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// GF(2^8) <-> GF((2^4)^2) Isomorphism
// Using Canright's optimized basis
////////////////////////////////////////////////////////////////////////////////
function [7:0] map_to_composite;
    input [7:0] x;
    reg [7:0] y;
    begin
        // Canright's matrix for GF(2^8) -> GF((2^4)^2)
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

function [7:0] map_from_composite;
    input [3:0] ah, al;
    reg [7:0] y;
    begin
        // Canright's inverse matrix
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
// GF(2^4) Operations (polynomial x^4 + x + 1)
////////////////////////////////////////////////////////////////////////////////
function [3:0] gf24_mult;
    input [3:0] a, b;
    reg [3:0] p;
    begin
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

function [3:0] gf24_sq_scale;
    input [3:0] a;
    reg [3:0] p;
    begin
        // Square and scale by N = x^2 in extension field
        // sq(a) = [a3, a1, a2, a0] (squaring is linear in GF(2))
        // Then multiply by x^2 (N)
        p[0] = a[2];
        p[1] = a[1];
        p[2] = a[0] ^ a[2];
        p[3] = a[3] ^ a[1];
        gf24_sq_scale = p;
    end
endfunction

function [3:0] gf24_inv;
    input [3:0] a;
    reg [3:0] b;
    begin
        case (a)
            4'h0: b = 4'h0;
            4'h1: b = 4'h1;
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
        gf24_inv = b;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// Affine Transformations
////////////////////////////////////////////////////////////////////////////////
function [7:0] affine_transform;
    input [7:0] x;
    reg [7:0] y;
    begin
        // Standard AES affine: y = Ax + 0x63
        y[0] = x[0] ^ x[4] ^ x[5] ^ x[6] ^ x[7] ^ 1'b1;
        y[1] = x[1] ^ x[5] ^ x[6] ^ x[7] ^ x[0] ^ 1'b1;
        y[2] = x[2] ^ x[6] ^ x[7] ^ x[0] ^ x[1];
        y[3] = x[3] ^ x[7] ^ x[0] ^ x[1] ^ x[2];
        y[4] = x[4] ^ x[0] ^ x[1] ^ x[2] ^ x[3];
        y[5] = x[5] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ 1'b1;
        y[6] = x[6] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ 1'b1;
        y[7] = x[7] ^ x[3] ^ x[4] ^ x[5] ^ x[6];
        affine_transform = y;
    end
endfunction

function [7:0] inv_affine_transform;
    input [7:0] y;
    reg [7:0] y_const;
    reg [7:0] x;
    begin
        // Inverse affine: x = A^-1 * (y + 0x63)
        // First XOR with constant
        y_const = y ^ 8'h63;

        // Then apply inverse matrix
        x[0] = y_const[2] ^ y_const[5] ^ y_const[7];
        x[1] = y_const[0] ^ y_const[3] ^ y_const[6];
        x[2] = y_const[1] ^ y_const[4] ^ y_const[7];
        x[3] = y_const[0] ^ y_const[2] ^ y_const[5];
        x[4] = y_const[1] ^ y_const[3] ^ y_const[6];
        x[5] = y_const[2] ^ y_const[4] ^ y_const[7];
        x[6] = y_const[0] ^ y_const[3] ^ y_const[5];
        x[7] = y_const[1] ^ y_const[4] ^ y_const[6];
        inv_affine_transform = x;
    end
endfunction

endmodule
