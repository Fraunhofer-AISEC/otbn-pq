# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:otbn.bzl", "otbn_binary", "otbn_library")

package(default_visibility = ["//visibility:public"])

otbn_binary(
    name = "otbn_dilithium2_verify",
    srcs = [
        "pq_dilithium-2-valid.s",
    ],
)
otbn_binary(
    name = "otbn_dilithium3_verify",
    srcs = [
        "pq_dilithium-3-valid.s",
    ],
)
otbn_binary(
    name = "otbn_dilithium5_verify",
    srcs = [
        "pq_dilithium-5-valid.s",
    ],
)
otbn_binary(
   name = "otbn_pq_add",
   srcs = [
       "pq_add.s",
   ],
)

otbn_binary(
   name = "otbn_dilithium_ntt",
   srcs = [
       "pq_ntt_indirect_dilithium.s",
   ],
)

otbn_binary(
   name = "otbn_dilithium_intt",
   srcs = [
       "pq_ntt_inv_indirect_dilithium.s",
   ],
)

otbn_binary(
   name = "otbn_keccak",
   srcs = [
       "pq_keccak.s",
   ],
)

otbn_binary(
   name = "otbn_shake128",
   srcs = [
       "pq_shake128.s",
   ],
)

otbn_binary(
   name = "otbn_dilithium_expanda",
   srcs = [
       "pq_expand_a.s",
   ],
)

otbn_binary(
   name = "otbn_dilithium_sampleinball",
   srcs = [
       "pq_sampleinball.s",
   ],
)

