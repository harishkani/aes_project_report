`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// AES SubBytes 32-bit - SHARED COMPOSITE FIELD VERSION
// Uses 4 shared S-boxes (instead of 8 separate)
// Combines forward/inverse with enc_dec control
// ~50% reduction vs separate S-boxes
////////////////////////////////////////////////////////////////////////////////

module aes_subbytes_32bit_shared(
    input  wire [31:0] data_in,
    input  wire        enc_dec,     // 1=encrypt (forward), 0=decrypt (inverse)
    output wire [31:0] data_out
);

////////////////////////////////////////////////////////////////////////////////
// 4 Shared Composite Field S-boxes
// Each S-box handles both forward and inverse based on enc_dec
////////////////////////////////////////////////////////////////////////////////

aes_sbox_composite_field sbox0 (
    .data_in(data_in[31:24]),
    .enc_dec(enc_dec),
    .data_out(data_out[31:24])
);

aes_sbox_composite_field sbox1 (
    .data_in(data_in[23:16]),
    .enc_dec(enc_dec),
    .data_out(data_out[23:16])
);

aes_sbox_composite_field sbox2 (
    .data_in(data_in[15:8]),
    .enc_dec(enc_dec),
    .data_out(data_out[15:8])
);

aes_sbox_composite_field sbox3 (
    .data_in(data_in[7:0]),
    .enc_dec(enc_dec),
    .data_out(data_out[7:0])
);

endmodule
