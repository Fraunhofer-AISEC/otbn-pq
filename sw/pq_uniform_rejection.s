/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Uniform Rejection Implementation */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load operands into WDRs */
li x2, 0
li x3, 0
li x4, 30
li x5, 96

/*************************************************/
/*                Load Inital State              */
/*************************************************/

/* Load inital state into WDRs w0 - w9 */

/* A[3,0] A[2,0] A[1,0] A[0,0] */
bn.lid x2++, 0(x0) 

/* A[4,0] */
bn.lid x2++, 32(x0)

/* A[3,1] A[2,1] A[1,1] A[0,1] */
bn.lid x2++, 64(x0) 

/* A[4,1] */
bn.lid x2++, 96(x0)

/* A[3,2] A[2,2] A[1,2] A[0,2] */
bn.lid x2++, 128(x0) 

/* A[4,2] */
bn.lid x2++, 160(x0) 

/* A[3,3] A[2,3] A[1,3] A[0,3] */
bn.lid x2++, 192(x0)

/* A[4,3] */
bn.lid x2++, 224(x0) 

/* A[3,4] A[2,4] A[1,4] A[0,4] */
bn.lid x2++, 256(x0)

/* A[4,4] */
bn.lid x2++, 288(x0) 

/* Load All-Zero in W30*/
bn.lid x4++, 320(x0) 

/* Align all samples */
li x10, 0
li x13, 14

jal x1, align_chunks

li x4, 14
li x2, 0

/*bn.sid x4++, 544(x2)
bn.sid x4++, 576(x2)

bn.sid x4++, 608(x2)
bn.sid x4++, 640(x2)

bn.sid x4++, 672(x2)
bn.sid x4++, 704(x2)

bn.sid x4++, 736(x2)
*/
/* Load All-Zero in W22*/
li x22, 22
bn.lid x22, 320(x0) 

li x12, 16
li x22, 0

/* Rejection Sampling */
jal x1, rej_uniform

/* Store results from [w0-w9] to dmem */

/*
li x4, 14
li x2, 0

bn.sid x4++, 544(x2)
bn.sid x4++, 576(x2)

bn.sid x4++, 608(x2)
bn.sid x4++, 640(x2)

bn.sid x4++, 672(x2)
bn.sid x4++, 704(x2)

bn.sid x4++, 736(x2)
*/
ecall


/***********************************************/
/*      24-bit Data Alignment Procedure       
*                                            
* @param[in]   : W20              
* @param[out]  : W21             
* clobbered registers: x4, W30, W31     
*
*/
/***********************************************/

data_alignment:

/* Load Bitmask in W31*/
li x4, 31
bn.lid x4, 416(x0)

/* Mask sample and store it in W21*/
bn.and w21, w20, w31


/* Update Bitmask */
bn.or w30, w30, w31 << 32

/* Mask sample*/
bn.and w30, w30, w20 << 8

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 64

/* Mask sample*/
bn.and w30, w30, w20 << 16

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 96

/* Mask sample*/
bn.and w30, w30, w0 << 24

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 128

/* Mask sample*/
bn.and w30, w30, w20 << 32

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 160

/* Mask sample*/
bn.and w30, w30, w20 << 40

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 192

/* Mask sample*/
bn.and w30, w30, w20 << 48

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 224

/* Mask sample*/
bn.and w30, w30, w20 << 56

/* Store sample in W21 */
bn.or w21, w21, w30

ret


/************************************************************/
/* Align chunk of samples (inside 5 WDRs) */
/*
* @param[in]  x10: address of raw Keccak samples inside WDRs
* @param[in]  x13: address of output WDR 
* @param[out] W[x13+i] for i in [0,6]
*
* clobbered registers: x10, x11, x12, x13,
*                      w10, w11, w12,
*                      w20, w21, w30
*
*/
/************************************************************/

align_chunks:

/* Load address of WDR for intermediate computation in x11 (W10 fixed)*/
li x11, 10

/* Load address of Input WDR for further function call in x12 (W20 fixed)*/
li x12, 20

/* Data Layout I */

/* Align samples for first WDR*/
bn.movr x12, x10
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Store S[3-0] in W[10]*/
li x11, 10
bn.movr x11, x10++

/* Store S[4] in W[11]*/
li x11, 11
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (lower part)*/
bn.rshi w20, w11, w10 >> 192

/* Store S[7-5] in W[12]*/
li x11, 12
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (upper part)*/
bn.or w20, w20, w12 << 128

/* Align samples for second WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Load All-Zero in W30*/
bn.addi w30, w30, 0
bn.rshi w20, w30, w12 >> 64

/* Align samples for third WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Data Layout II */

/* Store S[9] in W[10]*/
li x11, 10
bn.movr x11, x10++

/* Store S[13-10] in W[11]*/
li x11, 11
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 */
bn.or w20, w10, w11 << 64

/* Align samples for fourth WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Store S[14] in W[12]*/
li x11, 12
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 */
bn.rshi w20, w12, w11 >> 128

/* Align samples for fifth WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Data Layout I */

/* Align samples for sixth WDR*/
bn.movr x12, x10
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Store S[18-15] in W[10]*/
li x11, 10
bn.movr x11, x10++

/* Store S[19] in W[11]*/
li x11, 11
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (lower part)*/
bn.rshi w20, w11, w10 >> 192

/* Store S[23-20] in W[12]*/
li x11, 12
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (upper part)*/
bn.or w20, w20, w12 << 128

/* Align samples for second WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

ret



/************************************************************/
/* Rejection Uniform */
/*
* @param[in]  x12: number of coefficients to be sampled left 
* @param[in]  x22: pointer of first output sample inside DMEM
* @param[in]  w22: all zero vector
* @param[out] DMEM[x22+i] for i in [0,6]
*
* clobbered registers: x4 : 
                       x10: 
                       x11: 
                       x12: 
                       x13: 
                       x14: Value of ?(sample < q)
                       x15: Current WDR word
                       x16: Current WDR 
                       x22:
*                      w10, w11, w12,
*                      w20, w21, w30, w31
*
*/
/************************************************************/
rej_uniform: 

/* set fixed values to address w22 and w14*/
li x11, 176
li x10, 112

li x20, 20
li x21, 14

bn.mov w23, w22

/* Load index for input samples into PQSPR idx1 */
pq.srw 3, x11

/* Load index for output samples into PQSPR idx0*/
pq.srw 4, x10

/* Position of current source WDR - Initialize with 7 */
li x16, 6

/* Position inside current destination WDR - Initialize with 8 */
li x17, 8

/* Load Prime in W30*/
li x4, 30
bn.lid x4, 448(x0)

/* Build Prime-Vector */
bn.or w30, w30, w30 << 32
bn.or w30, w30, w30 << 64
bn.or w30, w30, w30 << 128

/* Loop through WDRs containing potential sampels */
loop_source_wdr:

/* Position inside current source WDR - Initialize with 7 */
li x15, 8

/* Copy sample in W20 for comparison */
bn.movr x20, x21
addi x21, x21, 1

/* Reset word select inside w22*/
/*
li x10, 176
pq.srw 3, x11
*/

/* Load Bitmask in W31*/
li x4, 31
bn.lid x4, 416(x0)

/* Loop for words inside WDR */
loop_source_wdr_word:

/* Mask sample in W20 and store it in W29*/
bn.and w29, w20, w31

/* Mask Prime in W30 and store it in W28*/
bn.and w28, w30, w31

/* Compare if sample < q */
bn.cmp w28, w29, FG0
csrrw x14, 1984, x0

/* Check for overflow (overflow <=> sample > q)*/
andi x14, x14, 1

li x4, 1
sub x15, x15, x4

/* If sample > q skip the storing of the sample*/
bne x14, x0, sample_rejected

/* Store sample */
pq.add.ind 0, 0, 0, 0, 0

/* Decrement number of coefficients left*/
li x4, 1
sub x12, x12, x4

/* Check if WDR full --> store it, increment DMEM address, reset WDR */
/* Update Loop Variable for WDR word */
li x4, 1
sub x17, x17, x4

li x4, 22
bne x17, x0, wdr_not_full
bn.sid x4, 544(x22++)
bn.and w21, w21, w29
li x17, 7

/* Reset All Zero Vector */
bn.mov w22, w23

/* Reset WDR word select for W22*/
li x11, 176
pq.srw 3, x11

beq x0, x0, sample_rejected
wdr_not_full:

/* Increment destination word */
addi x11, x11, 1

sample_rejected:

/* Increment source word*/
addi x10, x10, 1

/* If no coefficient is left to be samples, jump out of the loop */
beq x12, x0, end_loops

/* Update source and destination indices (check if both necessary)*/
pq.srw 3, x11
pq.srw 4, x10

/* Update Mask */
bn.or w31, w23, w31 << 32

/* Loop for words inside WDR */
bne x15, x0, loop_source_wdr_word

/* Loop through WDRs containing potential sampels */
li x4, 1
sub x16, x16, x4
bne x16, x0, loop_source_wdr

end_loops:

ret

.section .data

/* 256-bit integer

   0000000000000000 0000000000000000
   0000000000000000 0000000000000D01

   (.quad below is in reverse order) */

coef0:
  .quad 0x00000001FFFFFFFF
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

coef1:
  .quad 0x0000000900000008
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

coef3:
  .quad 0x0000001900000018
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

coef5:
  .quad 0x0000002900000028
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

coef7:
  .quad 0x0000003900000038
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

coef9:
  .quad 0x0000004900000048
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

allzero:
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

message:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  
nonce:
  .word 0x00000B0A

nonce_extended:
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  
bitmask:
  .word 0x007FFFFF
  
bitmask_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime:
  .quad 0x000000000000FFFF
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
