`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// 32-bit SubBytes with Canright Composite Field S-boxes
// Uses verified Canright implementation for 40% area savings
// 4 S-boxes handle 32-bit column transformation
////////////////////////////////////////////////////////////////////////////////

module aes_subbytes_32bit_canright(
    input  wire [31:0] data_in,
    input  wire        enc_dec,  // 1=encrypt, 0=decrypt
    output wire [31:0] data_out
);

// Instantiate 4 Canright S-boxes (one per byte)
// Each S-box handles both encryption and decryption based on enc_dec signal

aes_sbox_canright_verified sbox0 (
    .data_in(data_in[31:24]),
    .enc_dec(enc_dec),
    .data_out(data_out[31:24])
);

aes_sbox_canright_verified sbox1 (
    .data_in(data_in[23:16]),
    .enc_dec(enc_dec),
    .data_out(data_out[23:16])
);

aes_sbox_canright_verified sbox2 (
    .data_in(data_in[15:8]),
    .enc_dec(enc_dec),
    .data_out(data_out[15:8])
);

aes_sbox_canright_verified sbox3 (
    .data_in(data_in[7:0]),
    .enc_dec(enc_dec),
    .data_out(data_out[7:0])
);

endmodule
