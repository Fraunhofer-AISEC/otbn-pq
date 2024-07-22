# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@rules_python//python:defs.bzl", "py_binary")
load("@ot_python_deps//:requirements.bzl", "requirement")

package(default_visibility = ["//visibility:public"])

py_binary(
    name = "otbn_as",
    srcs = ["otbn_as.py"],
    deps = [
        "//hw/ip/otbn_pq/util/shared:bit_ranges",
        "//hw/ip/otbn_pq/util/shared:encoding",
        "//hw/ip/otbn_pq/util/shared:insn_yaml",
        "//hw/ip/otbn_pq/util/shared:operand",
        "//hw/ip/otbn_pq/util/shared:toolchain",
    ],
)

py_binary(
    name = "otbn_ld",
    srcs = ["otbn_ld.py"],
    deps = [
        "//hw/ip/otbn_pq/util/shared:mem_layout",
        "//hw/ip/otbn_pq/util/shared:toolchain",
        requirement("mako"),
    ],
)

py_binary(
    name = "otbn_objdump",
    srcs = ["otbn_objdump.py"],
    deps = [
        "//hw/ip/otbn_pq/util/shared:insn_yaml",
        "//hw/ip/otbn_pq/util/shared:toolchain",
    ],
)

py_binary(
    name = "check_const_time",
    srcs = ["check_const_time.py"],
    deps = [
        "//hw/ip/otbn_pq/util/shared:check",
        "//hw/ip/otbn_pq/util/shared:control_flow",
        "//hw/ip/otbn_pq/util/shared:decode",
        "//hw/ip/otbn_pq/util/shared:information_flow_analysis",
        requirement("pyelftools"),
    ],
)

py_binary(
    name = "get_instruction_count_range",
    srcs = ["get_instruction_count_range.py"],
    deps = [
        "//hw/ip/otbn_pq/util/shared:decode",
        "//hw/ip/otbn_pq/util/shared:instruction_count_range",
    ],
)

py_binary(
    name = "otbn_sim_test",
    srcs = ["otbn_sim_test.py"],
    deps = [
        "//hw/ip/otbn_pq/util/shared:check",
        "//hw/ip/otbn_pq/util/shared:reg_dump",
    ],
)
