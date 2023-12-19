// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "ntt.h"


int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  

  uint16_t a[512];
  uint16_t b[512];

  puts("FALCON-512 Pointwise Multiplication Performance Test\n");
  // Initialize poly
    for(int i=0; i<512; i++){
        a[i] = i;
        b[i] = i;
    }

  puts("FALCON-512 Pointwise Multiplication Start\n");

  pcount_enable(1);
  mq_poly_montymul_ntt(a, b, 9);
  pcount_enable(0);

  puts("FALCON-512 Pointwise Multiplication Done\n");
  putchar('\n');

  return 0;
}
