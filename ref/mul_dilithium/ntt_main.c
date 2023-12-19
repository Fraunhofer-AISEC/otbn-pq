// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "ntt.h"
#include "params.h"
#include "reduce.h"

void pointwise_mul(int32_t a[N], int32_t b[N],int32_t c[N] ){
  for(int i = 0; i < N; ++i)
    c[i] = montgomery_reduce((int64_t)a[i] * b[i]);
}

int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  

  int32_t a[N];
  int32_t b[N];
  int32_t c[N];

  puts("Dilithium Pointwise Multiplication Performance Test\n");
  // Initialize poly
    for(int i=0; i<N; i++){
        a[i] = i;
	b[i] = i;
    }

  puts("Dilithium Pointwise Multiplication Start\n");

  pcount_enable(1);

  pointwise_mul(a,b,c);

  pcount_enable(0);

  puts("Dilithium Pointwise Multiplication Done\n");
  putchar('\n');

  return 0;
}
