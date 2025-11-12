`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// 32-bit SubBytes with Composite Field S-boxes
// Wrapper that uses 4 composite S-boxes for both enc/dec
// NOTE: Currently using LUT-based for reliability until composite is debugged
////////////////////////////////////////////////////////////////////////////////

module aes_subbytes_32bit_composite(
    input  wire [31:0] data_in,
    input  wire        enc_dec,  // 1=encrypt, 0=decrypt
    output wire [31:0] data_out
);

// For now, use proven LUT-based S-boxes with proper muxing
// This ensures the architecture works while composite field is being debugged

// Forward S-box outputs (encryption)
wire [7:0] fwd_out0, fwd_out1, fwd_out2, fwd_out3;

// Inverse S-box outputs (decryption)
wire [7:0] inv_out0, inv_out1, inv_out2, inv_out3;

// Instantiate forward S-boxes
aes_sbox fwd_sbox0 (.in(data_in[31:24]), .out(fwd_out0));
aes_sbox fwd_sbox1 (.in(data_in[23:16]), .out(fwd_out1));
aes_sbox fwd_sbox2 (.in(data_in[15:8]),  .out(fwd_out2));
aes_sbox fwd_sbox3 (.in(data_in[7:0]),   .out(fwd_out3));

// Instantiate inverse S-boxes
aes_inv_sbox inv_sbox0 (.in(data_in[31:24]), .out(inv_out0));
aes_inv_sbox inv_sbox1 (.in(data_in[23:16]), .out(inv_out1));
aes_inv_sbox inv_sbox2 (.in(data_in[15:8]),  .out(inv_out2));
aes_inv_sbox inv_sbox3 (.in(data_in[7:0]),   .out(inv_out3));

// Mux based on enc_dec signal
assign data_out[31:24] = enc_dec ? fwd_out0 : inv_out0;
assign data_out[23:16] = enc_dec ? fwd_out1 : inv_out1;
assign data_out[15:8]  = enc_dec ? fwd_out2 : inv_out2;
assign data_out[7:0]   = enc_dec ? fwd_out3 : inv_out3;

endmodule
