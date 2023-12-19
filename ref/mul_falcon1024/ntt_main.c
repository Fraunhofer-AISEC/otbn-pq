// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "ntt.h"


int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  

  uint16_t a[1024];
  uint16_t b[1024];

  puts("FALCON-1024 Pointwise Multiplication Performance Test\n");
  // Initialize poly
    for(int i=0; i<1024; i++){
        a[i] = i;
        b[i] = i;
    }

  puts("FALCON-1024 Pointwise Multiplication Start\n");

  pcount_enable(1);
  mq_poly_montymul_ntt(a, b, 10);
  pcount_enable(0);

  puts("FALCON-1024 Pointwise Multiplication Done\n");
  putchar('\n');

  return 0;
}
