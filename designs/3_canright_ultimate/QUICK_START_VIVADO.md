# Quick Start Guide - Vivado Setup for Canright AES

## 🚀 Fastest Method (Automated)

### Option 1: Create New Project Automatically

1. **Open Vivado**
2. **In TCL Console**, type:
   ```tcl
   cd /path/to/aes_project_report/designs/3_canright_ultimate
   source synthesize_canright.tcl
   ```
3. **Done!** Project created with all files, synthesis runs automatically.

---

## 🔍 Diagnostic (Check Existing Project)

### Option 2: Check What's Wrong with Current Project

1. **Open your existing Vivado project**
2. **In TCL Console**, type:
   ```tcl
   cd /path/to/aes_project_report/designs/3_canright_ultimate
   source check_vivado_project.tcl
   ```
3. **Read the output** - it will tell you exactly what's missing
4. **Follow the fix instructions** it provides

---

## 📋 Manual Fix (If Automated Doesn't Work)

### The Files You MUST Have

Navigate to your Vivado project, then:

**Right-click "Design Sources" → Add Sources → Add or create design sources**

Add these 7 files from `designs/3_canright_ultimate/rtl/`:

```
✓ aes_sbox.v                          ← DON'T SKIP THIS!
✓ aes_sbox_canright_verified.v
✓ aes_subbytes_32bit_canright.v
✓ aes_shiftrows_128bit.v
✓ aes_mixcolumns_32bit.v
✓ aes_key_expansion_otf.v
✓ aes_core_ultimate_canright.v
```

**Set Top Module:**
- Right-click `aes_core_ultimate_canright.v`
- Select "Set as Top"

**Update Compile Order:**
- Flow Navigator → Settings → General → Update Compile Order

---

## ⚠️ Common Mistakes

### ❌ WRONG: "I only added Canright S-box"
```
aes_sbox_canright_verified.v  ← Only this
```
**Problem**: Key expansion needs `aes_sbox.v` too!

### ✅ CORRECT: "Both S-box files"
```
aes_sbox.v                     ← For key expansion (LUT-based)
aes_sbox_canright_verified.v   ← For data path (Canright)
```

---

## 🎯 Expected Results

After synthesis completes:

```
✅ LUTs: 480-560 (target)
✅ Throughput: 2.27 Mbps
✅ T/A Ratio: 4.0-4.7 Kbps/LUT
✅ Status: BEATS PAPER BY 60-88%
```

Reports will be saved in: `./reports_canright/`

---

## 🆘 Still Having Issues?

### Check the hierarchy in Vivado:

**Sources Window → Hierarchy tab**

You should see:
```
aes_core_ultimate_canright (green checkmark)
  ├─ aes_key_expansion_otf (green checkmark)
  │  └─ sbox0, sbox1, sbox2, sbox3 (green checkmark)
  ├─ aes_subbytes_32bit_canright (green checkmark)
  │  └─ sbox0, sbox1, sbox2, sbox3 (green checkmark)
  ├─ aes_shiftrows_128bit (green checkmark)
  └─ aes_mixcolumns_32bit (green checkmark)
```

**If you see red ✗ or yellow ?** → Missing files!

---

## 📁 File Locations

All files are in:
```
designs/3_canright_ultimate/
├── rtl/                          ← Source files here
│   ├── aes_sbox.v
│   ├── aes_sbox_canright_verified.v
│   ├── aes_subbytes_32bit_canright.v
│   ├── aes_shiftrows_128bit.v
│   ├── aes_mixcolumns_32bit.v
│   ├── aes_key_expansion_otf.v
│   └── aes_core_ultimate_canright.v
├── synthesize_canright.tcl       ← Auto-setup script
├── check_vivado_project.tcl      ← Diagnostic script
└── VIVADO_PROJECT_FIX.md         ← Detailed guide
```

---

## 🎓 Why This Design Uses Two S-boxes

| Component | S-box Used | Reason |
|-----------|-----------|---------|
| Key Expansion | `aes_sbox.v` (LUT) | Simple, only forward S-box needed |
| Data Path | `aes_sbox_canright_verified.v` | 40% smaller, handles forward & inverse |

**This is intentional optimization, not a mistake!**

---

## Next Steps

1. ✅ Fix Vivado project (use one of the methods above)
2. ✅ Run Synthesis (Flow → Run Synthesis)
3. ✅ Check reports in `./reports_canright/breakdown.txt`
4. ✅ Compare with IEEE paper results

---

**Need more help?** See `VIVADO_PROJECT_FIX.md` for detailed instructions.
