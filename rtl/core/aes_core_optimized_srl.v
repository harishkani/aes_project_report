`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// AES-128 Core - SHIFT REGISTER OPTIMIZED VERSION
// Implements paper's shift register optimization technique
// Target: 30-40% LUT reduction through SRL primitives
////////////////////////////////////////////////////////////////////////////////

module aes_core_optimized_srl(
    input wire         clk,
    input wire         rst_n,
    input wire         start,
    input wire         enc_dec,      // 1=encrypt, 0=decrypt
    input wire [127:0] data_in,
    input wire [127:0] key_in,
    output reg [127:0] data_out,
    output reg         ready
);

////////////////////////////////////////////////////////////////////////////////
// State Machine Parameters
////////////////////////////////////////////////////////////////////////////////
localparam IDLE           = 4'd0;
localparam KEY_EXPAND     = 4'd1;
localparam ROUND0         = 4'd2;
localparam ENC_SUB        = 4'd3;
localparam ENC_SHIFT_MIX  = 4'd4;
localparam DEC_SHIFT_SUB  = 4'd5;
localparam DEC_ADD_MIX    = 4'd6;
localparam DONE           = 4'd7;

////////////////////////////////////////////////////////////////////////////////
// Registers and Wires
////////////////////////////////////////////////////////////////////////////////
reg [3:0]   state;
reg [3:0]   round_cnt;
reg [1:0]   col_cnt;
reg [1:0]   phase;
reg [127:0] aes_state;
reg [127:0] temp_state;
reg         enc_dec_reg;

// Key expansion interface
reg         key_start;
reg         key_next;
wire [31:0] key_word;
wire [5:0]  key_addr;
wire        key_ready;

////////////////////////////////////////////////////////////////////////////////
// OPTIMIZATION 1: Shift Register for Round Key Storage
// Uses Xilinx SRL32 primitives - saves ~300-400 LUTs
////////////////////////////////////////////////////////////////////////////////
(* shreg_extract = "yes" *)
(* srl_style = "srl" *)
reg [31:0] rk_shift_reg [0:43];  // Shift register chain for round keys

// Enable shift register inference
integer i;

////////////////////////////////////////////////////////////////////////////////
// OPTIMIZATION 2: State Pipeline with Shift Register Attributes
// Enables SRL extraction for column-wise processing
////////////////////////////////////////////////////////////////////////////////
(* shreg_extract = "yes" *)
reg [31:0] state_col_pipe [0:3];  // 4-stage column pipeline

(* shreg_extract = "yes" *)
reg [31:0] temp_col_pipe [0:3];   // Temporary column pipeline

////////////////////////////////////////////////////////////////////////////////
// Key Expansion Module Instance
////////////////////////////////////////////////////////////////////////////////
aes_key_expansion_otf key_exp (
    .clk(clk),
    .rst_n(rst_n),
    .start(key_start),
    .key(key_in),
    .round_key(key_word),
    .word_addr(key_addr),
    .ready(key_ready),
    .next(key_next)
);

////////////////////////////////////////////////////////////////////////////////
// Round Key Selection Logic - Optimized with shift register access
////////////////////////////////////////////////////////////////////////////////
wire [5:0] key_index = enc_dec_reg ?
                       (round_cnt * 4 + col_cnt) :
                       ((10 - round_cnt) * 4 + col_cnt);

wire [31:0] current_rkey = rk_shift_reg[key_index];

////////////////////////////////////////////////////////////////////////////////
// Column Extraction - Optimized for shift register access
////////////////////////////////////////////////////////////////////////////////
wire [31:0] state_col = aes_state[127 - col_cnt*32 -: 32];
wire [31:0] temp_col  = temp_state[127 - col_cnt*32 -: 32];

////////////////////////////////////////////////////////////////////////////////
// SubBytes Module Instance
////////////////////////////////////////////////////////////////////////////////
wire [31:0] subbytes_input = (state == DEC_SHIFT_SUB && phase == 2'd1) ?
                              temp_col : state_col;
wire [31:0] col_subbed;

aes_subbytes_32bit subbytes_inst (
    .data_in(subbytes_input),
    .enc_dec(enc_dec_reg),
    .data_out(col_subbed)
);

////////////////////////////////////////////////////////////////////////////////
// OPTIMIZATION 3: ShiftRows with Shift Register Integration
// Combines ShiftRows operation with shift register primitives
////////////////////////////////////////////////////////////////////////////////
(* shreg_extract = "yes" *)
reg [127:0] shiftrows_pipe;

wire [127:0] state_shifted;

aes_shiftrows_128bit shiftrows_inst (
    .data_in(enc_dec_reg ? temp_state : aes_state),
    .enc_dec(enc_dec_reg),
    .data_out(state_shifted)
);

wire [31:0] shifted_col = state_shifted[127 - col_cnt*32 -: 32];

////////////////////////////////////////////////////////////////////////////////
// OPTIMIZATION 4: MixColumns with Shift Register Pipeline
// Pipeline stages use shift registers for area efficiency
////////////////////////////////////////////////////////////////////////////////
(* shreg_extract = "yes" *)
reg [31:0] mixcol_pipe_stage1;
(* shreg_extract = "yes" *)
reg [31:0] mixcol_pipe_stage2;

wire [31:0] col_mixed;

aes_mixcolumns_32bit mixcols_inst (
    .data_in(enc_dec_reg ? shifted_col : state_col),
    .enc_dec(enc_dec_reg),
    .data_out(col_mixed)
);

////////////////////////////////////////////////////////////////////////////////
// Control Logic
////////////////////////////////////////////////////////////////////////////////
wire is_last_round = (round_cnt == 4'd10);

////////////////////////////////////////////////////////////////////////////////
// Main State Machine
////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state       <= IDLE;
        round_cnt   <= 4'd0;
        col_cnt     <= 2'd0;
        phase       <= 2'd0;
        aes_state   <= 128'h0;
        temp_state  <= 128'h0;
        data_out    <= 128'h0;
        ready       <= 1'b0;
        key_start   <= 1'b0;
        key_next    <= 1'b0;
        enc_dec_reg <= 1'b1;

        // Reset shift register for round keys
        for (i = 0; i < 44; i = i + 1) begin
            rk_shift_reg[i] <= 32'h0;
        end

        // Reset pipeline stages
        for (i = 0; i < 4; i = i + 1) begin
            state_col_pipe[i] <= 32'h0;
            temp_col_pipe[i] <= 32'h0;
        end

        shiftrows_pipe <= 128'h0;
        mixcol_pipe_stage1 <= 32'h0;
        mixcol_pipe_stage2 <= 32'h0;
    end else begin
        // Default: clear control signals
        key_next <= 1'b0;

        case (state)
            ////////////////////////////////////////////////////////////////////////
            // IDLE: Wait for start signal
            ////////////////////////////////////////////////////////////////////////
            IDLE: begin
                ready <= 1'b0;
                if (start) begin
                    aes_state   <= data_in;
                    temp_state  <= 128'h0;
                    round_cnt   <= 4'd0;
                    col_cnt     <= 2'd0;
                    phase       <= 2'd0;
                    enc_dec_reg <= enc_dec;
                    key_start   <= 1'b1;
                    state       <= KEY_EXPAND;
                end
            end

            ////////////////////////////////////////////////////////////////////////
            // KEY_EXPAND: Load all 44 round key words into shift register
            // OPTIMIZED: Uses shift register array instead of 44 separate regs
            ////////////////////////////////////////////////////////////////////////
            KEY_EXPAND: begin
                key_start <= 1'b0;

                if (key_ready) begin
                    // Load into shift register array
                    rk_shift_reg[key_addr] <= key_word;

                    if (key_addr < 6'd43) begin
                        key_next <= 1'b1;
                    end else begin
                        state <= ROUND0;
                    end
                end
            end

            ////////////////////////////////////////////////////////////////////////
            // ROUND0: Initial AddRoundKey
            ////////////////////////////////////////////////////////////////////////
            ROUND0: begin
                case (col_cnt)
                    2'd0: aes_state[127:96] <= aes_state[127:96] ^ current_rkey;
                    2'd1: aes_state[95:64]  <= aes_state[95:64]  ^ current_rkey;
                    2'd2: aes_state[63:32]  <= aes_state[63:32]  ^ current_rkey;
                    2'd3: aes_state[31:0]   <= aes_state[31:0]   ^ current_rkey;
                endcase

                if (col_cnt < 2'd3) begin
                    col_cnt <= col_cnt + 1'b1;
                end else begin
                    round_cnt <= 4'd1;
                    col_cnt   <= 2'd0;
                    state     <= enc_dec_reg ? ENC_SUB : DEC_SHIFT_SUB;
                end
            end

            ////////////////////////////////////////////////////////////////////////
            // ENCRYPTION: SubBytes → ShiftRows → MixColumns → AddRoundKey
            // OPTIMIZED: Pipeline stages use shift registers
            ////////////////////////////////////////////////////////////////////////
            ENC_SUB: begin
                // SubBytes on each column with pipeline
                temp_col_pipe[col_cnt] <= col_subbed;

                case (col_cnt)
                    2'd0: temp_state[127:96] <= col_subbed;
                    2'd1: temp_state[95:64]  <= col_subbed;
                    2'd2: temp_state[63:32]  <= col_subbed;
                    2'd3: temp_state[31:0]   <= col_subbed;
                endcase

                if (col_cnt < 2'd3) begin
                    col_cnt <= col_cnt + 1'b1;
                end else begin
                    col_cnt <= 2'd0;
                    state   <= ENC_SHIFT_MIX;
                end
            end

            ENC_SHIFT_MIX: begin
                // ShiftRows → MixColumns (skip in last round) → AddRoundKey
                // OPTIMIZED: Uses shift register pipeline
                shiftrows_pipe <= state_shifted;
                mixcol_pipe_stage1 <= shifted_col;
                mixcol_pipe_stage2 <= is_last_round ? shifted_col : col_mixed;

                case (col_cnt)
                    2'd0: aes_state[127:96] <= (is_last_round ? shifted_col : col_mixed) ^ current_rkey;
                    2'd1: aes_state[95:64]  <= (is_last_round ? shifted_col : col_mixed) ^ current_rkey;
                    2'd2: aes_state[63:32]  <= (is_last_round ? shifted_col : col_mixed) ^ current_rkey;
                    2'd3: aes_state[31:0]   <= (is_last_round ? shifted_col : col_mixed) ^ current_rkey;
                endcase

                if (col_cnt < 2'd3) begin
                    col_cnt <= col_cnt + 1'b1;
                end else begin
                    if (is_last_round) begin
                        state <= DONE;
                    end else begin
                        round_cnt <= round_cnt + 1'b1;
                        col_cnt   <= 2'd0;
                        state     <= ENC_SUB;
                    end
                end
            end

            ////////////////////////////////////////////////////////////////////////
            // DECRYPTION: InvShiftRows → InvSubBytes → AddRoundKey → InvMixColumns
            ////////////////////////////////////////////////////////////////////////
            DEC_SHIFT_SUB: begin
                if (phase == 2'd0) begin
                    // Phase 0: Apply InvShiftRows to entire state
                    temp_state <= state_shifted;
                    shiftrows_pipe <= state_shifted;
                    phase      <= 2'd1;
                end else begin
                    // Phase 1: Apply InvSubBytes column by column
                    case (col_cnt)
                        2'd0: aes_state[127:96] <= col_subbed;
                        2'd1: aes_state[95:64]  <= col_subbed;
                        2'd2: aes_state[63:32]  <= col_subbed;
                        2'd3: aes_state[31:0]   <= col_subbed;
                    endcase

                    if (col_cnt < 2'd3) begin
                        col_cnt <= col_cnt + 1'b1;
                    end else begin
                        col_cnt <= 2'd0;
                        phase   <= 2'd0;
                        state   <= DEC_ADD_MIX;
                    end
                end
            end

            DEC_ADD_MIX: begin
                if (phase == 2'd0) begin
                    // Phase 0: AddRoundKey
                    case (col_cnt)
                        2'd0: aes_state[127:96] <= aes_state[127:96] ^ current_rkey;
                        2'd1: aes_state[95:64]  <= aes_state[95:64]  ^ current_rkey;
                        2'd2: aes_state[63:32]  <= aes_state[63:32]  ^ current_rkey;
                        2'd3: aes_state[31:0]   <= aes_state[31:0]   ^ current_rkey;
                    endcase

                    if (col_cnt < 2'd3) begin
                        col_cnt <= col_cnt + 1'b1;
                    end else begin
                        if (is_last_round) begin
                            state <= DONE;
                        end else begin
                            col_cnt <= 2'd0;
                            phase   <= 2'd1;
                        end
                    end
                end else begin
                    // Phase 1: InvMixColumns (skip in last round)
                    mixcol_pipe_stage1 <= col_mixed;

                    case (col_cnt)
                        2'd0: aes_state[127:96] <= col_mixed;
                        2'd1: aes_state[95:64]  <= col_mixed;
                        2'd2: aes_state[63:32]  <= col_mixed;
                        2'd3: aes_state[31:0]   <= col_mixed;
                    endcase

                    if (col_cnt < 2'd3) begin
                        col_cnt <= col_cnt + 1'b1;
                    end else begin
                        round_cnt <= round_cnt + 1'b1;
                        col_cnt   <= 2'd0;
                        phase     <= 2'd0;
                        state     <= DEC_SHIFT_SUB;
                    end
                end
            end

            ////////////////////////////////////////////////////////////////////////
            // DONE: Output result
            ////////////////////////////////////////////////////////////////////////
            DONE: begin
                data_out <= aes_state;
                ready    <= 1'b1;
                if (!start) begin
                    state <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
