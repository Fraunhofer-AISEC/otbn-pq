/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* UseHint Implementation */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load DMEM(0) into WDR w0*/
li x2, 0
bn.lid x2, 0(x0)

/* Configuration */

/* Address variables */
li x18, 16384
li x25, 0

/* Pointer to packed bits */  
li x13, 16384

/* Pointer to current lane */
li x24, 0
/*
* @param[in]  w0-w9: Keccak State 
* @param[in]  x13: pointer to packed w1 bytes 
* @param[in]  w10-w15: 
* @param[in]  x24: pointer to current lane 
* @param[in]  x15: number of 32-bit words left
*/

/* Init Keccak State with Zeros */
la x31, allzero
li x2, 0  
loopi 10, 1
  bn.lid x2++, 0(x31)  

  
/* Store Keccak State */
li x31, 24576
li x2, 0  
loopi 10, 2
  bn.sid x2++, 0(x31)  
  addi x31, x31, 32 
  
/* Start Address of w1 coefficients */
li x4, 0

loopi 4, 20
  jal x1, pack_w1

  /* Store packed bits */
  li x2, 10

  loopi 6, 2
    bn.sid x2++, 0(x18)
    addi x18, x18, 32
  
  
  /* Number of 32-bit words to absorb */
  li x15, 48
  
  li x31, 24576
  li x2, 0  
  loopi 10, 2
    bn.lid x2++, 0(x31)  
    addi x31, x31, 32  
    
  jal x1, keccak_absorb

  li x31, 24576
  li x2, 0  
  loopi 10, 2
    bn.sid x2++, 0(x31)  
    addi x31, x31, 32  
    
  addi x13, x13, 192
  addi x25, x25, 1024
  addi x4, x25, 0

ecall

/*************************************************/
/*                     PACK_W1                   */
/*
* @param[in]  x4: start address of w1 coefficients
* @param[out]  WDR10-W15: packed w1 bytes
*
* clobbered registers: x2: 
*                      x4: 
*                      x31: 
*                      w0: 
*                      w1: 
*                      w17: 
*                      w18: 
*                      w19: 
*                      w20:                   
*
*/
/*************************************************/
pack_w1:


  /* Load allzero in W18 */
  la x31, allzero
  li x2, 18  
  bn.lid x2, 0(x31)  
  
  /* Load Mask in W18 */
  bn.addi w18, w18, 255
  
  /* Load allzero in W19 */
  la x31, allzero
  li x2, 19
  bn.lid x2, 0(x31)
  
  /* Initialize Destination registers */
  li x2, 10
  loopi 6, 1
    bn.lid x2++, 0(x31) 
    
  /* Initialize idx register */
  
  /* Set WDR10 as Destination */
  li x2, 80
  pq.srw 3, x2
  
  loopi 16, 78
  
  /* Initialize idx register */
  
  /* Set WDR20 as Source */
  li x2, 160
  pq.srw 4, x2
  
  /* Load Coefficients of 16 WDRs */
  li x2, 0
  loopi 2, 2
    bn.lid x2++, 0(x4)
    addi x4, x4, 32 
  
  /* Shifting */
  
  /* Byte 0 */
  bn.and w20, w0, w18
  
  bn.rshi w17, w19, w0 >> 26
  bn.and w17, w17, w18
  bn.or w20, w20, w17
  
  /* Byte 1 */
  bn.rshi w17, w19, w0 >> 34
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 8 
  
  bn.rshi w17, w19, w0 >> 60
  bn.and w17, w17, w18 
  bn.or w20, w20, w17 << 8 
  
  /* Byte 2 */
  bn.rshi w17, w19, w0 >> 68
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 16
  
  bn.rshi w17, w19, w0 >> 94
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 16
  
  /* Byte 0 */
  bn.rshi w17, w19, w0 >> 128
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 24

  bn.rshi w17, w19, w0 >> 154
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 24
  
  /* Byte 1 */
  bn.rshi w17, w19, w0 >> 162
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 32 
  
  bn.rshi w17, w19, w0 >> 188
  bn.and w17, w17, w18 
  bn.or w20, w20, w17 << 32
  
  /* Byte 2 */
  bn.rshi w17, w19, w0 >> 196
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 40
  
  bn.rshi w17, w19, w0 >> 222
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 40
  
  /* Byte 0 */
  bn.and w17, w1, w18 
  bn.or w20, w20, w17 << 48 
  
  bn.rshi w17, w19, w1 >> 26
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 48

  /* Byte 1 */
  bn.rshi w17, w19, w1 >> 34
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 56  

  bn.rshi w17, w19, w1 >> 60
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 56    

  /* Byte 2 */
  bn.rshi w17, w19, w1 >> 68
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 64

  bn.rshi w17, w19, w1 >> 94
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 64  
  
  /* Byte 0 */
  bn.rshi w17, w19, w1 >> 128
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 72
  
  bn.rshi w17, w19, w1 >> 154
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 72  
     
  /* Byte 1 */
  bn.rshi w17, w19, w1 >> 162
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 80

  bn.rshi w17, w19, w1 >> 188
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 80  

  /* Byte 2 */
  bn.rshi w17, w19, w1 >> 196
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 88
  
  bn.rshi w17, w19, w1 >> 222
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 88  
  
  /* 96-bit packed into first 3 words of W20 */
  
  /* Move these words into Destination WDRs */
  loopi 3,1
    pq.add.ind 0, 0, 0, 0, 1
    
  addi x0, x0, 0    
  
ret

/*************************************************/
/*                  KECCAK_ABSORB                */
/*
* @param[in]  w0-w9: Keccak State 
* @param[in]  x13: pointer to packed w1 bytes 
* @param[in]  w10-w15: 
* @param[in]  x24: pointer to current lane 
* @param[in]  x15: number of 32-bit words left
*
* clobbered registers: x2: 
*                      x4:
*                      x5:
*
*/
/*************************************************/


keccak_absorb:

  /* Load and Configure Source Words */
  li x2, 10
  addi x14, x13, 0
  
  loopi 6, 2
    bn.lid x2++, 0(x14)
    addi x14, x14, 32
    
  /* Set w10 as source */
  addi x4, x0, 80
  pq.srw 4, x4

  /* Prepare Message */

  prep_loop:
  
  /* Load allzero in W20-W29 */
  la x31, allzero
  li x2, 20
  loopi 10, 1
    bn.lid x2++, 0(x31)
    
  /* Add 20 to lane pointer to address --> destination idx */
  addi x3, x24, 160
  pq.srw 3, x3
  
  state_loop:
  
    pq.add.ind 0, 0, 0, 0, 1
    
    /* Decrement missing 32-bit words */
    li x2, 1
    sub x15, x15, x2 
    
    /* If 51 --> full --> Keccak Permutation */
    li x5, 51
    bne x24, x5, skip_permutation
    
    /* Absorb Message  */
    bn.xor w0, w0, w20
    bn.xor w1, w1, w21
    bn.xor w2, w2, w22
    bn.xor w3, w3, w23
    bn.xor w4, w4, w24
    bn.xor w5, w5, w25
    bn.xor w6, w6, w26
    bn.xor w7, w7, w27
    bn.xor w8, w8, w28
    bn.xor w9, w9, w29
    
    la x5, rc0
    jal x1, keccak_permutation
    
    li x24, 0
    
    /* Load and Configure Source Words */
    li x2, 10
    addi x14, x13, 0
  
    loopi 6, 2
      bn.lid x2++, 0(x14)
      addi x14, x14, 32
    
    
    /* ToDo: Check # missing bits */
    beq x15, x0, end_keccak
    
    beq x0, x0, prep_loop
    
  /* Else */
    skip_permutation:
    /* Differentiate Cases when WDR stores 4 or 1 lanes */
    /* If 9 or 25 or 41 address is incremented +7 instead + 1 */
    li x5, 9

    /* Select 4-bit LSBs of x24 */
    andi x14, x24, 15

    bne x5, x14, increment_wdrword_address
    addi x24, x24, 6

    increment_wdrword_address: 
    addi x24, x24, 1    
    
    /* Add 20 to lane pointer to address --> destination idx */
    addi x3, x24, 160
    pq.srw 3, x3
  
    /* ToDo: Check # missing bits */
    bne x15, x0, state_loop
    
    /* Absorb Message  */
    bn.xor w0, w0, w20
    bn.xor w1, w1, w21
    bn.xor w2, w2, w22
    bn.xor w3, w3, w23
    bn.xor w4, w4, w24
    bn.xor w5, w5, w25
    bn.xor w6, w6, w26
    bn.xor w7, w7, w27
    bn.xor w8, w8, w28
    bn.xor w9, w9, w29

  end_keccak:
  
ret

/*************************************************/
/*               Keccak Permutation              */
/*
* @param[in] x5:    Address of RC0 in DMEM
* @param[in] W0-W9: Keccak State
*
* clobbered registers: x3: address of current RC value
*                      x4: internal variables
*                      w10-19: intermediate results
*                      w20-29: intermediate results
*                      w31: round counter value
*
*
*
*
*
*
*
*
*
/*************************************************/

keccak_permutation:

/* x4 as pointer to W31 */
li x4, 31

/* Copy Address of RC0 in X3  */
/* X3 is incremented each four round to address the correct RC in DMEM */
addi x3, x5, 0

/* Load DMEM(0) into WDR w31*/
bn.lid x4, 0(x3++)

/* Load round counter (rc0) into PQSR*/
pq.pqsrw 8, w31

loopi 6, 83
loopi 2, 80

/*************************************************/
/*                  Keccak Round                 */
/*************************************************/

/* Theta XOR Computation*/

bn.xor w10, w0, w2
bn.xor w11, w1, w3

bn.xor w10, w10, w4
bn.xor w11, w11, w5

bn.xor w10, w10, w6
bn.xor w11, w11, w7

bn.xor w10, w10, w8
bn.xor w11, w11, w9

/* Theta Parity Plain Computation */

pq.parity w10, w11

/* Theta, Rho and Pi Merged Computation */


pq.xorr w20.0, w0.0, w10.0, 1, 0
pq.xorr w24.0, w0.1, w10.1, 1, 0
pq.xorr w28.0, w0.2, w10.2, 1, 0
pq.xorr w22.0, w0.3, w10.3, 1, 0
pq.xorr w26.0, w1.0, w11.0, 1, 1

pq.xorr w26.1, w2.0, w10.0, 1, 0
pq.xorr w20.1, w2.1, w10.1, 1, 0
pq.xorr w24.1, w2.2, w10.2, 1, 0
pq.xorr w28.1, w2.3, w10.3, 1, 0
pq.xorr w22.1, w3.0, w11.0, 1, 1

pq.xorr w22.2, w4.0, w10.0, 1, 0
pq.xorr w26.2, w4.1, w10.1, 1, 0
pq.xorr w20.2, w4.2, w10.2, 1, 0
pq.xorr w24.2, w4.3, w10.3, 1, 0
pq.xorr w28.2, w5.0, w11.0, 1, 1

pq.xorr w28.3, w6.0, w10.0, 1, 0
pq.xorr w22.3, w6.1, w10.1, 1, 0
pq.xorr w26.3, w6.2, w10.2, 1, 0
pq.xorr w20.3, w6.3, w10.3, 1, 0
pq.xorr w24.3, w7.0, w11.0, 1, 1

pq.xorr w25.0, w8.0, w10.0, 1, 0
pq.xorr w29.0, w8.1, w10.1, 1, 0
pq.xorr w23.0, w8.2, w10.2, 1, 0
pq.xorr w27.0, w8.3, w10.3, 1, 0
pq.xorr w21.0, w9.0, w11.0, 1, 1

/* Chi Plain Computations */

pq.chi w20, w21
pq.chi w22, w23
pq.chi w24, w25
pq.chi w26, w27
pq.chi w28, w29

/* Iota Computation */

pq.ioata w20.0, w20.0, w20.0, 1

/* Theta XOR Computation*/

bn.xor w10, w20, w22
bn.xor w11, w21, w23

bn.xor w10, w10, w24
bn.xor w11, w11, w25

bn.xor w10, w10, w26
bn.xor w11, w11, w27

bn.xor w10, w10, w28
bn.xor w11, w11, w29

/* Theta Parity Plain Computation */

pq.parity w10, w11

/* Theta, Rho and Pi Merged Computation */

pq.xorr w0.0, w20.0, w10.0, 1, 0
pq.xorr w4.0, w20.1, w10.1, 1, 0
pq.xorr w8.0, w20.2, w10.2, 1, 0
pq.xorr w2.0, w20.3, w10.3, 1, 0
pq.xorr w6.0, w21.0, w11.0, 1, 1

pq.xorr w6.1, w22.0, w10.0, 1, 0
pq.xorr w0.1, w22.1, w10.1, 1, 0
pq.xorr w4.1, w22.2, w10.2, 1, 0
pq.xorr w8.1, w22.3, w10.3, 1, 0
pq.xorr w2.1, w23.0, w11.0, 1, 1

pq.xorr w2.2, w24.0, w10.0, 1, 0
pq.xorr w6.2, w24.1, w10.1, 1, 0
pq.xorr w0.2, w24.2, w10.2, 1, 0
pq.xorr w4.2, w24.3, w10.3, 1, 0
pq.xorr w8.2, w25.0, w11.0, 1, 1

pq.xorr w8.3, w26.0, w10.0, 1, 0
pq.xorr w2.3, w26.1, w10.1, 1, 0
pq.xorr w6.3, w26.2, w10.2, 1, 0
pq.xorr w0.3, w26.3, w10.3, 1, 0
pq.xorr w4.3, w27.0, w11.0, 1, 1

pq.xorr w5.0, w28.0, w10.0, 1, 0
pq.xorr w9.0, w28.1, w10.1, 1, 0
pq.xorr w3.0, w28.2, w10.2, 1, 0
pq.xorr w7.0, w28.3, w10.3, 1, 0
pq.xorr w1.0, w29.0, w11.0, 1, 1

/* Chi Plain Computations */

pq.chi w0, w1
pq.chi w2, w3
pq.chi w4, w5
pq.chi w6, w7
pq.chi w8, w9

/* Iota Computation */

pq.ioata w0.0, w0.0, w0.0, 1

/* Load DMEM(0) into WDR w0*/
bn.lid x4, 0(x3++)

/* Load round counter (rc0) into PQSR*/
pq.pqsrw 8, w31

/* End of Keccak Permutation */

ret


.section .data

.word 0x1a
.word 0xa
.word 0x5
.word 0x5
.word 0x22
.word 0x26
.word 0x2b
.word 0x2a
.word 0x1
.word 0x3
.word 0x7
.word 0x1f
.word 0xb
.word 0xa
.word 0x28
.word 0x1d
.word 0x26
.word 0x27
.word 0xb
.word 0x0
.word 0xc
.word 0x14
.word 0x23
.word 0x1e
.word 0x25
.word 0x16
.word 0x2a
.word 0x4
.word 0x21
.word 0xd
.word 0x8
.word 0x21
.word 0x11
.word 0xb
.word 0x17
.word 0x24
.word 0x28
.word 0x1d
.word 0x8
.word 0x18
.word 0x7
.word 0x21
.word 0x2
.word 0x22
.word 0x14
.word 0xc
.word 0x7
.word 0x12
.word 0x1
.word 0x21
.word 0x18
.word 0x20
.word 0x1d
.word 0x2
.word 0x21
.word 0x26
.word 0x22
.word 0x1
.word 0x21
.word 0x10
.word 0x2
.word 0x5
.word 0x17
.word 0x6
.word 0xd
.word 0x4
.word 0x2b
.word 0xf
.word 0x1d
.word 0x0
.word 0x1f
.word 0x7
.word 0x29
.word 0x1f
.word 0xe
.word 0x27
.word 0xe
.word 0x3
.word 0x21
.word 0xc
.word 0x5
.word 0xc
.word 0x4
.word 0x28
.word 0x17
.word 0x27
.word 0x15
.word 0x19
.word 0x8
.word 0x13
.word 0xf
.word 0x24
.word 0xa
.word 0x23
.word 0x2
.word 0x1d
.word 0x18
.word 0x22
.word 0x3
.word 0x4
.word 0x26
.word 0x7
.word 0x15
.word 0xc
.word 0x1e
.word 0x1c
.word 0x11
.word 0x3
.word 0x4
.word 0x2a
.word 0x25
.word 0x9
.word 0x11
.word 0x2a
.word 0x17
.word 0xb
.word 0x26
.word 0x1d
.word 0x8
.word 0x12
.word 0x9
.word 0x7
.word 0x13
.word 0x3
.word 0x10
.word 0x17
.word 0x2a
.word 0xd
.word 0x1c
.word 0x23
.word 0xc
.word 0x22
.word 0x1a
.word 0xd
.word 0x4
.word 0x2a
.word 0x6
.word 0x12
.word 0x21
.word 0x9
.word 0x8
.word 0x25
.word 0x1d
.word 0x5
.word 0x12
.word 0x8
.word 0x20
.word 0x2a
.word 0x24
.word 0x3
.word 0x3
.word 0x1f
.word 0x1f
.word 0x1c
.word 0x1e
.word 0x11
.word 0x21
.word 0x12
.word 0x14
.word 0x3
.word 0x12
.word 0x28
.word 0x14
.word 0x1e
.word 0x17
.word 0x8
.word 0x27
.word 0xe
.word 0x20
.word 0x4
.word 0x15
.word 0x1b
.word 0x1d
.word 0x12
.word 0x1
.word 0x0
.word 0x12
.word 0x2a
.word 0x1e
.word 0x7
.word 0x2
.word 0x20
.word 0x6
.word 0x1c
.word 0x9
.word 0x29
.word 0xe
.word 0xe
.word 0x16
.word 0x7
.word 0x17
.word 0x6
.word 0x26
.word 0xf
.word 0x24
.word 0x1
.word 0xf
.word 0x2a
.word 0x15
.word 0xa
.word 0x29
.word 0x28
.word 0x6
.word 0x3
.word 0x2a
.word 0x1
.word 0x28
.word 0x15
.word 0x11
.word 0x1b
.word 0x4
.word 0x13
.word 0x9
.word 0x16
.word 0xa
.word 0x3
.word 0x20
.word 0x1b
.word 0x9
.word 0x1f
.word 0x27
.word 0x5
.word 0x17
.word 0x14
.word 0x28
.word 0x22
.word 0x1e
.word 0xb
.word 0x1e
.word 0x18
.word 0xe
.word 0x4
.word 0x2b
.word 0x8
.word 0x24
.word 0xd
.word 0x6
.word 0x2b
.word 0x23
.word 0xa
.word 0x13
.word 0x1e
.word 0x5
.word 0x19
.word 0x19
.word 0x8
.word 0x0
.word 0x18
.word 0x21
.word 0xa
.word 0x1a
.word 0x11
.word 0x1d
.word 0x18
.word 0xa
.word 0xb
.word 0x9
.word 0x0
.word 0xa
.word 0x16
.word 0xd
.word 0xd
.word 0x28
.word 0x1d
.word 0x16
.word 0x18
.word 0x10
.word 0x14
.word 0x1c
.word 0x2
.word 0x1
.word 0x20
.word 0x8
.word 0x12
.word 0xc
.word 0x11
.word 0x10
.word 0x13
.word 0x2
.word 0x1a
.word 0xa
.word 0xd
.word 0x22
.word 0xb
.word 0x17
.word 0x25
.word 0x20
.word 0x2
.word 0x12
.word 0x4
.word 0x19
.word 0x9
.word 0x3
.word 0x18
.word 0x0
.word 0x8
.word 0x7
.word 0x7
.word 0x28
.word 0x21
.word 0x1a
.word 0x9
.word 0x3
.word 0x21
.word 0x1c
.word 0x16
.word 0x11
.word 0x1c
.word 0x18
.word 0xf
.word 0x5
.word 0x2b
.word 0x27
.word 0x19
.word 0x13
.word 0xf
.word 0x28
.word 0x4
.word 0x14
.word 0x1c
.word 0x13
.word 0x28
.word 0xb
.word 0x14
.word 0xf
.word 0x1a
.word 0x13
.word 0x4
.word 0x26
.word 0x10
.word 0x15
.word 0x11
.word 0x27
.word 0x10
.word 0x13
.word 0x19
.word 0x22
.word 0x10
.word 0xe
.word 0x15
.word 0x13
.word 0x14
.word 0x13
.word 0x3
.word 0x8
.word 0x25
.word 0xb
.word 0x1e
.word 0x12
.word 0xf
.word 0xb
.word 0x6
.word 0x1f
.word 0x20
.word 0x17
.word 0x27
.word 0x25
.word 0x24
.word 0xa
.word 0x20
.word 0x24
.word 0x23
.word 0x10
.word 0x9
.word 0x19
.word 0x5
.word 0x11
.word 0x26
.word 0x6
.word 0xa
.word 0x20
.word 0x5
.word 0x1f
.word 0x26
.word 0xe
.word 0x17
.word 0x20
.word 0x7
.word 0xc
.word 0x2
.word 0xf
.word 0x5
.word 0xe
.word 0x8
.word 0xf
.word 0x19
.word 0x19
.word 0x9
.word 0x1f
.word 0x20
.word 0x3
.word 0xe
.word 0x2
.word 0x20
.word 0x22
.word 0x26
.word 0x12
.word 0x15
.word 0x29
.word 0x1d
.word 0xd
.word 0x25
.word 0xe
.word 0x6
.word 0x0
.word 0x19
.word 0xb
.word 0x22
.word 0x4
.word 0x1a
.word 0x1b
.word 0x19
.word 0x29
.word 0x23
.word 0x6
.word 0x15
.word 0x13
.word 0x22
.word 0x2b
.word 0x22
.word 0x1e
.word 0xa
.word 0xb
.word 0x29
.word 0x1b
.word 0x6
.word 0x11
.word 0xc
.word 0x13
.word 0x11
.word 0x9
.word 0x21
.word 0x14
.word 0x25
.word 0xf
.word 0x28
.word 0x18
.word 0x28
.word 0x11
.word 0x24
.word 0x14
.word 0xf
.word 0x22
.word 0x14
.word 0x28
.word 0x1f
.word 0x16
.word 0x2a
.word 0xe
.word 0xc
.word 0x1d
.word 0xc
.word 0x9
.word 0xe
.word 0x24
.word 0x24
.word 0xe
.word 0x20
.word 0xd
.word 0x2b
.word 0x24
.word 0xc
.word 0x0
.word 0x21
.word 0x17
.word 0xe
.word 0x1b
.word 0x28
.word 0x1e
.word 0x24
.word 0x22
.word 0x1f
.word 0x20
.word 0x24
.word 0xf
.word 0x16
.word 0x2b
.word 0x2a
.word 0x13
.word 0x25
.word 0x27
.word 0x23
.word 0x2
.word 0x1c
.word 0x20
.word 0x12
.word 0x10
.word 0xa
.word 0xd
.word 0x1f
.word 0x22
.word 0x5
.word 0x16
.word 0xb
.word 0x2b
.word 0x28
.word 0x6
.word 0xc
.word 0x12
.word 0x29
.word 0x18
.word 0x20
.word 0x11
.word 0x1f
.word 0xf
.word 0xc
.word 0x2a
.word 0x2b
.word 0x1f
.word 0x5
.word 0x25
.word 0x1f
.word 0x0
.word 0x0
.word 0x4
.word 0x7
.word 0x9
.word 0x20
.word 0x18
.word 0x17
.word 0xc
.word 0x1b
.word 0x11
.word 0x2b
.word 0x1e
.word 0x28
.word 0x2
.word 0x4
.word 0x6
.word 0x8
.word 0xa
.word 0x23
.word 0x20
.word 0xf
.word 0xf
.word 0x1f
.word 0xf
.word 0x2a
.word 0x12
.word 0x1e
.word 0x1c
.word 0x18
.word 0x28
.word 0x14
.word 0x21
.word 0x22
.word 0xa
.word 0xc
.word 0x1f
.word 0xc
.word 0x5
.word 0x2
.word 0x8
.word 0x2a
.word 0x29
.word 0x9
.word 0x1b
.word 0x19
.word 0xc
.word 0x2
.word 0x3
.word 0x1b
.word 0x2
.word 0x17
.word 0x3
.word 0x1
.word 0x25
.word 0x1a
.word 0x20
.word 0x1d
.word 0x2b
.word 0x28
.word 0x11
.word 0xc
.word 0x1f
.word 0x2a
.word 0x2b
.word 0x1b
.word 0x11
.word 0x20
.word 0x2
.word 0xa
.word 0x18
.word 0x6
.word 0x8
.word 0x28
.word 0x10
.word 0x2b
.word 0x26
.word 0x24
.word 0x2b
.word 0x18
.word 0x8
.word 0x1d
.word 0x19
.word 0x0
.word 0x18
.word 0x15
.word 0x0
.word 0x12
.word 0x3
.word 0x10
.word 0x24
.word 0xd
.word 0x28
.word 0x18
.word 0x7
.word 0x27
.word 0x24
.word 0x16
.word 0x19
.word 0xc
.word 0x9
.word 0x8
.word 0x1c
.word 0x4
.word 0x9
.word 0x19
.word 0x21
.word 0x23
.word 0x27
.word 0x8
.word 0x11
.word 0x1d
.word 0x2a
.word 0x14
.word 0x14
.word 0x0
.word 0x0
.word 0x10
.word 0x21
.word 0x27
.word 0xd
.word 0xe
.word 0x1b
.word 0x21
.word 0x1
.word 0x5
.word 0x0
.word 0x19
.word 0x17
.word 0x17
.word 0x2b
.word 0xa
.word 0x29
.word 0xa
.word 0x17
.word 0x1
.word 0xe
.word 0x1c
.word 0x29
.word 0xe
.word 0x18
.word 0x9
.word 0x7
.word 0x6
.word 0x15
.word 0x16
.word 0x1e
.word 0x23
.word 0x21
.word 0xd
.word 0x25
.word 0xa
.word 0xa
.word 0x7
.word 0x22
.word 0x15
.word 0x18
.word 0xc
.word 0x1a
.word 0x21
.word 0xe
.word 0x4
.word 0x1
.word 0x6
.word 0x1b
.word 0xc
.word 0x6
.word 0x1b
.word 0x0
.word 0xa
.word 0x2a
.word 0x7
.word 0x11
.word 0x0
.word 0xe
.word 0x26
.word 0x17
.word 0x8
.word 0x2b
.word 0x17
.word 0x2
.word 0x6
.word 0x11
.word 0x21
.word 0x2b
.word 0x11
.word 0x1c
.word 0x12
.word 0x20
.word 0xd
.word 0x17
.word 0x5
.word 0x21
.word 0x23
.word 0x1d
.word 0x0
.word 0x1e
.word 0x8
.word 0x20
.word 0x1a
.word 0x22
.word 0x1f
.word 0x1f
.word 0x2a
.word 0x1e
.word 0x7
.word 0x7
.word 0xf
.word 0x6
.word 0x8
.word 0x0
.word 0x22
.word 0x13
.word 0x16
.word 0x10
.word 0x0
.word 0x6
.word 0x1f
.word 0x28
.word 0x0
.word 0x7
.word 0x10
.word 0x29
.word 0x10
.word 0x16
.word 0x4
.word 0x1
.word 0x8
.word 0x2
.word 0x1b
.word 0xd
.word 0x2b
.word 0x24
.word 0x1f
.word 0x18
.word 0xd
.word 0x3
.word 0x1f
.word 0xb
.word 0x27
.word 0x10
.word 0x24
.word 0x15
.word 0x6
.word 0x2a
.word 0xc
.word 0x19
.word 0x15
.word 0x29
.word 0x28
.word 0x14
.word 0x27
.word 0xa
.word 0x19
.word 0x19
.word 0xa
.word 0xb
.word 0x10
.word 0xc
.word 0x27
.word 0xc
.word 0x28
.word 0x4
.word 0x2b
.word 0x11
.word 0x10
.word 0x25
.word 0x10
.word 0x4
.word 0x19
.word 0x3
.word 0x5
.word 0x10
.word 0xf
.word 0x1
.word 0x24
.word 0x2a
.word 0x26
.word 0x9
.word 0x15
.word 0x14
.word 0x21
.word 0x23
.word 0x3
.word 0xb
.word 0x20
.word 0x16
.word 0x20
.word 0x14
.word 0x3
.word 0x1d
.word 0xb
.word 0x1d
.word 0x11
.word 0x16
.word 0x1b
.word 0x25
.word 0x2
.word 0x6
.word 0x6
.word 0x22
.word 0x28
.word 0x7
.word 0x17
.word 0x27
.word 0x20
.word 0x10
.word 0x29
.word 0xe
.word 0x26
.word 0x25
.word 0x5
.word 0x9
.word 0x1e
.word 0x2b
.word 0x1f
.word 0xe
.word 0x23
.word 0xd
.word 0x16
.word 0xd
.word 0x27
.word 0x9
.word 0x11
.word 0x22
.word 0xd
.word 0xc
.word 0x1b
.word 0x3
.word 0x23
.word 0x2a
.word 0x21
.word 0xb
.word 0x20
.word 0x1c
.word 0xc
.word 0x9
.word 0xb
.word 0xf
.word 0x1b
.word 0x1b
.word 0x0
.word 0x20
.word 0xb
.word 0x1f
.word 0x22
.word 0x5
.word 0x1
.word 0x25
.word 0x29
.word 0x3
.word 0x1b
.word 0x24
.word 0x3
.word 0x8
.word 0x1a
.word 0x5
.word 0x1
.word 0x1f
.word 0xe
.word 0x23
.word 0x19
.word 0x16
.word 0x4
.word 0x27
.word 0x2
.word 0x1e
.word 0x8
.word 0x24
.word 0x16
.word 0x2a
.word 0xa
.word 0x12
.word 0x17
.word 0xf
.word 0x20
.word 0x0
.word 0x8
.word 0x13
.word 0x4
.word 0x17
.word 0x9
.word 0xe
.word 0x1
.word 0xf
.word 0x1f
.word 0xc
.word 0x1a
.word 0x2b
.word 0x23
.word 0x23
.word 0x1c
.word 0xb
.word 0xa
.word 0x1b
.word 0xe
.word 0x1a
.word 0xc
.word 0x18
.word 0x27
.word 0x19
.word 0x26
.word 0x24
.word 0x0
.word 0x24
.word 0x21
.word 0x17
.word 0x4
.word 0x1e
.word 0x17
.word 0x17
.word 0x14
.word 0x20
.word 0x21
.word 0x16
.word 0xe
.word 0x9
.word 0x3
.word 0x3
.word 0x20
.word 0xd
.word 0x20
.word 0x1a
.word 0x1c
.word 0x2b
.word 0x3
.word 0x13
.word 0x25
.word 0x10
.word 0x1f
.word 0x6
.word 0x19
.word 0x8
.word 0x1e
.word 0x29
.word 0x15
.word 0x9
.word 0x14
.word 0x22
.word 0x7
.word 0xf
.word 0x3
.word 0x0
.word 0xc
.word 0xa
.word 0x26
.word 0xf
.word 0x29
.word 0xe
.word 0x1d
.word 0xd
.word 0x5
.word 0x12
.word 0x18
.word 0x21
.word 0xc
.word 0x25
.word 0x11
.word 0xb
.word 0x12
.word 0x2
.word 0x2b
.word 0x29
.word 0x21
.word 0x15
.word 0x1f
.word 0x29
.word 0x21
.word 0x1e
.word 0x1a
.word 0x22
.word 0x29
.word 0x2b
.word 0xf
.word 0x7
.word 0xc
.word 0x7
.word 0x6
.word 0x3
.word 0x7
.word 0x13
.word 0x25
.word 0x3
.word 0x9
.word 0x15
.word 0x2b
.word 0x17
.word 0x14
.word 0x22
.word 0xf
.word 0xb
.word 0xd
.word 0x1e
.word 0xc
.word 0x8
.word 0xe
.word 0x1
.word 0x14
.word 0x10
.word 0x17
.word 0x6
.word 0x24
.word 0x12
.word 0x28
.word 0x1
.word 0x1e
.word 0x0
.word 0x1a
.word 0x20
.word 0x1f
.word 0x10
.word 0x10

rc0:
  .quad 0x0000000000000001
  .quad 0x0000000000008082
  .quad 0x800000000000808a
  .quad 0x8000000080008000

rc1:
  .quad 0x000000000000808b
  .quad 0x0000000080000001
  .quad 0x8000000080008081
  .quad 0x8000000000008009

rc2:
  .quad 0x000000000000008a
  .quad 0x0000000000000088
  .quad 0x0000000080008009
  .quad 0x000000008000000a

rc3:
  .quad 0x000000008000808b
  .quad 0x800000000000008b
  .quad 0x8000000000008089
  .quad 0x8000000000008003

rc4:
  .quad 0x8000000000008002
  .quad 0x8000000000000080
  .quad 0x000000000000800a
  .quad 0x800000008000000a

rc5:
  .quad 0x8000000080008081
  .quad 0x8000000000008080
  .quad 0x0000000080000001
  .quad 0x8000000080008008
  
bitmask32:
  .word 0xFFFFFFFF

bitmask_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
 
allzero: 
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime:
  .quad 0x00000000007fe001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  
