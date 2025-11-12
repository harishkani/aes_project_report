`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// 32-bit SubBytes with 4 Shared LUT-based S-boxes
// Uses proven LUT S-boxes instead of composite field
// For verification and testing of ultimate architecture
////////////////////////////////////////////////////////////////////////////////

module aes_subbytes_32bit_lut_shared(
    input  wire [31:0] data_in,
    input  wire        enc_dec,  // 1=encrypt, 0=decrypt
    output wire [31:0] data_out
);

// Forward S-box outputs (encryption)
wire [7:0] fwd_out0, fwd_out1, fwd_out2, fwd_out3;

// Inverse S-box outputs (decryption)
wire [7:0] inv_out0, inv_out1, inv_out2, inv_out3;

// Instantiate forward S-boxes
aes_sbox fwd_sbox0 (.data_in(data_in[31:24]), .data_out(fwd_out0));
aes_sbox fwd_sbox1 (.data_in(data_in[23:16]), .data_out(fwd_out1));
aes_sbox fwd_sbox2 (.data_in(data_in[15:8]),  .data_out(fwd_out2));
aes_sbox fwd_sbox3 (.data_in(data_in[7:0]),   .data_out(fwd_out3));

// Instantiate inverse S-boxes
aes_inv_sbox inv_sbox0 (.data_in(data_in[31:24]), .data_out(inv_out0));
aes_inv_sbox inv_sbox1 (.data_in(data_in[23:16]), .data_out(inv_out1));
aes_inv_sbox inv_sbox2 (.data_in(data_in[15:8]),  .data_out(inv_out2));
aes_inv_sbox inv_sbox3 (.data_in(data_in[7:0]),   .data_out(inv_out3));

// Mux based on enc_dec signal
assign data_out[31:24] = enc_dec ? fwd_out0 : inv_out0;
assign data_out[23:16] = enc_dec ? fwd_out1 : inv_out1;
assign data_out[15:8]  = enc_dec ? fwd_out2 : inv_out2;
assign data_out[7:0]   = enc_dec ? fwd_out3 : inv_out3;

endmodule
