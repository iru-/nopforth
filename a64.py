#!/usr/bin/env python

import lldb
import shlex
from sys import byteorder
from lldbinit import *

CELL = 8

def reg_value(reg):
    return int(get_register(reg), 16)

def mem_bytes(addr, len):
    error = lldb.SBError()
    return get_target().GetProcess().ReadMemory(addr, len, error)

def mem_value(addr, len):
    return int.from_bytes(mem_bytes(addr, len), byteorder=byteorder)

def get_symbol(name):
    symbols = get_target().FindSymbols(name)
    if symbols.GetSize() == 0:
        return None

    for context in symbols:
        if context.GetModule().GetFileSpec().GetFilename() == "nop":
            return context.GetSymbol()
    return None

def symbol_address(name):
    symbol = get_symbol(name)
    if symbol is None:
        return None
    return symbol.GetStartAddress().GetLoadAddress(get_target())

def dstk():
    print("top %s" % get_register("x0"))
    p = reg_value("fp")
    ep = symbol_address("dstack0")
    i = 1
    while p < ep:
        print("%3d 0x%016x" % (i, mem_value(p, CELL)))
        p += CELL
        i += 1

R0 = 0
def grabR0():
    global R0
    R0 = reg_value("sp")

def rstk():
    if R0 == 0:
        grabR0()

    p = reg_value("sp")
    while p < R0:
        print("0x%016x" % mem_value(p, CELL))
        p += CELL

def state(debugger, command, exe_ctx, result, internal_dict):
    dstk()
    print()
    rstk()

def go(debugger, command, exe_ctx, result, internal_dict):
    debugger.HandleCommand("step")
    state(debugger, command, exe_ctx, result, internal_dict)
   
def dodh(addr):
    link = mem_value(addr, CELL)
    cfa = mem_value(addr + CELL, CELL)
    namelen = mem_value(addr + 2 * CELL, 1)

    try:
        name = mem_bytes(addr + 2 * CELL + 1, namelen).decode("utf-8")
    except:
        name = ""

    print("0x%016x" % addr)
    print("link  0x%016x" % link)
    print("cfa   0x%016x" % cfa)
    print("#name   %16d"  % namelen)
    print("name    %16s"  % name)

    return link

def dh(debugger, command, exe_ctx, result, internal_dict):
    args = shlex.split(command)
    if len(args) < 1:
        print("usage: dh addr")
        return

    addr = 0
    try:
        addr = int(args[0], 16)
    except:
        print("invalid address %s" % args[0])
        return

    dodh(addr)

def dodict(addr):
    if addr == 0:
        return

    dodict(mem_value(addr, CELL))
    dodh(addr)
    print()

def ddict(debugger, command, exe_ctx, result, internal_dict):
    args = shlex.split(command)
    if len(args) < 1:
        print("usage: ddict [addr|forth|macro]")
        return

    if args[0] == "macro":
        addr = mem_value(symbol_address("mlatestp"), CELL)
    elif args[0] == "forth":
        addr = mem_value(symbol_address("flatestp"), CELL)
    else:
        try:
            addr = int(args[0], 16)
        except:
            print("invalid address", args[0])
            return

    dodict(addr)

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand("command script add state -f a64.state")
    debugger.HandleCommand("command script add go -f a64.go")
    debugger.HandleCommand("command script add dh -f a64.dh")
    debugger.HandleCommand("command script add ddict -f a64.ddict")
