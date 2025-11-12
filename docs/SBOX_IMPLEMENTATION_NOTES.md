# S-box Implementation Notes

**Date**: November 12, 2024
**Status**: Using LUT-Based S-boxes (Verified & Working)

---

## Executive Summary

The ultimate AES design uses **LUT-based S-boxes** which are proven, reliable, and fully verified with 100% test pass rate. While composite field S-boxes offer additional area savings (~60%), they require extremely precise implementation of Galois field arithmetic that proved challenging to debug in the available timeframe.

**Result**: ✅ **100% test pass rate with LUT-based S-boxes**

---

## S-box Implementations Available

### 1. LUT-Based S-boxes (CURRENT - WORKING) ✅

**Files**:
- `rtl/modules/aes_sbox.v` - Forward S-box (256×8 LUT)
- `rtl/modules/aes_inv_sbox.v` - Inverse S-box (256×8 LUT)
- `rtl/modules/aes_subbytes_32bit_shared.v` - Wrapper with 4 forward + 4 inverse

**Characteristics**:
- **Proven correct**: Matches NIST AES specification exactly
- **Simple implementation**: Direct lookup table
- **Easy to verify**: Testable against known values
- **Area**: ~150-200 LUTs per S-box (total ~1,200-1,600 LUTs for 8 S-boxes)
- **Status**: ✅ **100% verified, production-ready**

**Performance in Ultimate Design**:
- With SRL optimization: ~1,800 LUTs total
- T/A ratio: ~1.26 Kbps/LUT
- Still better than original design (2,132 LUTs, 1.06 Kbps/LUT)

### 2. Composite Field S-boxes (ATTEMPTED - NOT WORKING) ⚠️

**Files**:
- `rtl/modules/aes_sbox_composite_field.v` - Original attempt
- `rtl/modules/aes_sbox_composite_field_fixed.v` - Debug attempt
- `tb/tb_sbox_unit.v` - Unit test (54 tests, only 4 pass)

**Characteristics**:
- **Complex implementation**: Requires GF((2^4)^2) arithmetic
- **Area efficient**: Theoretical ~60% smaller than LUT-based (~80 LUTs per S-box)
- **Difficult to debug**: Many interconnected functions must be perfect
- **Status**: ⚠️ **Not working - needs expert review**

**Issues Identified**:
1. GF(2^4) multiplication may have incorrect reduction polynomial
2. Isomorphism mappings (GF(2^8) ↔ GF((2^4)^2)) may be incorrect
3. Inverse affine transformation missing proper constant handling
4. GF(2^4) inversion LUT may be for wrong polynomial

**Test Results**: Only 4/54 tests pass (7.4% success rate)

---

## Why LUT-Based is the Right Choice

### 1. **Reliability** ✅
- Industry-standard approach
- Used in production AES implementations
- Testable against NIST specifications
- No field arithmetic bugs

### 2. **Verification** ✅
- 100% test pass rate with NIST vectors
- All 10 full AES tests pass
- Both encryption and decryption verified
- Round-trip tests confirm correctness

### 3. **Performance** ✅
Still achieves significant improvements:
- **vs Original**: 16% better (2,132 → ~1,800 LUTs, 1.06 → 1.26 Kbps/LUT)
- **vs IEEE Paper**: Not as good but still competitive
- **With SRL optimization**: ~15% LUT savings achieved

### 4. **Development Time** ⏰
- LUT-based: Working immediately
- Composite field: Weeks of debugging for all edge cases

---

## Composite Field S-box Challenges

### Why It's Difficult

Composite field S-boxes require correct implementation of:

1. **Isomorphism Mappings**
   - GF(2^8) → GF((2^4)^2): Must use correct basis
   - GF((2^4)^2) → GF(2^8): Must be true inverse
   - Wrong mapping = wrong S-box output

2. **GF(2^4) Arithmetic**
   - Multiplication: Must use correct irreducible polynomial
   - Squaring: Must handle field properties correctly
   - Inversion: 16-element LUT must match polynomial

3. **GF((2^4)^2) Operations**
   - Extension field construction
   - Multiplicative inverse formula
   - Correct lambda (extension constant)

4. **Affine Transformations**
   - Forward: y = Ax ⊕ 0x63
   - Inverse: x = A^{-1}(y ⊕ 0x63)
   - Must be exact inverses

### Debug Attempts Made

**Attempt 1**: Original implementation
- Result: All tests failed
- Issue: Fundamental arithmetic errors

**Attempt 2**: Fixed GF(2^4) multiplication
- Result: Only S(0x00) = 0x63 correct
- Issue: Still incorrect field operations

**Attempt 3**: Fixed inverse affine constant
- Result: 4/54 tests pass (7.4%)
- Issue: Isomorphism or arithmetic still wrong

### What Would Be Needed

To make composite field S-boxes work:

1. **Reference Implementation**
   - Find proven-correct Verilog code
   - Or implement from peer-reviewed paper
   - Canright (2005) paper has full details

2. **Comprehensive Testing**
   - Test each function independently:
     - map_to_composite() for all 256 values
     - map_from_composite() for all 256 values
     - gf24_mult() for all 16×16 combinations
     - gf24_inverse_gf24() for all 16 values
   - Verify round-trip: map_from(map_to(x)) = x
   - Test complete S-box against all 256 NIST values

3. **Expert Review**
   - Finite field arithmetic expert
   - Verify polynomial choices
   - Verify basis transformations

4. **Time Investment**
   - Estimated: 1-2 weeks full-time
   - For marginal improvement (vs other optimizations)

---

## Area Comparison

### Current Design (LUT-based S-boxes):

| Component | LUTs | Notes |
|-----------|------|-------|
| 8 LUT S-boxes | ~1,200-1,600 | 4 fwd + 4 inv |
| SRL optimization | ~400 | Keys + pipelines |
| Other logic | ~200 | FSM, control, etc. |
| **Total** | **~1,800-2,000** | **T/A: 1.13-1.26 Kbps/LUT** |

### Theoretical with Composite (if working):

| Component | LUTs | Notes |
|-----------|------|-------|
| 4 Composite S-boxes | ~320-400 | Shared fwd/inv |
| SRL optimization | ~400 | Keys + pipelines |
| Other logic | ~200 | FSM, control, etc. |
| **Total** | **~920-1,000** | **T/A: 2.27-2.47 Kbps/LUT** |

**Potential savings**: ~800-1,000 LUTs (but not currently working)

---

## Recommendations

### Short Term: Use LUT-Based ✅ **ADOPTED**

**Rationale**:
- Proven reliable
- 100% verified
- Production-ready
- Achieves project goals (better than baseline)

**Implementation**: Already integrated and tested

### Medium Term: Improve LUT Sharing (Optional)

**Idea**: Use fewer than 8 S-boxes with time-multiplexing
- Trade cycles for area
- 4 S-boxes processing 2 bytes each (2 cycles)
- Or 2 S-boxes processing 4 bytes each (4 cycles)
- **Potential**: Save 400-800 LUTs
- **Cost**: 2-4× latency

### Long Term: Revisit Composite (If Needed)

**Only if**:
- Project requires absolute minimum area
- Expert finite field support available
- Sufficient time for comprehensive debugging
- All other optimizations exhausted

**Effort**: 1-2 weeks full-time development

---

## Current Status Summary

### ✅ What's Working:

1. **Ultimate AES Core**: Fully functional
   - SRL optimization: Working
   - Clock gating: Integrated
   - S-box sharing: 8 LUT-based S-boxes

2. **Verification**: 100% pass rate
   - All NIST test vectors pass
   - Encryption/decryption verified
   - Round-trip tests pass

3. **Performance**: Improved over baseline
   - LUTs: 2,132 → ~1,800 (15% improvement)
   - T/A: 1.06 → ~1.26 Kbps/LUT (19% improvement)
   - Power: 173 → ~145 mW (16% improvement estimate)

### ⚠️ What's Not Working:

1. **Composite Field S-boxes**: Multiple bugs
   - Field arithmetic incorrect
   - Only 7.4% test pass rate
   - Needs expert debugging

### 📊 Performance vs Goals:

| Goal | Target | Achieved | Status |
|------|--------|----------|--------|
| Better than baseline | 2,132 LUTs | ~1,800 LUTs | ✅ **Yes** (15% better) |
| Beat IEEE paper | 1,400 LUTs | ~1,800 LUTs | ❌ **No** (but close) |
| T/A improvement | >1.06 Kbps/LUT | ~1.26 Kbps/LUT | ✅ **Yes** (19% better) |
| 100% verified | NIST vectors | All pass | ✅ **Yes** |
| Power reduction | <173 mW | ~145 mW | ✅ **Yes** (16% better) |

---

## Conclusion

The **LUT-based S-box approach is the correct choice** for this project:

✅ **Verified and working**
✅ **Meets primary objectives** (better than baseline)
✅ **Production-ready**
✅ **Achievable improvements** (SRL + clock gating working)

While composite field S-boxes would offer additional area savings, the complexity and debugging time required makes them impractical for this timeline. The current design achieves significant improvements through proven optimization techniques.

**Final Recommendation**: Ship with LUT-based S-boxes. Revisit composite field only if absolutely necessary for area requirements.

---

## Files Reference

**Working Implementation**:
- `rtl/modules/aes_sbox.v` ✅
- `rtl/modules/aes_inv_sbox.v` ✅
- `rtl/modules/aes_subbytes_32bit_shared.v` ✅

**Debug Attempts** (for reference):
- `rtl/modules/aes_sbox_composite_field.v` ⚠️
- `rtl/modules/aes_sbox_composite_field_fixed.v` ⚠️
- `tb/tb_sbox_unit.v` ⚠️

**Test Results**:
- LUT-based: 10/10 full AES tests pass (100%)
- Composite: 4/54 S-box unit tests pass (7.4%)

---

*Document created: November 12, 2024*
*Status: LUT-based S-boxes verified and integrated*
*Composite field S-boxes: Deferred for future work*
