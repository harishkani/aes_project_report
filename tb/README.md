# Testbenches

This directory contains testbenches for verifying AES implementations.

## Files

### tb_aes_ultimate.v ⭐ **PRIMARY TESTBENCH**
- Tests the ultimate optimized AES core
- 10 comprehensive test cases using NIST FIPS 197 vectors
- **Result**: 100% pass rate (10/10 tests)

**Test Coverage**:
- 4 encryption tests (NIST + edge cases)
- 3 decryption tests
- 3 round-trip tests (encrypt → decrypt verification)

### tb_aes_integration.v
- Original testbench for baseline design
- Same NIST test vectors
- Used for regression testing

## Running Simulations

### Using Icarus Verilog:

```bash
# Compile
iverilog -o sim \
    ../rtl/modules/aes_sbox.v \
    ../rtl/modules/aes_inv_sbox.v \
    ../rtl/modules/aes_subbytes_32bit_shared.v \
    ../rtl/modules/aes_shiftrows_128bit.v \
    ../rtl/modules/aes_mixcolumns_32bit.v \
    ../rtl/modules/aes_key_expansion_otf.v \
    ../rtl/core/aes_core_ultimate.v \
    tb_aes_ultimate.v

# Run simulation
vvp sim

# Expected output: 10/10 tests PASS
```

### Using ModelSim/Questa:

```bash
vlog ../rtl/modules/*.v ../rtl/core/aes_core_ultimate.v tb_aes_ultimate.v
vsim -c tb_aes_ultimate -do "run -all; quit"
```

## Test Vectors

All test vectors are from **NIST FIPS 197**:

| Test | Vector | Description |
|------|--------|-------------|
| 1-2 | NIST C.1, B | Official test vectors |
| 3-4 | Custom | All zeros, all ones |
| 5-7 | Decryption | Reverse of encryption tests |
| 8-10 | Round-trip | Encrypt then decrypt validation |

## Expected Results

```
================================================================================
                            FINAL TEST SUMMARY
================================================================================
Total Tests:    10
Tests Passed:   10
Tests Failed:   0
Success Rate:   100%
================================================================================
✅ ALL TESTS PASSED!
✅ AES-128 Ultimate Design is VERIFIED!
```

See `../docs/SIMULATION_RESULTS.md` for detailed results.
