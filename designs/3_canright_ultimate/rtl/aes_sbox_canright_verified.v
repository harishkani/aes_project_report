`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// AES S-box - Canright Algorithm (Direct Port from Verified Source)
// Reference: https://github.com/coruus/canright-aes-sboxes
// "A Very Compact S-Box for AES" - David Canright (2005)
//
// This is a direct port of the proven implementation.
//
// All sub-modules are now in separate files for better organization:
// - canright_modules/gf_sq_2.v       : GF(2^2) square
// - canright_modules/gf_sclw_2.v     : GF(2^2) scale by omega
// - canright_modules/gf_sclw2_2.v    : GF(2^2) scale by omega^2
// - canright_modules/gf_muls_2.v     : GF(2^2) multiply with shared factors
// - canright_modules/gf_muls_scl_2.v : GF(2^2) multiply and scale
// - canright_modules/gf_inv_4.v      : GF(2^4) inverse
// - canright_modules/gf_sq_scl_4.v   : GF(2^4) square and scale
// - canright_modules/gf_muls_4.v     : GF(2^4) multiply with shared factors
// - canright_modules/gf_inv_8.v      : GF(2^8) inverse
// - canright_modules/mux21i.v        : Inverting 2:1 multiplexor
// - canright_modules/select_not_8.v  : 8-bit select and invert
// - canright_modules/bsbox.v         : Core Canright S-box implementation
////////////////////////////////////////////////////////////////////////////////

// Include all sub-modules
`include "canright_modules/gf_sq_2.v"
`include "canright_modules/gf_sclw_2.v"
`include "canright_modules/gf_sclw2_2.v"
`include "canright_modules/gf_muls_2.v"
`include "canright_modules/gf_muls_scl_2.v"
`include "canright_modules/gf_inv_4.v"
`include "canright_modules/gf_sq_scl_4.v"
`include "canright_modules/gf_muls_4.v"
`include "canright_modules/gf_inv_8.v"
`include "canright_modules/mux21i.v"
`include "canright_modules/select_not_8.v"
`include "canright_modules/bsbox.v"

// Top-level wrapper with standard interface
module aes_sbox_canright_verified(
    input  wire [7:0] data_in,
    input  wire       enc_dec,  // 1=encrypt, 0=decrypt
    output wire [7:0] data_out
);

bSbox sbox_inst(
    .A(data_in),
    .encrypt(enc_dec),
    .Q(data_out)
);

endmodule
