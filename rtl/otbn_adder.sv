// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module otbn_adder
#(
    parameter DATA_WIDTH = 32
)
(
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    input   logic   [DATA_WIDTH-1:0]    q_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);

    logic   [DATA_WIDTH-1:0]    add;
    logic   [DATA_WIDTH-1:0]    sub;

always_comb
begin    
    add = op0_i + op1_i;
    sub = add - q_i;
    res_o = (add < q_i) ? add : sub;
end

endmodule: otbn_adder
