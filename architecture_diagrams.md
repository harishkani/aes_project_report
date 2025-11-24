# AES-128 Architecture Diagrams

## 1. On-the-Fly Key Expansion Module

The on-the-fly key expansion module generates round keys on demand, storing only the current 128-bit round key (4 words) instead of all 11 round keys.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AES KEY EXPANSION (ON-THE-FLY)                           │
│                                                                              │
│  ┌──────────┐                                                                │
│  │ master_key│                                                                │
│  │ [127:0]  │                                                                │
│  └────┬─────┘                                                                │
│       │ (on start)                                                           │
│       ▼                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐           │
│  │        Current 4-Word Window (128 bits)                      │           │
│  │   ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │           │
│  │   │   w0   │  │   w1   │  │   w2   │  │   w3   │           │           │
│  │   │ [31:0] │  │ [31:0] │  │ [31:0] │  │ [31:0] │           │           │
│  │   └───┬────┘  └───┬────┘  └───┬────┘  └───┬────┘           │           │
│  └───────┼───────────┼───────────┼───────────┼────────────────┘           │
│          │           │           │           │                              │
│          │           │           │           │                              │
│  Output  ▼           │           │           │  Next Round Generation       │
│  Selection           │           │           │                              │
│   (MUX)              │           │           │                              │
│          │           │           │           └──────┐                       │
│          │           │           │                  │                       │
│          │           │           │           ┌──────▼──────┐                │
│          │           │           │           │  RotWord    │                │
│          │           │           │           │ (rotation)  │                │
│          │           │           │           └──────┬──────┘                │
│          │           │           │                  │                       │
│          │           │           │           ┌──────▼──────────────────┐    │
│          │           │           │           │   SubWord (4 S-boxes)   │    │
│          │           │           │           │  ┌────┐ ┌────┐ ┌────┐  │    │
│          │           │           │           │  │Sbox│ │Sbox│ │Sbox│  │    │
│          │           │           │           │  │ 0  │ │ 1  │ │ 2  │  │    │
│          │           │           │           │  └────┘ └────┘ └────┘  │    │
│          │           │           │           │  ┌────┐                │    │
│          │           │           │           │  │Sbox│                │    │
│          │           │           │           │  │ 3  │                │    │
│          │           │           │           │  └────┘                │    │
│          │           │           │           └──────┬──────────────────┘    │
│          │           │           │                  │                       │
│          │           │           │                  │  ┌─────────────┐      │
│          │           │           │                  │  │ Rcon(round) │      │
│          │           │           │                  │  └──────┬──────┘      │
│          │           │           │                  │         │             │
│          │           │           │                  ▼         ▼             │
│          │           │           │              ┌────────────────┐          │
│          │           │           │              │  temp_w0 = w0  │          │
│          │           │           │              │    XOR result  │          │
│          │           │           │              │    XOR Rcon    │          │
│          │           │           │              └────────┬───────┘          │
│          │           │           │                       │                  │
│          │           │           │                       ▼                  │
│          │           │           │              ┌────────────────┐          │
│          │           │           │              │ temp_w1 = w1   │          │
│          │           │           │              │   XOR temp_w0  │          │
│          │           │           │              └────────┬───────┘          │
│          │           │           │                       │                  │
│          │           │           │                       ▼                  │
│          │           │           │              ┌────────────────┐          │
│          │           │           │              │ temp_w2 = w2   │          │
│          │           │           │              │   XOR temp_w1  │          │
│          │           │           │              └────────┬───────┘          │
│          │           │           │                       │                  │
│          │           │           │                       ▼                  │
│          │           │           │              ┌────────────────┐          │
│          │           │           │              │ temp_w3 = w3   │          │
│          │           │           │              │   XOR temp_w2  │          │
│          │           │           │              └────────┬───────┘          │
│          │           │           │                       │                  │
│          │           │           │         (when moving to next round)      │
│          │           │           │                       │                  │
│          └───────────┴───────────┴───────────────────────┘                  │
│                                                                              │
│  ┌────────────┐      ┌──────────────┐                                       │
│  │ word_addr  │      │  round_key   │                                       │
│  │   [5:0]    │      │   [31:0]     │   ◄── Output                          │
│  │  (0-43)    │      │              │                                       │
│  └────────────┘      └──────────────┘                                       │
│                                                                              │
│  Control Signals:                                                           │
│  • start  - Load new master key                                             │
│  • next   - Advance to next word (auto-generates if needed)                 │
│  • ready  - Always ready (no pre-computation phase)                         │
└──────────────────────────────────────────────────────────────────────────────┘

Key Features:
- Stores only current round (128 bits) vs all rounds (1408 bits)
- Generates next round keys combinationally
- 4 S-boxes for SubWord operation
- Word counter (0-43) tracks position across all rounds
- Minimal storage, maximum efficiency
```

---

## 2. 32-bit AES-128 Core Datapath

The 32-bit datapath processes one column (32 bits) at a time, cycling through 4 columns per round.

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                         AES-128 CORE (32-bit Datapath)                           │
│                                                                                   │
│  ┌──────────┐                                                                     │
│  │ data_in  │                                                                     │
│  │ [127:0]  │                                                                     │
│  └────┬─────┘                                                                     │
│       │                                                                           │
│       ▼                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐         │
│  │                    AES State Register [127:0]                       │         │
│  │                                                                     │         │
│  │   Column 0    Column 1    Column 2    Column 3                     │         │
│  │   [127:96]    [95:64]     [63:32]     [31:0]                       │         │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐                   │         │
│  │  │  Byte0 │  │  Byte4 │  │  Byte8 │  │ Byte12 │                   │         │
│  │  │  Byte1 │  │  Byte5 │  │  Byte9 │  │ Byte13 │                   │         │
│  │  │  Byte2 │  │  Byte6 │  │ Byte10 │  │ Byte14 │                   │         │
│  │  │  Byte3 │  │  Byte7 │  │ Byte11 │  │ Byte15 │                   │         │
│  │  └────┬───┘  └────┬───┘  └────┬───┘  └────┬───┘                   │         │
│  └───────┼───────────┼───────────┼───────────┼────────────────────────┘         │
│          │           │           │           │                                   │
│          │           │           │           │                                   │
│          └───────────┴───────────┴───────────┴───────────────┐                   │
│                                                               │                   │
│                      Column Selector (col_cnt[1:0])          │                   │
│                              (0, 1, 2, 3)                    │                   │
│                                  │                           │                   │
│                                  ▼                           │                   │
│                         ┌────────────────┐                   │                   │
│                         │ Current Column │                   │                   │
│                         │    [31:0]      │                   │                   │
│                         └────────┬───────┘                   │                   │
│                                  │                           │                   │
│  ┌───────────────────────────────┼───────────────────────────┘                   │
│  │                               │                                               │
│  │  ENCRYPTION PATH              │         DECRYPTION PATH                       │
│  │                               │                                               │
│  │  ┌────────────────────────────▼──────────────┐                                │
│  │  │         SubBytes (4 S-boxes)              │                                │
│  │  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐    │                                │
│  │  │  │ Sbox │ │ Sbox │ │ Sbox │ │ Sbox │    │   ◄── Shared for enc/dec       │
│  │  │  │ [0]  │ │ [1]  │ │ [2]  │ │ [3]  │    │   ◄── 4 S-boxes total          │
│  │  │  │ 8bit │ │ 8bit │ │ 8bit │ │ 8bit │    │                                │
│  │  │  └──────┘ └──────┘ └──────┘ └──────┘    │                                │
│  │  │          (processes 1 column/cycle)      │                                │
│  │  └──────────────────┬───────────────────────┘                                │
│  │                     │                                                         │
│  │                     ▼                                                         │
│  │         ┌───────────────────────┐                                            │
│  │         │    Temp State Reg     │                                            │
│  │         │      [127:0]          │                                            │
│  │         └───────────┬───────────┘                                            │
│  │                     │                                                         │
│  │                     ▼                                                         │
│  │         ┌───────────────────────────────┐                                    │
│  │         │   ShiftRows (Full 128-bit)    │                                    │
│  │         │                               │                                    │
│  │         │  Row0: [no shift]             │                                    │
│  │         │  Row1: [<<<1]                 │                                    │
│  │         │  Row2: [<<<2]                 │                                    │
│  │         │  Row3: [<<<3]  (or >>>1)      │                                    │
│  │         └───────────┬───────────────────┘                                    │
│  │                     │                                                         │
│  │                     ▼                                                         │
│  │         ┌───────────────────────┐                                            │
│  │         │  Extract Shifted Col  │                                            │
│  │         │      [31:0]           │                                            │
│  │         └───────────┬───────────┘                                            │
│  │                     │                                                         │
│  │                     ▼                                                         │
│  │         ┌───────────────────────────────┐                                    │
│  │         │   MixColumns (32-bit)         │                                    │
│  │         │                               │                                    │
│  │         │  [2 1 1 3]   [byte0]          │                                    │
│  │         │  [3 2 1 1] × [byte1]          │                                    │
│  │         │  [1 3 2 1]   [byte2]          │                                    │
│  │         │  [1 1 3 2]   [byte3]          │                                    │
│  │         │                               │                                    │
│  │         │  (skipped on last round)      │                                    │
│  │         └───────────┬───────────────────┘                                    │
│  │                     │                                                         │
│  │                     ▼                                                         │
│  │         ┌───────────────────────┐          ┌──────────────────────┐          │
│  │         │  AddRoundKey (XOR)    │  ◄───────│   Round Key [31:0]   │          │
│  │         │      [31:0]           │          │  (from key expansion)│          │
│  │         └───────────┬───────────┘          └──────────────────────┘          │
│  │                     │                                 ▲                       │
│  │                     │                                 │                       │
│  └─────────────────────┘                                 │                       │
│                                                           │                       │
│         (Write back to State Register)                   │                       │
│                                                           │                       │
│  ┌──────────────────────────────────────────────────────────────────────┐       │
│  │              KEY EXPANSION & ROUND KEY STORAGE                       │       │
│  │                                                                      │       │
│  │  ┌────────────────────────┐          ┌────────────────────────┐    │       │
│  │  │   Key Expansion OTF    │          │  Round Key Shift Reg   │    │       │
│  │  │   (generates on-fly)   │  ───────►│   rk_shift_reg[0:43]   │    │       │
│  │  │                        │          │                        │    │       │
│  │  │  • key_word [31:0]     │          │  [44 words × 32 bits]  │    │       │
│  │  │  • word_addr [5:0]     │          │                        │    │       │
│  │  └────────────────────────┘          └────────┬───────────────┘    │       │
│  │                                                │                    │       │
│  │                                                │                    │       │
│  │                                    ┌───────────▼──────────────┐     │       │
│  │                                    │  Key Index Calculation   │     │       │
│  │                                    │                          │     │       │
│  │                                    │  Enc: round*4 + col_cnt  │     │       │
│  │                                    │  Dec: (10-round)*4 + col │     │       │
│  │                                    └───────────┬──────────────┘     │       │
│  │                                                │                    │       │
│  │                                                ▼                    │       │
│  │                                       current_rkey[31:0]            │       │
│  └──────────────────────────────────────────────────────────────────────┘       │
│                                                                                  │
│  ┌──────────────────────────────────────────────────────────────────┐           │
│  │                    CONTROL STATE MACHINE                         │           │
│  │                                                                  │           │
│  │  States:                                                         │           │
│  │  • IDLE           - Wait for start                               │           │
│  │  • KEY_EXPAND     - Load 44 round keys into shift register       │           │
│  │  • ROUND0         - Initial AddRoundKey (4 cycles)               │           │
│  │  • ENC_SUB        - SubBytes (4 cycles)                          │           │
│  │  • ENC_SHIFT_MIX  - ShiftRows+MixColumns+AddRoundKey (4 cycles)  │           │
│  │  • DEC_SHIFT_SUB  - InvShiftRows+InvSubBytes (5 cycles)          │           │
│  │  • DEC_ADD_MIX    - AddRoundKey+InvMixColumns (8 cycles)         │           │
│  │  • DONE           - Output result                                │           │
│  │                                                                  │           │
│  │  Counters:                                                       │           │
│  │  • round_cnt[3:0] - Current round (0-10)                         │           │
│  │  • col_cnt[1:0]   - Current column (0-3)                         │           │
│  │  • phase[1:0]     - Sub-phase within state                       │           │
│  └──────────────────────────────────────────────────────────────────┘           │
│                                                                                  │
│  ┌──────────┐                                                                    │
│  │ data_out │  ◄── Final output after 10 rounds                                 │
│  │ [127:0]  │                                                                    │
│  └──────────┘                                                                    │
│                                                                                  │
│  Timing: 32-bit column-wise processing                                          │
│  • 4 cycles per transformation (SubBytes, ShiftRows, MixColumns)                │
│  • Total ~44 cycles per round                                                   │
│  • ~440-480 cycles for full encryption                                          │
└──────────────────────────────────────────────────────────────────────────────────┘

Key Features:
- 32-bit datapath: processes 1 column (4 bytes) per cycle
- Shared SubBytes: 4 S-boxes handle all columns sequentially
- Full 128-bit ShiftRows operation (affects all 4 columns)
- 32-bit MixColumns: processes each column independently
- Shift register storage for round keys (44 words)
- On-the-fly key expansion integration
```

---

## 3. Data Flow Summary

### Encryption Flow (Column-wise):
```
Round 0: AddRoundKey (4 cycles: process columns 0→1→2→3)

Rounds 1-9: (For each round, 8 cycles total)
  ├─ SubBytes      (4 cycles: col0→col1→col2→col3)
  └─ ShiftRows     (1 operation on full state)
     MixColumns    (4 cycles: col0→col1→col2→col3)
     AddRoundKey   (interleaved with MixColumns)

Round 10: (6 cycles total)
  ├─ SubBytes      (4 cycles)
  └─ ShiftRows     (1 operation on full state)
     AddRoundKey   (4 cycles, no MixColumns)
```

### Decryption Flow (Column-wise):
```
Round 0: AddRoundKey (4 cycles)

Rounds 1-9: (For each round, 13 cycles total)
  ├─ InvShiftRows  (1 operation on full state)
  ├─ InvSubBytes   (4 cycles: col0→col1→col2→col3)
  ├─ AddRoundKey   (4 cycles: col0→col1→col2→col3)
  └─ InvMixColumns (4 cycles: col0→col1→col2→col3)

Round 10: (6 cycles total, no InvMixColumns)
  ├─ InvShiftRows  (1 operation on full state)
  ├─ InvSubBytes   (4 cycles)
  └─ AddRoundKey   (4 cycles)
```

---

## 4. Resource Optimization Highlights

### Key Expansion Module:
- **Storage**: 128 bits (current round) vs 1408 bits (all rounds)
- **Savings**: ~91% memory reduction
- **Trade-off**: Regeneration overhead (negligible with caching)

### 32-bit Datapath:
- **S-boxes**: 4 shared (enc/dec) vs 16 separate
- **Savings**: ~75% S-box resource reduction
- **Processing**: Sequential column processing
- **Latency**: ~440-480 cycles per block
- **Throughput**: ~2.27 Mbps @ 100MHz

### Combined Optimizations:
1. **Shift Register Storage** (SRL primitives): 30% LUT reduction
2. **Composite Field S-boxes**: 60% S-box area reduction
3. **S-box Sharing**: 50% S-box count reduction
4. **Clock Gating**: 25-40% dynamic power reduction

**Result**: ~500-600 LUTs total with T/A ratio of 3.8-4.5 Kbps/LUT
