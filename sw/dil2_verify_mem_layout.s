/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Memory layout example for Dilithium 2 */

.section .text

ecall

.section .data
/*
Initial draft, expects A to be streamed linewise, pk, sig, and mu=CRH(CRH(pk), m) need to be provided externally.
*/

/* Constants */
.globl gamma1
gamma1:
  .word 0x00020000

.globl beta
beta:
  .word 0x0000004E

/* Align the following pointers into the next data word (256bit) */
.balign 32

/* Pointer to rho, beginning of pk */
dptr_rho:
  .word pk

/* Pointer to t1, equals pk + 32 */
dptr_t1_pk:
  .word pk + 32

/* Pointer to c, equals beginning of sig */
dptr_c_sig:
  .word sig

/* Pointer to z, equals sig + 32 */
dptr_z_sig:
  .word sig + 32

/* Pointer to h */
dptr_h_sig:
  .word sig + 2336

/* Pointer to mu and kecc_mu_w1*/
dptr_mu:
  .word kecc_mu_w1

/* Pointer to z */
dptr_z:
  .word z

/* Pointer to c */
dptr_c:
  .word c

/* Pointer to w_i */
dptr_w_i:
  .word w_i

/* Pointer to t1_i */
dptr_t1_i:
  .word t1_i

/* Pointer to h */
dptr_h:
  .word h

/* Input from ibex: pk, completely necessary, unpacking can be done on the fly */
.balign 32
.globl pk
pk:
.zero 1312

/* Input from ibex: sig, completely necessary, unpacking can be done on the fly */
.balign 32
.globl sig
sig:
.zero 2420

/* Input from ibex/HMAC core, later locally generated: mu, after hashing pk, and hashing msg though mu has only 64 bytes, Keccak state for mu||w1, needs to be kept around to allow streaming A */
.balign 32
.globl kecc_mu_w1
kecc_mu_w1:
.zero 208

/* Space to store extracted z; We expand this space here to be able to store all polynoms z from the signature */
.balign 32
.globl z
z:
.zero 4096

/* Locally generated: c, output of sample in ball from c_dash (part of key) */
.balign 32
.globl c
c:
.zero 68

/* Locally generated: w_i, output of A*z (for one line of A) - T
Can possibly be reduced to 24 per coeff and 768 byte in total */
.balign 32
.globl w_i
w_i:
.zero 1024

/* Locally generated: t1_i, expanded from Key and transformed to NTT domain */
.balign 32
.globl t1_i
t1_i:
.zero 1024

/* Locally generated: h, expanded from signature */
.balign 32
.globl h
h:
.zero 208
