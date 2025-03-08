import pwndbg
import argparse

from pwndbg.color import memory

parser = argparse.ArgumentParser(description="find leaks to some mmap")

parser.add_argument("address", help="address we start searching from")
parser.add_argument("map", type=str, help="mmap we want to leak")

@pwndbg.commands.ArgparsedCommand(parser)
def leak_search(address=None, map=None) -> None:
    address = address.cast(
        pwndbg.aglib.typeinfo.pvoid
    )  # Fixes issues with function ptrs (xinfo malloc)
    addr = int(address)
    addr &= pwndbg.aglib.arch.ptrmask

    map_page = pwndbg.aglib.vmmap.find(addr)

    if map_page is None:
        print(f"\n  Virtual address {addr:#x} is not mapped.")
        return

    print("Searching mmap of", memory.get(addr))
    print("Starting address:", memory.get(map_page.vaddr))
    print("Ending address:", memory.get(map_page.end))

    for leak in range(pwndbg.lib.memory.round_down(addr, 8), map_page.end, 8):
        value = pwndbg.aglib.memory.read(leak, 8)
        addr = int.from_bytes(value, byteorder="little")

        addr &= pwndbg.aglib.arch.ptrmask
        if addr == 0:
            continue

        page = pwndbg.aglib.vmmap.find(addr)
        if page is None:
            continue

        if map in page.objfile:
            print(memory.get(map_page.vaddr), "+", hex(leak - map_page.vaddr), "=", memory.get(leak), end="")
            print(f"  &&  [{memory.get(leak)}] = {memory.get(addr)}")
