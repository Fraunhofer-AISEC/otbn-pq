/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* UseHint Implementation */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load Bitmask into WDR w0*/
li x2, 0
bn.lid x2, 0(x0)

/* Load Bitmask into Prime PQSR*/
pq.pqsrw 0, w0


/* Load hint bits for polynomial in W20 */
li x2, 96
li x3, 20
bn.lid x3, 0(x2)

/* Address of coefficients */
li x4, 128

/* Address of all-zero vector */
li x6, 32

/* Relative address of result coefficient */
li x7, 0

loopi 32, 4
  jal x1, use_hint
  /* Select next pair of coefficients */
  addi x4, x4, 32
  li x3, 10
  bn.sid x3, 2048(x7++)
  

ecall








/*************************************************/
/*                     UseHint                   */
/*
* @param[in]  x6: address of all-zero vector
* @param[in]  x4: address of coefficients
* @param[in]  w20: current hint bits
* @param[out] w10: result of UseHint
*
* clobbered registers: x3: internal register addressing
*                      x14: read out flags
*                      x15: read out flags
*                      w1: store constant 127
*                      w2: store constant 11275
*                      w3: store constant 1<<23
*                      w4: store constant 43
*                      w5: store constant 19464
*                      w6: store constant 4190208
*                      w7: store constant 0x0...0
*                      w8: store constant 0XF...F
*                      w9: store coefficients
*                      w10: sorting of coefficients
*                      w11: intermediate result
*                      w12: intermediate result
*                      w13: intermediate result
*                      w14: intermediate result
*                      w15: intermediate result
*                      w16: intermediate result                       
*
*/
/*************************************************/
use_hint:

/* Initialize WDR 10 with 0x0...0*/
li x3, 10
bn.lid x3++, 0(x6)

/* a1 = decompose(&a0, a) */
jal x1, decompose
/* WDR 15 = a1 , WDR 16 = a0 */

/* if(hint == 0) */

loopi 8, 34

/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.addi w11, w7, 1
bn.and w11, w11, w20
bn.cmp w11, w7, FG0

/* Check Zero Flag */
csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8

bne x3, x14, hint_not_zero
/* return a1 */
bn.rshi w10, w15, w10 >> 32
beq x0, x0, shift_coefficients

/* else */
hint_not_zero:

/* if(a0 > 0)*/

/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */
/* From decompose: WDR 16 = a0 */
bn.and w11, w8, w16


/* Check Allzero Flag */
bn.cmp w7, w11, FG0
csrrw x14, 1984, x0
andi x15, x14, 8
srli x15, x15, 3

/* Check Carry Flag */
bn.rshi w11, w7, w11 >> 31
bn.cmp w7, w11, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

/* Check Flags: Carry = 1 if a0 < 0 ; Allzero = 1 if a0 == 0*/
or x15, x15, x14
li x3, 1
beq x3, x15, a0_leq_zero

/* return (a1 + 1) & 15 */

/* From decompose: WDR 4 = 15 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.addi w11, w11, 1
bn.and w11, w11, w4
bn.rshi w10, w11, w10 >> 32
beq x0, x0, shift_coefficients

/* else */
a0_leq_zero:

/* return (a1 - 1) & 15 */

/* From decompose: WDR 4 = 15 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.subi w11, w11, 1
bn.and w11, w8, w11
bn.and w11, w11, w4
bn.rshi w10, w11, w10 >> 32

shift_coefficients:
bn.rshi w15, w7, w15 >> 32
bn.rshi w16, w7, w16 >> 32
bn.rshi w20, w7, w20 >> 1

ret

/*************************************************/
/*                    Decompose                  */
/*
* @param[in]  x6: address of all-zero vector
* @param[in]  x4: address of coefficients
* @param[out] w15: a1
* @param[out] w16: a0
*
* clobbered registers: x3: internal register addressing
*                      x14: read out flags
*                      w1: store constant 127
*                      w2: store constant 1025
*                      w3: store constant 1<<21
*                      w4: store constant 15
*                      w5: store constant 2*GAMMA2
*                      w6: store constant 4190208
*                      w7: store constant 0x0...0
*                      w8: store constant 0XF...F
*                      w9: store coefficients
*                      w10: sorting of coefficients
*                      w11: intermediate result
*                      w12: intermediate result
*                      w13: intermediate result
*                      w14: intermediate result
*                         
*
*/
/*************************************************/

decompose:

/* Initialize all necessary WDRs with zero */
li x3, 0
loopi 18, 1
  bn.lid x3++, 0(x6) 

/* Load Prime into WDR w0*/
li x3, 0
bn.lid x3, 64(x0)

/* Store 127 in WDR 1 */
bn.addi w1, w1, 127

/* Store 1025 in WDR 2 */
bn.addi w2, w2, 1023
bn.addi w2, w2, 2

/* Store 1<<21 in WDR 3 */
bn.addi w3, w3, 1
bn.rshi w3, w3, w7 >> 235

/* Store 15 in WDR 4 */
bn.addi w4, w4, 15

/* Store 2*GAMMA2 = (prime-1)/32*2 in WDR 5 */
bn.subi w5, w0, 1
bn.rshi w5, w7, w5 >> 6
bn.rshi w5, w5, w7 >> 254

/* Store (Q-1)/2 = 4190208 in WDR 6 (1023 << 12) */
bn.addi w6, w6, 1023
bn.rshi w6, w6, w7 >> 244

/* Allzero in WDR 7 */

/* Store Mask in WDR 8 */
li x3, 8
bn.lid x3, 0(x0) 

/* Load Coefficients in WDR 9 */
li x3, 9
bn.lid x3, 0(x4) 

/* Work in WDR 10 */

/* Sort coefficients differently to store them easier in one WDR */
pq.add w10.7, w9.0, w7.0
pq.add w10.6, w9.1, w7.0
pq.add w10.5, w9.2, w7.0
pq.add w10.4, w9.3, w7.0
pq.add w10.3, w9.4, w7.0
pq.add w10.2, w9.5, w7.0
pq.add w10.1, w9.6, w7.0
pq.add w10.0, w9.7, w7.0


loopi 8, 40
/* a1  = (a + 127) >> 7 */
bn.and w11, w8, w10
bn.addi w11, w11, 127
bn.and w11, w8, w10
bn.rshi w11, w7, w11 >> 7
bn.and w11, w8, w11

/* a1*1025 + (1 << 21) */
bn.mulqacc.wo.z w11, w2.0, w11.0, 0
bn.add w11, w11, w3

/* (a1*1025 + (1 << 21)) >> 22 */
bn.rshi w12, w7, w11 >> 31
bn.addi w13, w13, 1
bn.cmp w12, w13, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

bn.rshi w11, w7, w11 >> 22

bne x14, x0, skip_mask0
bn.or w11, w11, w8 << 8
bn.and w11, w11, w8
skip_mask0:

/* a1 = a1 & 15 */
bn.and w12, w4, w11

/* *a0  = a - a1*2*GAMMA2 */
bn.mulqacc.wo.z w13, w12.0, w5.0, 0
bn.and w13, w8, w13
bn.and w14, w8, w10
bn.sub w13, w14, w13

/* *a0 -= (((Q-1)/2 - *a0) >> 31) & Q */
bn.sub w14, w6, w13
bn.and w14, w8, w14

bn.rshi w14, w7, w14 >> 31

bn.addi w17, w17, 0
bn.cmp w7, w14, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

beq x14, x0, skip_mask2
bn.rshi w11, w8, w7 >> 248
bn.or w14, w8, w14
bn.and w14, w14, w8
skip_mask2:

bn.and w14, w8, w14
bn.and w14, w0, w14
bn.sub w14, w13, w14


/* Store a1 and a0 in WDR15 and WDR16 */
bn.and w12, w8, w12
bn.or w15, w12, w15 << 32
bn.and w14, w8, w14
bn.or w16, w14, w16 << 32

/* Update WDR10 to process next coefficient */
bn.or w10, w7, w10 >> 32

ret

.section .data

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
  
hint_coeffs:
  .quad 0xAAAAAAAAAAAAAAAA
  .quad 0xAAAAAAAAAAAAAAAA
  .quad 0xAAAAAAAAAAAAAAAA
  .quad 0xAAAAAAAAAAAAAAAA
  
coef0:
  .word 0x608ee1
coef1:
  .word 0x1d5f69
coef2:
  .word 0x5ef871
coef3:
  .word 0x698a90
coef4:
  .word 0x374f40
coef5:
  .word 0x663e2
coef6:
  .word 0x2d0737
coef7:
  .word 0x357671
coef8:
  .word 0x68beba
coef9:
  .word 0x7623f1
coef10:
  .word 0x52400
coef11:
  .word 0x383a2f
coef12:
  .word 0x4f0b10
coef13:
  .word 0x40b847
coef14:
  .word 0x6fe878
coef15:
  .word 0x725373
coef16:
  .word 0x183d77
coef17:
  .word 0x4be367
coef18:
  .word 0x27450
coef19:
  .word 0xe0c32
coef20:
  .word 0x64b8f4
coef21:
  .word 0x6baf58
coef22:
  .word 0x768d08
coef23:
  .word 0x2d8f5d
coef24:
  .word 0x5c816
coef25:
  .word 0x2a6a98
coef26:
  .word 0x5e27f1
coef27:
  .word 0x16360
coef28:
  .word 0x78a351
coef29:
  .word 0x595930
coef30:
  .word 0x1404c1
coef31:
  .word 0x3c06e6
coef32:
  .word 0x162d94
coef33:
  .word 0x472c4d
coef34:
  .word 0x45984a
coef35:
  .word 0x1eb32e
coef36:
  .word 0x381c50
coef37:
  .word 0x6a2959
coef38:
  .word 0x3df253
coef39:
  .word 0x29e27f
coef40:
  .word 0x7f91bf
coef41:
  .word 0xadead
coef42:
  .word 0x75ca09
coef43:
  .word 0x3c8be5
coef44:
  .word 0x39f31a
coef45:
  .word 0xd5729
coef46:
  .word 0x4ed8d8
coef47:
  .word 0x2deb50
coef48:
  .word 0x73208d
coef49:
  .word 0xc16c0
coef50:
  .word 0x39588e
coef51:
  .word 0x5dd3b6
coef52:
  .word 0x34b06e
coef53:
  .word 0x57d8ba
coef54:
  .word 0x7bde14
coef55:
  .word 0x57ab47
coef56:
  .word 0x3bdae7
coef57:
  .word 0x7c65de
coef58:
  .word 0x15ea91
coef59:
  .word 0x45fa41
coef60:
  .word 0x518028
coef61:
  .word 0x6bd6cd
coef62:
  .word 0x458c26
coef63:
  .word 0x7767d2
coef64:
  .word 0x44ff18
coef65:
  .word 0x7ce907
coef66:
  .word 0xa709d
coef67:
  .word 0x6c66cf
coef68:
  .word 0x18006a
coef69:
  .word 0x4e4621
coef70:
  .word 0x5f2f1a
coef71:
  .word 0x1d5f4c
coef72:
  .word 0x5fb705
coef73:
  .word 0x60974d
coef74:
  .word 0x5f71c
coef75:
  .word 0x3a166c
coef76:
  .word 0x6b0327
coef77:
  .word 0x127663
coef78:
  .word 0x74d6b1
coef79:
  .word 0x7667e
coef80:
  .word 0x50def3
coef81:
  .word 0x3f136e
coef82:
  .word 0x7cbcf
coef83:
  .word 0x4d5b0c
coef84:
  .word 0x7f3aaa
coef85:
  .word 0x771747
coef86:
  .word 0x36b304
coef87:
  .word 0x14b38c
coef88:
  .word 0x21090c
coef89:
  .word 0x2f1d54
coef90:
  .word 0x50c65a
coef91:
  .word 0x684111
coef92:
  .word 0x1d5411
coef93:
  .word 0x1b4a05
coef94:
  .word 0x696b10
coef95:
  .word 0x177580
coef96:
  .word 0x34b5f2
coef97:
  .word 0x8adfe
coef98:
  .word 0x6109cd
coef99:
  .word 0x6522e8
coef100:
  .word 0x5f751e
coef101:
  .word 0x6a8f75
coef102:
  .word 0x466cb0
coef103:
  .word 0x4c75e
coef104:
  .word 0x2b5ea2
coef105:
  .word 0x7c8370
coef106:
  .word 0x5df04b
coef107:
  .word 0x3b269
coef108:
  .word 0x673226
coef109:
  .word 0x417b4c
coef110:
  .word 0x3f90c3
coef111:
  .word 0x2bca2b
coef112:
  .word 0x3fe661
coef113:
  .word 0x6c9a32
coef114:
  .word 0x53a73d
coef115:
  .word 0x1232f8
coef116:
  .word 0x50109e
coef117:
  .word 0x4cf8ae
coef118:
  .word 0x5016f
coef119:
  .word 0x5969b5
coef120:
  .word 0x22c349
coef121:
  .word 0x514adf
coef122:
  .word 0x35b3cd
coef123:
  .word 0x7a9232
coef124:
  .word 0x2ed8d6
coef125:
  .word 0xb5389
coef126:
  .word 0x3da7aa
coef127:
  .word 0x4a9435
coef128:
  .word 0x59c8f8
coef129:
  .word 0x1734b1
coef130:
  .word 0x41a99d
coef131:
  .word 0x67eaf1
coef132:
  .word 0x83b5b
coef133:
  .word 0x4c9f1
coef134:
  .word 0xb5d42
coef135:
  .word 0x502340
coef136:
  .word 0x226810
coef137:
  .word 0x4176e2
coef138:
  .word 0x20fdb8
coef139:
  .word 0x6b53c6
coef140:
  .word 0x16ae1
coef141:
  .word 0x3b32d
coef142:
  .word 0x50ce25
coef143:
  .word 0x62e813
coef144:
  .word 0x47a272
coef145:
  .word 0x76f118
coef146:
  .word 0x706e0f
coef147:
  .word 0x39009e
coef148:
  .word 0x1963c
coef149:
  .word 0x546333
coef150:
  .word 0x2f0ad9
coef151:
  .word 0x4077a8
coef152:
  .word 0x3b6bcb
coef153:
  .word 0x52df0e
coef154:
  .word 0x2376cf
coef155:
  .word 0x4ebf57
coef156:
  .word 0x199a71
coef157:
  .word 0x450e59
coef158:
  .word 0x6f7fe4
coef159:
  .word 0x43000
coef160:
  .word 0x280c4b
coef161:
  .word 0x2e9cc6
coef162:
  .word 0x64f11d
coef163:
  .word 0x27b111
coef164:
  .word 0x6d60e2
coef165:
  .word 0x39e55a
coef166:
  .word 0x2824d5
coef167:
  .word 0x5823f7
coef168:
  .word 0x202a50
coef169:
  .word 0x37e0a0
coef170:
  .word 0x6721a6
coef171:
  .word 0x4c2e59
coef172:
  .word 0x4db4af
coef173:
  .word 0x6d2a3b
coef174:
  .word 0x741f1f
coef175:
  .word 0x34e071
coef176:
  .word 0x4d4a28
coef177:
  .word 0x48d527
coef178:
  .word 0x460939
coef179:
  .word 0x6478cc
coef180:
  .word 0x43d089
coef181:
  .word 0x42599
coef182:
  .word 0x39e02e
coef183:
  .word 0x40bf32
coef184:
  .word 0x6f5643
coef185:
  .word 0x12bf15
coef186:
  .word 0x42a22d
coef187:
  .word 0x19e256
coef188:
  .word 0x1f56c2
coef189:
  .word 0x28855
coef190:
  .word 0x6dd248
coef191:
  .word 0x7bd8d0
coef192:
  .word 0x2c22b9
coef193:
  .word 0x316afd
coef194:
  .word 0xbf7d5
coef195:
  .word 0x49adcc
coef196:
  .word 0x7ecab3
coef197:
  .word 0x354ce8
coef198:
  .word 0x1dd7bd
coef199:
  .word 0x1a711
coef200:
  .word 0xb6b85
coef201:
  .word 0x5a042a
coef202:
  .word 0x4c6716
coef203:
  .word 0x294cf3
coef204:
  .word 0x17f0f4
coef205:
  .word 0x38ef72
coef206:
  .word 0x59d69b
coef207:
  .word 0x4a8813
coef208:
  .word 0x5e1ff3
coef209:
  .word 0x521b69
coef210:
  .word 0x11b739
coef211:
  .word 0x1dcacb
coef212:
  .word 0x6816c2
coef213:
  .word 0x7bb2e5
coef214:
  .word 0x5e372b
coef215:
  .word 0x1b5eb9
coef216:
  .word 0x47be74
coef217:
  .word 0x677462
coef218:
  .word 0x5f14f9
coef219:
  .word 0x17f25c
coef220:
  .word 0x1b22bb
coef221:
  .word 0x18dd37
coef222:
  .word 0x6c5026
coef223:
  .word 0x6d98df
coef224:
  .word 0x65d45
coef225:
  .word 0x2453ce
coef226:
  .word 0x5c728
coef227:
  .word 0x435fec
coef228:
  .word 0x454510
coef229:
  .word 0x70cb55
coef230:
  .word 0x672d46
coef231:
  .word 0x982b1
coef232:
  .word 0x591df5
coef233:
  .word 0x2d549a
coef234:
  .word 0xd24b5
coef235:
  .word 0x7b7d3a
coef236:
  .word 0x48047e
coef237:
  .word 0x451a9c
coef238:
  .word 0x10879a
coef239:
  .word 0x2e9a09
coef240:
  .word 0x19dd40
coef241:
  .word 0x5a0535
coef242:
  .word 0x7895fa
coef243:
  .word 0x3c722d
coef244:
  .word 0x4d6169
coef245:
  .word 0x7f4fc
coef246:
  .word 0x75ff65
coef247:
  .word 0x63fbef
coef248:
  .word 0x29ed00
coef249:
  .word 0x5d7c75
coef250:
  .word 0x65bd99
coef251:
  .word 0x48d02d
coef252:
  .word 0x1c011b
coef253:
  .word 0x53eadb
coef254:
  .word 0x2f54aa
coef255:
  .word 0x4a122b


