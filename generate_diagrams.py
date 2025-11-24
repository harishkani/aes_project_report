#!/usr/bin/env python3
"""
Generate AES Architecture Diagrams using Graphviz
Install: pip install graphviz

Usage:
    python generate_diagrams.py

Outputs:
    - key_expansion_diagram.png
    - datapath_diagram.png
    - key_expansion_diagram.svg
    - datapath_diagram.svg
"""

try:
    from graphviz import Digraph
    GRAPHVIZ_AVAILABLE = True
except ImportError:
    print("ERROR: graphviz not installed. Install with: pip install graphviz")
    GRAPHVIZ_AVAILABLE = False
    exit(1)


def create_key_expansion_diagram():
    """Create the on-the-fly key expansion module diagram"""
    dot = Digraph(comment='AES Key Expansion Module', format='png')
    dot.attr(rankdir='TB', splines='ortho', nodesep='0.5', ranksep='0.7')
    dot.attr('node', shape='box', style='rounded,filled', fontname='Arial')

    # Title
    dot.node('title', 'AES-128 On-the-Fly Key Expansion Module',
             shape='plaintext', fontsize='16', fontname='Arial Bold')

    # Master Key
    dot.node('master_key', 'Master Key\n[127:0]', fillcolor='#fff2cc')

    # Current window subgraph
    with dot.subgraph(name='cluster_window') as c:
        c.attr(label='Current 4-Word Window (128 bits)', style='dashed')
        c.node('w0', 'w0\n[31:0]', fillcolor='#fff2cc')
        c.node('w1', 'w1\n[31:0]', fillcolor='#fff2cc')
        c.node('w2', 'w2\n[31:0]', fillcolor='#fff2cc')
        c.node('w3', 'w3\n[31:0]', fillcolor='#fff2cc')

    # RotWord
    dot.node('rotword', 'RotWord\n(Rotation)', fillcolor='#dae8fc')

    # SubWord subgraph
    with dot.subgraph(name='cluster_subword') as c:
        c.attr(label='SubWord (4 S-boxes)', style='dashed')
        c.node('sbox0', 'S-box 0', fillcolor='#f8cecc')
        c.node('sbox1', 'S-box 1', fillcolor='#f8cecc')
        c.node('sbox2', 'S-box 2', fillcolor='#f8cecc')
        c.node('sbox3', 'S-box 3', fillcolor='#f8cecc')

    # Rcon
    dot.node('rcon', 'Rcon\n(round)', fillcolor='#fff2cc')

    # Next round generation
    dot.node('temp_w0', 'temp_w0 =\nw0 ⊕ result ⊕ Rcon', fillcolor='#d5e8d4')
    dot.node('temp_w1', 'temp_w1 =\nw1 ⊕ temp_w0', fillcolor='#d5e8d4')
    dot.node('temp_w2', 'temp_w2 =\nw2 ⊕ temp_w1', fillcolor='#d5e8d4')
    dot.node('temp_w3', 'temp_w3 =\nw3 ⊕ temp_w2', fillcolor='#d5e8d4')

    # Output
    dot.node('out_mux', 'Output\nMUX', fillcolor='#dae8fc')
    dot.node('round_key', 'round_key\n[31:0]', fillcolor='#fff2cc',
             style='rounded,filled,bold')
    dot.node('word_addr', 'word_addr[5:0]\n(0-43)', fillcolor='#e1d5e7')

    # Control signals
    dot.node('ready', 'ready', fillcolor='#e1d5e7')
    dot.node('next', 'next', fillcolor='#e1d5e7')
    dot.node('start', 'start', fillcolor='#e1d5e7')

    # Annotations
    dot.node('annot1', 'Only 128 bits stored\nvs 1408 bits\n(91% savings)',
             fillcolor='#ffe6cc', shape='note')
    dot.node('annot2', 'Next round keys\ngenerated\ncombinationally',
             fillcolor='#ffe6cc', shape='note')

    # Edges
    dot.edge('title', 'master_key', style='invis')
    dot.edge('master_key', 'w0')
    dot.edge('w3', 'rotword')
    dot.edge('rotword', 'sbox0')
    dot.edge('sbox0', 'temp_w0')
    dot.edge('rcon', 'temp_w0')
    dot.edge('temp_w0', 'temp_w1')
    dot.edge('temp_w1', 'temp_w2')
    dot.edge('temp_w2', 'temp_w3')

    # Feedback loops
    dot.edge('temp_w0', 'w0', style='dashed', color='green')
    dot.edge('temp_w1', 'w1', style='dashed', color='green')
    dot.edge('temp_w2', 'w2', style='dashed', color='green')
    dot.edge('temp_w3', 'w3', style='dashed', color='green')

    # Output path
    dot.edge('w0', 'out_mux')
    dot.edge('w1', 'out_mux')
    dot.edge('w2', 'out_mux')
    dot.edge('w3', 'out_mux')
    dot.edge('out_mux', 'round_key')

    return dot


def create_datapath_diagram():
    """Create the 32-bit AES datapath diagram"""
    dot = Digraph(comment='AES 32-bit Datapath', format='png')
    dot.attr(rankdir='TB', splines='ortho', nodesep='0.5', ranksep='0.6')
    dot.attr('node', shape='box', style='rounded,filled', fontname='Arial')

    # Title
    dot.node('title', 'AES-128 Core: 32-bit Datapath',
             shape='plaintext', fontsize='16', fontname='Arial Bold')

    # Input
    dot.node('data_in', 'data_in [127:0]', fillcolor='#dae8fc',
             style='rounded,filled,bold')

    # State register subgraph
    with dot.subgraph(name='cluster_state') as c:
        c.attr(label='AES State Register [127:0]', style='dashed')
        c.node('col0', 'Column 0\n[127:96]', fillcolor='#fff2cc')
        c.node('col1', 'Column 1\n[95:64]', fillcolor='#fff2cc')
        c.node('col2', 'Column 2\n[63:32]', fillcolor='#fff2cc')
        c.node('col3', 'Column 3\n[31:0]', fillcolor='#fff2cc')

    # Column selector
    dot.node('col_sel', 'Column Selector\ncol_cnt [1:0]', fillcolor='#d5e8d4')
    dot.node('cur_col', 'Current Column\n[31:0]', fillcolor='#fff2cc')

    # SubBytes subgraph
    with dot.subgraph(name='cluster_subbytes') as c:
        c.attr(label='SubBytes (4 Shared S-boxes)', style='dashed')
        c.node('sb0', 'S-box 0', fillcolor='#f8cecc')
        c.node('sb1', 'S-box 1', fillcolor='#f8cecc')
        c.node('sb2', 'S-box 2', fillcolor='#f8cecc')
        c.node('sb3', 'S-box 3', fillcolor='#f8cecc')

    # Transformations
    dot.node('temp_state', 'Temp State [127:0]', fillcolor='#dae8fc')
    dot.node('shiftrows', 'ShiftRows\n(Full 128-bit)', fillcolor='#d5e8d4')
    dot.node('shift_col', 'Shifted Column\n[31:0]', fillcolor='#fff2cc')
    dot.node('mixcols', 'MixColumns\n(32-bit)', fillcolor='#d5e8d4')
    dot.node('addrk', 'AddRoundKey\n(XOR)', fillcolor='#d5e8d4')

    # Key management subgraph
    with dot.subgraph(name='cluster_key') as c:
        c.attr(label='Key Management', style='dashed')
        c.node('key_reg', 'Round Key\nShift Register\n[0:43]',
               fillcolor='#fff2cc')
        c.node('key_exp', 'Key Expansion\nOTF', fillcolor='#dae8fc')
        c.node('rkey', 'Round Key\n[31:0]', fillcolor='#fff2cc',
               style='rounded,filled,bold')

    # Output
    dot.node('data_out', 'data_out [127:0]', fillcolor='#dae8fc',
             style='rounded,filled,bold')

    # Control FSM
    dot.node('fsm', 'Control FSM\n\nStates:\n• IDLE • KEY_EXPAND\n• ROUND0 • ENC_SUB\n• ENC_SHIFT_MIX\n• DEC_SHIFT_SUB\n• DEC_ADD_MIX\n• DONE\n\nCounters:\n• round_cnt[3:0]\n• col_cnt[1:0]\n• phase[1:0]',
             fillcolor='#e1d5e7', shape='box')

    # Annotations
    dot.node('annot1', 'Processes\n1 column per cycle',
             fillcolor='#ffe6cc', shape='note')
    dot.node('annot2', '44 words stored\n(176 bytes)',
             fillcolor='#ffe6cc', shape='note')
    dot.node('annot3', '4 cycles per transform\n~440-480 cycles total\n2.27 Mbps @ 100MHz',
             fillcolor='#ffe6cc', shape='note')

    # Edges - Main datapath
    dot.edge('title', 'data_in', style='invis')
    dot.edge('data_in', 'col0')
    dot.edge('col0', 'col_sel')
    dot.edge('col_sel', 'cur_col')
    dot.edge('cur_col', 'sb0')
    dot.edge('sb0', 'temp_state')
    dot.edge('temp_state', 'shiftrows')
    dot.edge('shiftrows', 'shift_col')
    dot.edge('shift_col', 'mixcols')
    dot.edge('mixcols', 'addrk')
    dot.edge('addrk', 'data_out')

    # Key path
    dot.edge('key_reg', 'key_exp')
    dot.edge('key_exp', 'rkey')
    dot.edge('rkey', 'addrk')

    # Feedback
    dot.edge('addrk', 'col0', style='dashed', color='green',
             label='write back')

    # Control
    dot.edge('fsm', 'col_sel', style='dashed', color='purple')
    dot.edge('fsm', 'data_out', style='dashed', color='purple')

    return dot


def main():
    """Generate all diagrams"""
    if not GRAPHVIZ_AVAILABLE:
        return

    print("Generating AES architecture diagrams...")

    # Generate key expansion diagram
    print("1. Creating key expansion module diagram...")
    key_exp = create_key_expansion_diagram()
    key_exp.render('key_expansion_diagram', format='png', cleanup=True)
    key_exp.render('key_expansion_diagram', format='svg', cleanup=True)
    print("   ✓ Generated: key_expansion_diagram.png")
    print("   ✓ Generated: key_expansion_diagram.svg")

    # Generate datapath diagram
    print("2. Creating 32-bit datapath diagram...")
    datapath = create_datapath_diagram()
    datapath.render('datapath_diagram', format='png', cleanup=True)
    datapath.render('datapath_diagram', format='svg', cleanup=True)
    print("   ✓ Generated: datapath_diagram.png")
    print("   ✓ Generated: datapath_diagram.svg")

    print("\n✅ All diagrams generated successfully!")
    print("\nFiles created:")
    print("  - key_expansion_diagram.png")
    print("  - key_expansion_diagram.svg")
    print("  - datapath_diagram.png")
    print("  - datapath_diagram.svg")


if __name__ == '__main__':
    main()
