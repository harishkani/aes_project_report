`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Test Corrected Isomorphism Matrices
////////////////////////////////////////////////////////////////////////////////

module tb_isomorphism_corrected_test;

integer i, pass_count, fail_count;

////////////////////////////////////////////////////////////////////////////////
// Corrected Isomorphism Functions
////////////////////////////////////////////////////////////////////////////////

function [7:0] map_to_gf24sq;
    input [7:0] a;
    reg [7:0] b;
    begin
        b[7] = a[7] ^ a[5];
        b[6] = a[7] ^ a[6] ^ a[5] ^ a[1];
        b[5] = a[6] ^ a[1] ^ a[0];
        b[4] = a[7] ^ a[6] ^ a[4] ^ a[3] ^ a[1];
        b[3] = a[6] ^ a[5] ^ a[4] ^ a[2];
        b[2] = a[6] ^ a[4] ^ a[3] ^ a[2] ^ a[1];
        b[1] = a[5] ^ a[4] ^ a[3];
        b[0] = a[4] ^ a[1] ^ a[0];
        map_to_gf24sq = b;
    end
endfunction

function [7:0] map_from_gf24sq;
    input [3:0] ah, al;
    reg [7:0] b;
    reg [7:0] a;
    begin
        a = {ah, al};

        b[7] = a[7] ^ a[6] ^ a[5] ^ a[4] ^ a[3] ^ a[1];
        b[6] = a[6] ^ a[3] ^ a[2] ^ a[1];
        b[5] = a[7] ^ a[6] ^ a[5] ^ a[3] ^ a[2];
        b[4] = a[7] ^ a[6] ^ a[3] ^ a[2] ^ a[0];
        b[3] = a[7] ^ a[4] ^ a[2] ^ a[1] ^ a[0];
        b[2] = a[5] ^ a[4] ^ a[2] ^ a[1] ^ a[0];
        b[1] = a[7] ^ a[3] ^ a[2];
        b[0] = a[6] ^ a[4] ^ a[3] ^ a[1] ^ a[0];
        map_from_gf24sq = b;
    end
endfunction

reg [7:0] test_val, mapped, roundtrip;
reg [3:0] ah, al;

initial begin
    $display("\n================================================================================");
    $display("           CORRECTED GF(2^8) <-> GF((2^4)^2) ISOMORPHISM TEST");
    $display("================================================================================\n");

    pass_count = 0;
    fail_count = 0;

    //=========================================================================
    // Test Round-trip
    //=========================================================================
    $display("ROUND-TRIP TESTS:");
    $display("-----------------");

    for (i = 0; i < 256; i = i + 1) begin
        test_val = i;
        mapped = map_to_gf24sq(test_val);
        ah = mapped[7:4];
        al = mapped[3:0];
        roundtrip = map_from_gf24sq(ah, al);

        if (roundtrip == test_val) begin
            pass_count = pass_count + 1;
        end else begin
            if (fail_count < 10) begin  // Only show first 10 failures
                $display("✗ Round-trip failed for 0x%02h: got 0x%02h", i, roundtrip);
            end
            fail_count = fail_count + 1;
        end
    end

    if (fail_count == 0) begin
        $display("✓ All 256 round-trip tests PASSED!");
    end else if (fail_count > 10) begin
        $display("... and %0d more failures", fail_count - 10);
    end

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
        $display("Corrected isomorphism mappings are WORKING!");
    end else begin
        $display("\n✗✗✗ %0d TEST(S) FAILED ✗✗✗", fail_count);
        $display("Still need to fix the matrices.");
    end
    $display("================================================================================\n");

    $finish;
end

endmodule
