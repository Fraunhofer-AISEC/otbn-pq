// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module bitreverse
    import otbn_pq_pkg::*;
(
    input   bitrev_pq_operation_t                   operation_i,
    output  logic                   [31:0]          operation_result_o
);
    logic   [5:0]       bitrev_6;
    logic   [6:0]       bitrev_7;
    logic   [7:0]       bitrev_8;
    logic   [8:0]       bitrev_9;
    logic   [9:0]       bitrev_10;
    logic   [10:0]      bitrev_11;
    logic   [11:0]      bitrev_12;
    
    logic   [31:0]      bitrev_before_shift;
    
    always_comb begin
    
        operation_result_o = operation_i.operand_a;
        
        bitrev_6 = {operation_i.operand_a[0], 
                    operation_i.operand_a[1], 
                    operation_i.operand_a[2], 
                    operation_i.operand_a[3], 
                    operation_i.operand_a[4], 
                    operation_i.operand_a[5]
                   };
    
        bitrev_7 = {operation_i.operand_a[0], 
                    operation_i.operand_a[1], 
                    operation_i.operand_a[2], 
                    operation_i.operand_a[3], 
                    operation_i.operand_a[4], 
                    operation_i.operand_a[5],
                    operation_i.operand_a[6]
                   };
    
        bitrev_8 = {operation_i.operand_a[0], 
                    operation_i.operand_a[1], 
                    operation_i.operand_a[2], 
                    operation_i.operand_a[3], 
                    operation_i.operand_a[4], 
                    operation_i.operand_a[5],
                    operation_i.operand_a[6],
                    operation_i.operand_a[7]
                   };
    
        bitrev_9 = {operation_i.operand_a[0], 
                    operation_i.operand_a[1], 
                    operation_i.operand_a[2], 
                    operation_i.operand_a[3], 
                    operation_i.operand_a[4], 
                    operation_i.operand_a[5],
                    operation_i.operand_a[6],
                    operation_i.operand_a[7],
                    operation_i.operand_a[8]
                   };
                   
        bitrev_10 = {operation_i.operand_a[0], 
                    operation_i.operand_a[1], 
                    operation_i.operand_a[2], 
                    operation_i.operand_a[3], 
                    operation_i.operand_a[4], 
                    operation_i.operand_a[5],
                    operation_i.operand_a[6],
                    operation_i.operand_a[7],
                    operation_i.operand_a[8],
                    operation_i.operand_a[9]
                   };
                   
        bitrev_11 = {operation_i.operand_a[0], 
                    operation_i.operand_a[1], 
                    operation_i.operand_a[2], 
                    operation_i.operand_a[3], 
                    operation_i.operand_a[4], 
                    operation_i.operand_a[5],
                    operation_i.operand_a[6],
                    operation_i.operand_a[7],
                    operation_i.operand_a[8],
                    operation_i.operand_a[9],
                    operation_i.operand_a[10]
                   };
                   
            bitrev_12 = {operation_i.operand_a[0], 
                    operation_i.operand_a[1], 
                    operation_i.operand_a[2], 
                    operation_i.operand_a[3], 
                    operation_i.operand_a[4], 
                    operation_i.operand_a[5],
                    operation_i.operand_a[6],
                    operation_i.operand_a[7],
                    operation_i.operand_a[8],
                    operation_i.operand_a[9],
                    operation_i.operand_a[10],
                    operation_i.operand_a[11]
                   };
                   
        unique case (operation_i.nof_bits)
            'd6:                bitrev_before_shift = {operation_i.operand_a[31:6], bitrev_6};
            'd7:                bitrev_before_shift = {operation_i.operand_a[31:7], bitrev_7};
            'd8:                bitrev_before_shift = {operation_i.operand_a[31:8], bitrev_8};
            'd9:                bitrev_before_shift = {operation_i.operand_a[31:9], bitrev_9};
            'd10:               bitrev_before_shift = {operation_i.operand_a[31:10], bitrev_10};
            'd11:               bitrev_before_shift = {operation_i.operand_a[31:11], bitrev_11};
            'd12:               bitrev_before_shift = {operation_i.operand_a[31:12], bitrev_12};
            default:            bitrev_before_shift = operation_i.operand_a;
        endcase
        
        unique case (operation_i.op)
            BitrevOpPq:         operation_result_o = bitrev_before_shift;
            BitrevOpPqShift:    operation_result_o = {bitrev_before_shift[29:0], 2'b0};
            default:            operation_result_o = bitrev_before_shift;
        endcase
        
    end

endmodule
