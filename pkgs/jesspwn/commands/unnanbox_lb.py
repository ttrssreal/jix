import pwndbg
import argparse

BASE_TAG = 0x7FF8
IS_CELL_BIT = 0x8000 | BASE_TAG

UNDEFINED_TAG = 0b110 | BASE_TAG
NULL_TAG = 0b111 | BASE_TAG
BOOLEAN_TAG = 0b001 | BASE_TAG
INT32_TAG = 0b010 | BASE_TAG
EMPTY_TAG = 0b011 | BASE_TAG

OBJECT_TAG = 0b001 | IS_CELL_BIT
STRING_TAG = 0b010 | IS_CELL_BIT
SYMBOL_TAG = 0b011 | IS_CELL_BIT
ACCESSOR_TAG = 0b100 | IS_CELL_BIT
BIGINT_TAG = 0b101 | IS_CELL_BIT

tags = {
    UNDEFINED_TAG: "undefined",
    NULL_TAG: "null",
    BOOLEAN_TAG: "boolean",
    INT32_TAG: "int32",
    EMPTY_TAG: "empty",
    OBJECT_TAG: "object",
    STRING_TAG: "string",
    SYMBOL_TAG: "symbol",
    ACCESSOR_TAG: "accessor",
    BIGINT_TAG: "bigint"
}

parser = argparse.ArgumentParser(description="Ladybird LibJS un-nanbox JS Value")

parser.add_argument("addr", type=int, help="JS Value pointer")

@pwndbg.commands.ArgparsedCommand(parser)
def unnanbox_lb(addr) -> None:
    try:
        value = pwndbg.aglib.memory.read(addr, 8)
    except:
        print(f"Cannot access memory at address {addr:#x}")
        return

    tag = int.from_bytes(value[6:8][::-1])
    kind = tags[tag]
    print(f"type = {kind}")

    if tag == BOOLEAN_TAG:
        print("value = unimplemented")
    elif tag == INT32_TAG:
        int_value = int.from_bytes(value[0:6][::-1])
        print(f"value = {int_value:#x}")
    elif tag == OBJECT_TAG:
        ptr = int.from_bytes(value[0:6][::-1])
        print(f"value = {ptr:#x}")
    elif tag == STRING_TAG:
        print("value = unimplemented")
    elif tag == SYMBOL_TAG:
        print("value = unimplemented")
    elif tag == ACCESSOR_TAG:
        print("value = unimplemented")
    elif tag == BIGINT_TAG:
        print("value = unimplemented")
    else:
        print("value = ???")
