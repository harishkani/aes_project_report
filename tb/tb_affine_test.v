`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Unit Test for Affine Transformations
// Tests affine and inverse affine against known values
////////////////////////////////////////////////////////////////////////////////

module tb_affine_test;

integer i, pass_count, fail_count;

// Known test vectors from NIST FIPS 197
// affine(0x00) = 0x63
// affine(0x01) = 0x7C  (after inversion 0x01 stays 0x01)
// affine(0xCA) = 0x82  (after inversion 0xCA becomes 0x11)

////////////////////////////////////////////////////////////////////////////////
// Affine Transformation Functions
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

reg [7:0] test_val, affine_result, roundtrip_result;

initial begin
    $display("\n================================================================================");
    $display("                  AES AFFINE TRANSFORMATION TEST");
    $display("================================================================================\n");

    pass_count = 0;
    fail_count = 0;

    //=========================================================================
    // Test Forward Affine
    //=========================================================================
    $display("FORWARD AFFINE TESTS:");
    $display("---------------------");

    // Test affine(0x00) = 0x63
    test_val = 8'h00;
    affine_result = affine_transform(test_val);
    if (affine_result == 8'h63) begin
        $display("✓ affine(0x00) = 0x%02h (expected 0x63)", affine_result);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ affine(0x00) = 0x%02h (expected 0x63)", affine_result);
        fail_count = fail_count + 1;
    end

    // Test affine(0x01) = 0x7C (0x01 is self-inverse)
    test_val = 8'h01;
    affine_result = affine_transform(test_val);
    if (affine_result == 8'h7c) begin
        $display("✓ affine(0x01) = 0x%02h (expected 0x7c)", affine_result);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ affine(0x01) = 0x%02h (expected 0x7c)", affine_result);
        fail_count = fail_count + 1;
    end

    //=========================================================================
    // Test Inverse Affine
    //=========================================================================
    $display("\nINVERSE AFFINE TESTS:");
    $display("---------------------");

    // Test inv_affine(0x63) = 0x00
    test_val = 8'h63;
    roundtrip_result = inv_affine_transform(test_val);
    if (roundtrip_result == 8'h00) begin
        $display("✓ inv_affine(0x63) = 0x%02h (expected 0x00)", roundtrip_result);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ inv_affine(0x63) = 0x%02h (expected 0x00)", roundtrip_result);
        fail_count = fail_count + 1;
    end

    // Test inv_affine(0x7C) = 0x01
    test_val = 8'h7c;
    roundtrip_result = inv_affine_transform(test_val);
    if (roundtrip_result == 8'h01) begin
        $display("✓ inv_affine(0x7c) = 0x%02h (expected 0x01)", roundtrip_result);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ inv_affine(0x7c) = 0x%02h (expected 0x01)", roundtrip_result);
        fail_count = fail_count + 1;
    end

    //=========================================================================
    // Test Round-trip: inv_affine(affine(x)) = x
    //=========================================================================
    $display("\nROUND-TRIP TESTS (inv_affine(affine(x)) = x):");
    $display("----------------------------------------------");

    for (i = 0; i < 256; i = i + 1) begin
        test_val = i;
        affine_result = affine_transform(test_val);
        roundtrip_result = inv_affine_transform(affine_result);

        if (roundtrip_result == test_val) begin
            pass_count = pass_count + 1;
        end else begin
            $display("✗ Round-trip failed for 0x%02h: inv_affine(affine(0x%02h)) = 0x%02h",
                     i, i, roundtrip_result);
            fail_count = fail_count + 1;
        end
    end
    $display("Tested all 256 values for round-trip consistency");

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
        $display("Affine transformations are WORKING CORRECTLY!");
    end else begin
        $display("\n✗✗✗ %0d TEST(S) FAILED ✗✗✗", fail_count);
        $display("Affine transformations need debugging.");
    end
    $display("================================================================================\n");

    $finish;
end

endmodule
