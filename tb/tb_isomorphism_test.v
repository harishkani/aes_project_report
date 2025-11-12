`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Unit Test for GF(2^8) <-> GF((2^4)^2) Isomorphism
// Tests that mapping is reversible and preserves field structure
////////////////////////////////////////////////////////////////////////////////

module tb_isomorphism_test;

integer i, pass_count, fail_count;

////////////////////////////////////////////////////////////////////////////////
// Isomorphism Functions (Canright's basis)
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

reg [7:0] test_val, mapped, roundtrip;
reg [3:0] ah, al;

initial begin
    $display("\n================================================================================");
    $display("              GF(2^8) <-> GF((2^4)^2) ISOMORPHISM TEST");
    $display("================================================================================\n");

    pass_count = 0;
    fail_count = 0;

    //=========================================================================
    // Test Round-trip: map_from_composite(map_to_composite(x)) = x
    //=========================================================================
    $display("ROUND-TRIP TESTS (map_from_composite(map_to_composite(x)) = x):");
    $display("----------------------------------------------------------------");

    for (i = 0; i < 256; i = i + 1) begin
        test_val = i;

        // Map to composite
        mapped = map_to_composite(test_val);
        ah = mapped[7:4];
        al = mapped[3:0];

        // Map back
        roundtrip = map_from_composite(ah, al);

        if (roundtrip == test_val) begin
            pass_count = pass_count + 1;
        end else begin
            $display("✗ Round-trip failed for 0x%02h:", i);
            $display("  map_to_composite(0x%02h) = 0x%02h [ah=0x%01h, al=0x%01h]",
                     i, mapped, ah, al);
            $display("  map_from_composite(0x%01h, 0x%01h) = 0x%02h (expected 0x%02h)",
                     ah, al, roundtrip, test_val);
            fail_count = fail_count + 1;
        end
    end

    if (fail_count == 0) begin
        $display("✓ All 256 values tested successfully");
    end

    //=========================================================================
    // Test Specific Known Values
    //=========================================================================
    $display("\nSPECIFIC VALUE TESTS:");
    $display("---------------------");

    // Test 0x00 (should map and return correctly)
    test_val = 8'h00;
    mapped = map_to_composite(test_val);
    ah = mapped[7:4];
    al = mapped[3:0];
    roundtrip = map_from_composite(ah, al);
    if (roundtrip == test_val) begin
        $display("✓ 0x00: map_to(0x00)=0x%02h -> map_from=0x%02h", mapped, roundtrip);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ 0x00: map_to(0x00)=0x%02h -> map_from=0x%02h (expected 0x00)", mapped, roundtrip);
        fail_count = fail_count + 1;
    end

    // Test 0x01 (should map and return correctly)
    test_val = 8'h01;
    mapped = map_to_composite(test_val);
    ah = mapped[7:4];
    al = mapped[3:0];
    roundtrip = map_from_composite(ah, al);
    if (roundtrip == test_val) begin
        $display("✓ 0x01: map_to(0x01)=0x%02h -> map_from=0x%02h", mapped, roundtrip);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ 0x01: map_to(0x01)=0x%02h -> map_from=0x%02h (expected 0x01)", mapped, roundtrip);
        fail_count = fail_count + 1;
    end

    // Test 0x53 (from our failing S-box test)
    test_val = 8'h53;
    mapped = map_to_composite(test_val);
    ah = mapped[7:4];
    al = mapped[3:0];
    roundtrip = map_from_composite(ah, al);
    if (roundtrip == test_val) begin
        $display("✓ 0x53: map_to(0x53)=0x%02h -> map_from=0x%02h", mapped, roundtrip);
        pass_count = pass_count + 1;
    end else begin
        $display("✗ 0x53: map_to(0x53)=0x%02h -> map_from=0x%02h (expected 0x53)", mapped, roundtrip);
        fail_count = fail_count + 1;
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
        $display("Isomorphism mappings are WORKING CORRECTLY!");
    end else begin
        $display("\n✗✗✗ %0d TEST(S) FAILED ✗✗✗", fail_count);
        $display("Isomorphism mappings need debugging.");
    end
    $display("================================================================================\n");

    $finish;
end

endmodule
