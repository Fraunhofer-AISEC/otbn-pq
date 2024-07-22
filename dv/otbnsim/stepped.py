#!/usr/bin/env python3
# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

'''A simulator that runs one instruction at a time, reading from a REPL

The input language is simple (and intended to be generated by another program).
Input should appear with one command per line.

The valid commands are as follows. All arguments are shown here as <argname>.
The integer arguments are read with Python's int() function, so should be
prefixed with "0x" if they are hexadecimal.

    start_operation         Start an execution or DMEM/IMEM secure wipe

    step                    Run one instruction. Print trace information to
                            stdout.

    load_elf <path>         Load the ELF file at <path>, replacing current
                            contents of DMEM and IMEM.

    add_loop_warp <addr> <from> <to>

                            Add a loop warp to the simulation. This will
                            trigger at address <addr> and will jump from
                            iteration <from> to iteration <to>.

    clear_loop_warps        Clear any loop warp rules

    load_d <path>           Replace the current contents of DMEM with <path>
                            (read as an array of 32-bit little-endian words)

    load_i <path>           Replace the current contents of IMEM with <path>
                            (read as an array of 32-bit little-endian words)

    dump_d <path>           Write the current contents of DMEM to <path> (same
                            format as for load).

    print_regs              Write the hex contents of all registers to stdout

    edn_rnd_step            Send 32b RND Data to the model.

    edn_rnd_cdc_done        Finish the RND data write process by signalling RTL
                            is also finished processing 32b packages from EDN.

    edn_urnd_step           Send 32b URND seed data to the model.

    edn_urnd_cdc_done       Finish the URND resseding process by signalling RTL
                            is also finished processing 32b packages from EDN
                            and set the seed.

    edn_flush               Flush EDN data from model because of reset signal
                            in EDN clock domain

    otp_key_cdc_done        Lowers the request flag for any external secure
                            wipe operation. Gets called when we acknowledge
                            incoming scrambling key in RTL.

    invalidate_imem         Mark all of IMEM as having invalid ECC checksums

    invalidate_dmem         Mark all of DMEM as having invalid ECC checksums

    set_keymgr_value        Send keymgr data to the model.

    step_crc                Step CRC function with 48 bits of data. No actual
                            change of state (this is pure, but handled in
                            Python to simplify verification).

    send_err_escalation     React to an injected error.

    set_software_errs_fatal Set software_errs_fatal bit.
'''

import binascii
import sys
from typing import List, Optional

from sim.decode import decode_file
from sim.load_elf import load_elf
from sim.sim import OTBNSim


def read_word(arg_name: str, word_data: str, bits: int) -> int:
    '''Try to read an unsigned word of the specified bit length'''
    try:
        value = int(word_data, 0)
    except ValueError:
        raise ValueError('Failed to read {!r} as an integer for <{}> argument.'
                         .format(word_data, arg_name)) from None

    if value < 0 or value >> bits:
        raise ValueError('<{}> argument is {!r}: '
                         'not representable in {!r} bits.'
                         .format(arg_name, word_data, bits))

    return value


def end_command() -> None:
    '''Print a single '.' to stdout and flush, ending the output for command'''
    print('.')
    sys.stdout.flush()


def check_arg_count(cmd: str, cnt: int, args: List[str]) -> None:
    if len(args) != cnt:
        if cnt == 0:
            txt_cnt = 'no arguments'
        elif cnt == 1:
            txt_cnt = 'exactly one argument'
        else:
            txt_cnt = f'exactly {cnt} arguments'

        raise ValueError(f'{cmd} expects {txt_cnt} arguments. Got {args}.')


def on_start_operation(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('start_operation', 1, args)
    command = args[0]

    if command == 'Execute':
        print('START')
        sim.start(collect_stats=False)
    elif command == 'DmemWipe':
        sim.start_mem_wipe(False)
    elif command == 'ImemWipe':
        sim.start_mem_wipe(True)
    else:
        raise ValueError(f'Invalid command for start_operation: {command}.')

    return None


def on_step(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Step one instruction'''
    check_arg_count('step', 0, args)

    pc = sim.state.pc
    assert 0 == pc & 3

    was_wiping = sim.state.wiping()

    insn, changes = sim.step(verbose=False)

    if insn is not None:
        hdr = insn.rtl_trace(pc)  # type: Optional[str]
    elif was_wiping:
        # The trailing space is a bit naff but matches the behaviour in the RTL
        # tracer, where it's rather difficult to change.
        hdr = 'U ' if sim.state.wiping() else 'V '
    elif sim.state.executing():
        hdr = 'STALL'
    else:
        hdr = None

    # When locking immediately, drop headers that get cancelled by RTL.
    if sim.state.lock_immediately and hdr in ['V ', 'STALL']:
        hdr = None

    rtl_changes = []
    for c in changes:
        rt = c.rtl_trace()
        if rt is not None:
            rtl_changes.append(rt)

    # This is a bit of a hack. Very occasionally, we'll see traced changes when
    # there's not actually an instruction in flight. For example, this happens
    # if there's a RND request still pending when an operation stops. In this
    # case, we might see a change where we drop the REQ signal after the secure
    # wipe has finished. Rather than define a special "do-nothing" trace entry
    # format for this situation, we cheat and use STALL.
    if hdr is None and rtl_changes:
        hdr = 'STALL'

    if hdr is not None:
        print(hdr)
        for rt in rtl_changes:
            print(rt)

    return None


def on_load_elf(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Load contents of ELF at path given by only argument'''
    check_arg_count('load_elf', 1, args)

    path = args[0]

    print('LOAD_ELF {!r}'.format(path))
    load_elf(sim, path)

    return None


def on_add_loop_warp(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Add a loop warp to the simulation'''
    check_arg_count('add_loop_warp', 3, args)

    try:
        addr = int(args[0], 0)
        if addr < 0:
            raise ValueError('addr is negative')
        from_cnt = int(args[1], 0)
        if from_cnt < 0:
            raise ValueError('from_cnt is negative')
        to_cnt = int(args[2], 0)
        if to_cnt < 0:
            raise ValueError('to_cnt is negative')
    except ValueError as err:
        raise ValueError('Bad argument to add_loop_warp: {}'
                         .format(err)) from None

    print('ADD_LOOP_WARP {:#x} {} {}'.format(addr, from_cnt, to_cnt))
    sim.add_loop_warp(addr, from_cnt, to_cnt)

    return None


def on_clear_loop_warps(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Run until ecall or error'''
    check_arg_count('clear_loop_warps', 0, args)

    sim.loop_warps = {}

    return None


def on_load_d(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Load contents of data memory from file at path given by only argument'''
    check_arg_count('load_d', 1, args)

    path = args[0]

    print('LOAD_D {!r}'.format(path))
    with open(path, 'rb') as handle:
        sim.load_data(handle.read(), has_validity=True)

    return None


def on_load_i(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Load contents of insn memory from file at path given by only argument'''
    check_arg_count('load_i', 1, args)

    path = args[0]

    print('LOAD_I {!r}'.format(path))
    sim.load_program(decode_file(0, path))

    return None


def on_dump_d(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Dump contents of data memory to file at path given by only argument'''
    check_arg_count('dump_d', 1, args)

    path = args[0]

    print('DUMP_D {!r}'.format(path))

    with open(path, 'wb') as handle:
        handle.write(sim.state.dmem.dump_le_words())

    return None


def on_print_regs(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Print registers to stdout'''
    check_arg_count('print_regs', 0, args)

    print('PRINT_REGS')
    for idx, value in enumerate(sim.state.gprs.peek_unsigned_values()):
        print(' x{:<2} = 0x{:08x}'.format(idx, value))
    for idx, value in enumerate(sim.state.wdrs.peek_unsigned_values()):
        print(' w{:<2} = 0x{:064x}'.format(idx, value))

    return None


def on_print_call_stack(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    '''Print call stack to stdout. First element is the bottom of the stack'''
    check_arg_count('print_call_stack', 0, args)

    print('PRINT_CALL_STACK')
    for value in sim.state.peek_call_stack():
        print('0x{:08x}'.format(value))

    return None


def on_reset(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('reset', 0, args)
    return OTBNSim()


def on_edn_rnd_step(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('edn_rnd_step', 2, args)
    edn_rnd_data = read_word('edn_rnd_step', args[0], 32)
    fips_err = read_word('fips_err', args[1], 1)
    sim.state.edn_rnd_step(edn_rnd_data, bool(fips_err))
    return None


def on_edn_urnd_step(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('edn_urnd_step', 1, args)
    edn_urnd_data = read_word('edn_urnd_step', args[0], 32)
    sim.state.edn_urnd_step(edn_urnd_data)
    return None


def on_edn_flush(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('edn_flush', 0, args)
    sim.state.edn_flush()
    return None


def on_edn_urnd_cdc_done(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('urnd_cdc_done', 0, args)
    sim.state.urnd_completed()
    return None


def on_edn_rnd_cdc_done(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('edn_rnd_cdc_done', 0, args)
    sim.state.rnd_completed()
    return None


def on_invalidate_imem(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('invalidate_imem', 0, args)

    sim.state.invalidate_imem()
    return None


def on_invalidate_dmem(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('invalidate_dmem', 0, args)

    sim.state.dmem.empty_dmem()
    return None


def on_set_software_errs_fatal(sim: OTBNSim,
                               args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('set_software_errs_fatal', 1, args)
    new_val = read_word('error', args[0], 1)
    assert new_val in [0, 1]
    sim.state.software_errs_fatal = new_val != 0

    return None


def on_set_keymgr_value(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('set_keymgr_value', 3, args)
    key0 = read_word('key0', args[0], 384)
    key1 = read_word('key1', args[1], 384)
    valid = read_word('valid', args[2], 1) == 1
    sim.state.wsrs.set_sideload_keys(key0 if valid else None,
                                     key1 if valid else None)

    return None


def on_step_crc(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('step_crc', 2, args)

    item = read_word('item', args[0], 48)
    state = read_word('state', args[1], 32)

    new_state = binascii.crc32(item.to_bytes(6, 'little'), state)
    print(f'! otbn.LOAD_CHECKSUM: 0x{new_state:08x}')

    return None


def on_send_err_escalation(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('send_err_escalation', 2, args)
    err_val = read_word('err_val', args[0], 32)
    lock_immediately = bool(read_word('lock_immediately', args[1], 1))
    sim.send_err_escalation(err_val, lock_immediately)
    return None


def on_send_rma_req(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('send_rma_req', 0, args)
    sim.send_rma_req()
    return None


def on_initial_secure_wipe(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('initial_secure_wipe', 0, args)
    sim.initial_secure_wipe()
    return None


def on_otp_cdc_done(sim: OTBNSim, args: List[str]) -> Optional[OTBNSim]:
    check_arg_count('otp_key_cdc_done', 0, args)

    sim.on_otp_cdc_done()
    return None


_HANDLERS = {
    'start_operation': on_start_operation,
    'otp_key_cdc_done': on_otp_cdc_done,
    'step': on_step,
    'load_elf': on_load_elf,
    'add_loop_warp': on_add_loop_warp,
    'clear_loop_warps': on_clear_loop_warps,
    'load_d': on_load_d,
    'load_i': on_load_i,
    'dump_d': on_dump_d,
    'print_regs': on_print_regs,
    'print_call_stack': on_print_call_stack,
    'reset': on_reset,
    'edn_rnd_step': on_edn_rnd_step,
    'edn_urnd_step': on_edn_urnd_step,
    'edn_rnd_cdc_done': on_edn_rnd_cdc_done,
    'edn_urnd_cdc_done': on_edn_urnd_cdc_done,
    'edn_flush': on_edn_flush,
    'invalidate_imem': on_invalidate_imem,
    'invalidate_dmem': on_invalidate_dmem,
    'set_keymgr_value': on_set_keymgr_value,
    'step_crc': on_step_crc,
    'send_err_escalation': on_send_err_escalation,
    'send_rma_req': on_send_rma_req,
    'initial_secure_wipe': on_initial_secure_wipe,
    'set_software_errs_fatal': on_set_software_errs_fatal
}


def on_input(sim: OTBNSim, line: str) -> Optional[OTBNSim]:
    '''Process an input command'''
    words = line.split()

    # Just ignore empty lines
    if not words:
        return None

    verb = words[0]
    handler = _HANDLERS.get(verb)
    if handler is None:
        raise RuntimeError('Unknown command: {!r}'.format(verb))

    ret = handler(sim, words[1:])
    print('.')
    sys.stdout.flush()

    return ret


def main() -> int:
    sim = OTBNSim()
    try:
        for line in sys.stdin:
            ret = on_input(sim, line)
            if ret is not None:
                sim = ret

    except KeyboardInterrupt:
        print("Received shutdown request, ending OTBN simulation.")
        return 0
    return 0


if __name__ == '__main__':
    sys.exit(main())
