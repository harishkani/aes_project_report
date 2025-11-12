`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Unit Test for Composite Field S-box
// Tests against known AES S-box values
////////////////////////////////////////////////////////////////////////////////

module tb_sbox_unit;

reg [7:0] data_in;
reg enc_dec;
wire [7:0] data_out;

integer i, pass_count, fail_count;
reg [7:0] encrypted;

// DUT
aes_sbox_composite_field_fixed dut (
    .data_in(data_in),
    .enc_dec(enc_dec),
    .data_out(data_out)
);

// Known S-box values (first 16 entries for quick test)
reg [7:0] sbox_table [0:255];
reg [7:0] inv_sbox_table [0:255];

initial begin
    // Initialize complete forward S-box table
    sbox_table[8'h00] = 8'h63; sbox_table[8'h01] = 8'h7c; sbox_table[8'h02] = 8'h77; sbox_table[8'h03] = 8'h7b;
    sbox_table[8'h04] = 8'hf2; sbox_table[8'h05] = 8'h6b; sbox_table[8'h06] = 8'h6f; sbox_table[8'h07] = 8'hc5;
    sbox_table[8'h08] = 8'h30; sbox_table[8'h09] = 8'h01; sbox_table[8'h0a] = 8'h67; sbox_table[8'h0b] = 8'h2b;
    sbox_table[8'h0c] = 8'hfe; sbox_table[8'h0d] = 8'hd7; sbox_table[8'h0e] = 8'hab; sbox_table[8'h0f] = 8'h76;
    sbox_table[8'h10] = 8'hca; sbox_table[8'h11] = 8'h82; sbox_table[8'h12] = 8'hc9; sbox_table[8'h13] = 8'h7d;
    sbox_table[8'h14] = 8'hfa; sbox_table[8'h15] = 8'h59; sbox_table[8'h16] = 8'h47; sbox_table[8'h17] = 8'hf0;
    sbox_table[8'h18] = 8'had; sbox_table[8'h19] = 8'hd4; sbox_table[8'h1a] = 8'ha2; sbox_table[8'h1b] = 8'haf;
    sbox_table[8'h1c] = 8'h9c; sbox_table[8'h1d] = 8'ha4; sbox_table[8'h1e] = 8'h72; sbox_table[8'h1f] = 8'hc0;
    sbox_table[8'h20] = 8'hb7; sbox_table[8'h21] = 8'hfd; sbox_table[8'h22] = 8'h93; sbox_table[8'h23] = 8'h26;
    sbox_table[8'h24] = 8'h36; sbox_table[8'h25] = 8'h3f; sbox_table[8'h26] = 8'hf7; sbox_table[8'h27] = 8'hcc;
    sbox_table[8'h28] = 8'h34; sbox_table[8'h29] = 8'ha5; sbox_table[8'h2a] = 8'he5; sbox_table[8'h2b] = 8'hf1;
    sbox_table[8'h2c] = 8'h71; sbox_table[8'h2d] = 8'hd8; sbox_table[8'h2e] = 8'h31; sbox_table[8'h2f] = 8'h15;

    // Add key test values
    sbox_table[8'h53] = 8'hed;  // S(0x53) = 0xed
    sbox_table[8'h00] = 8'h63;  // S(0x00) = 0x63
    sbox_table[8'hff] = 8'h16;  // S(0xff) = 0x16
    sbox_table[8'haa] = 8'hac;  // S(0xaa) = 0xac

    // Inverse S-box values
    inv_sbox_table[8'h63] = 8'h00;
    inv_sbox_table[8'h7c] = 8'h01;
    inv_sbox_table[8'hed] = 8'h53;
    inv_sbox_table[8'h16] = 8'hff;
    inv_sbox_table[8'hac] = 8'haa;

    $display("\n================================================================================");
    $display("                 AES S-BOX UNIT TEST - Composite Field");
    $display("================================================================================\n");

    pass_count = 0;
    fail_count = 0;

    //=========================================================================
    // Test Forward S-box (Encryption)
    //=========================================================================
    $display("FORWARD S-BOX TESTS (Encryption):");
    $display("----------------------------------");

    enc_dec = 1'b1;  // Encryption mode

    // Test critical values
    data_in = 8'h00; #10;
    if (data_out == 8'h63) begin
        $display("✓ S(0x00) = 0x%02h (expected 0x63)", data_out);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ S(0x00) = 0x%02h (expected 0x63)", data_out);
        fail_count = fail_count + 1;
    end

    data_in = 8'h53; #10;
    if (data_out == 8'hed) begin
        $display("✓ S(0x53) = 0x%02h (expected 0xed)", data_out);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ S(0x53) = 0x%02h (expected 0xed)", data_out);
        fail_count = fail_count + 1;
    end

    data_in = 8'hff; #10;
    if (data_out == 8'h16) begin
        $display("✓ S(0xff) = 0x%02h (expected 0x16)", data_out);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ S(0xff) = 0x%02h (expected 0xff)", data_out);
        fail_count = fail_count + 1;
    end

    data_in = 8'haa; #10;
    if (data_out == 8'hac) begin
        $display("✓ S(0xaa) = 0x%02h (expected 0xac)", data_out);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ S(0xaa) = 0x%02h (expected 0xac)", data_out);
        fail_count = fail_count + 1;
    end

    // Test first 32 values
    $display("\nTesting first 32 S-box values...");
    for (i = 0; i < 32; i = i + 1) begin
        data_in = i;
        #10;
        if (data_out == sbox_table[i]) begin
            pass_count = pass_count + 1;
        end else begin
            $display("✗ S(0x%02h) = 0x%02h (expected 0x%02h)", i, data_out, sbox_table[i]);
            fail_count = fail_count + 1;
        end
    end

    //=========================================================================
    // Test Inverse S-box (Decryption)
    //=========================================================================
    $display("\nINVERSE S-BOX TESTS (Decryption):");
    $display("----------------------------------");

    enc_dec = 1'b0;  // Decryption mode

    data_in = 8'h63; #10;
    if (data_out == 8'h00) begin
        $display("✓ S^-1(0x63) = 0x%02h (expected 0x00)", data_out);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ S^-1(0x63) = 0x%02h (expected 0x00)", data_out);
        fail_count = fail_count + 1;
    end

    data_in = 8'hed; #10;
    if (data_out == 8'h53) begin
        $display("✓ S^-1(0xed) = 0x%02h (expected 0x53)", data_out);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ S^-1(0xed) = 0x%02h (expected 0x53)", data_out);
        fail_count = fail_count + 1;
    end

    //=========================================================================
    // Test Round-trip (S(S^-1(x)) = x)
    //=========================================================================
    $display("\nROUND-TRIP TESTS:");
    $display("----------------------------------");

    for (i = 0; i < 16; i = i + 1) begin
        // Encrypt
        enc_dec = 1'b1;
        data_in = i;
        #10;
        encrypted = data_out;

        // Decrypt
        enc_dec = 1'b0;
        data_in = encrypted;
        #10;

        if (data_out == i) begin
            pass_count = pass_count + 1;
        end else begin
            $display("✗ Round-trip failed for 0x%02h: S^-1(S(0x%02h)) = 0x%02h", i, i, data_out);
            fail_count = fail_count + 1;
        end
    end
    $display("Round-trip test: 16 values tested");

    //=========================================================================
    // Final Summary
    //=========================================================================
    $display("\n================================================================================");
    $display("                            FINAL TEST SUMMARY");
    $display("================================================================================");
    $display("Total Tests:    %0d", pass_count + fail_count);
    $display("Tests Passed:   %0d", pass_count);
    $display("Tests Failed:   %0d", fail_count);
    if (fail_count == 0) begin
        $display("\n✓✓✓ ALL TESTS PASSED! ✓✓✓");
        $display("Composite Field S-box is WORKING CORRECTLY!");
    end else begin
        $display("\n✗✗✗ %0d TEST(S) FAILED ✗✗✗", fail_count);
        $display("S-box needs further debugging.");
    end
    $display("================================================================================\n");

    $finish;
end

endmodule
