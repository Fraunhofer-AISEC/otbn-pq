// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* verilator lint_off UNUSED */

module otbn_multiplier
#(
    parameter DATA_WIDTH = 32,
    parameter LOG_R = 32
)
(
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    input   logic   [DATA_WIDTH-1:0]    q_i,
    input   logic   [LOG_R-1:0]         q_dash_i,
    output  logic   [DATA_WIDTH-1:0]    res_o   
);

logic   [2*DATA_WIDTH-1:0]          p;
logic   [2*LOG_R-1:0]               m;
logic   [DATA_WIDTH+LOG_R:0]        s;
logic   [DATA_WIDTH-1:0]            t;

always_comb
begin
    p = op0_i * op1_i;
    m = p[LOG_R-1:0] * q_dash_i;
    s = p + (m[LOG_R-1:0] * q_i);
    t = s[LOG_R+DATA_WIDTH-1:LOG_R];
    if (q_i <= t) begin
        t = t-q_i;
    end
end

assign res_o = t;

endmodule: otbn_multiplier
