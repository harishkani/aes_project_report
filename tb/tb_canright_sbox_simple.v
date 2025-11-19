`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Simple Testbench for Canright S-box
// Tests basic S-box functionality with known NIST test vectors
////////////////////////////////////////////////////////////////////////////////

module tb_canright_sbox_simple;

reg  [7:0] data_in;
reg        enc_dec;
wire [7:0] data_out;

// Instantiate the Canright S-box
aes_sbox_canright_verified dut (
    .data_in(data_in),
    .enc_dec(enc_dec),
    .data_out(data_out)
);

integer pass_count, fail_count;

initial begin
    $display("\n========================================");
    $display("Canright S-box Standalone Test");
    $display("========================================\n");

    pass_count = 0;
    fail_count = 0;
    enc_dec = 1'b1; // Test encryption S-box

    #10;

    // Test a few known S-box values (encryption)
    // S-box(0x00) = 0x63
    data_in = 8'h00;
    #10;
    $display("S-box(0x%02h) = 0x%02h (expected 0x63)", data_in, data_out);
    if (data_out === 8'h63) pass_count = pass_count + 1;
    else fail_count = fail_count + 1;

    // S-box(0x01) = 0x7c
    data_in = 8'h01;
    #10;
    $display("S-box(0x%02h) = 0x%02h (expected 0x7c)", data_in, data_out);
    if (data_out === 8'h7c) pass_count = pass_count + 1;
    else fail_count = fail_count + 1;

    // S-box(0x53) = 0xed
    data_in = 8'h53;
    #10;
    $display("S-box(0x%02h) = 0x%02h (expected 0xed)", data_in, data_out);
    if (data_out === 8'hed) pass_count = pass_count + 1;
    else fail_count = fail_count + 1;

    // S-box(0xff) = 0x16
    data_in = 8'hff;
    #10;
    $display("S-box(0x%02h) = 0x%02h (expected 0x16)", data_in, data_out);
    if (data_out === 8'h16) pass_count = pass_count + 1;
    else fail_count = fail_count + 1;

    // Test inverse S-box
    enc_dec = 1'b0;
    #10;

    // InvS-box(0x63) = 0x00
    data_in = 8'h63;
    #10;
    $display("InvS-box(0x%02h) = 0x%02h (expected 0x00)", data_in, data_out);
    if (data_out === 8'h00) pass_count = pass_count + 1;
    else fail_count = fail_count + 1;

    // InvS-box(0x7c) = 0x01
    data_in = 8'h7c;
    #10;
    $display("InvS-box(0x%02h) = 0x%02h (expected 0x01)", data_in, data_out);
    if (data_out === 8'h01) pass_count = pass_count + 1;
    else fail_count = fail_count + 1;

    $display("\n========================================");
    $display("Test Summary:");
    $display("  Pass: %0d", pass_count);
    $display("  Fail: %0d", fail_count);
    $display("========================================\n");

    $finish;
end

endmodule
