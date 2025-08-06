from pwn import *
from icecream import ic

{bindings}

context.binary = {bin_name}
context.log_level = "debug"
context.terminal = ["tmux", "splitw", "-h"]

gdbscript = """
break main
continue
"""

class Challenge:
    def __init__(self, conn_string = "abcdefg.nz 1337"):
        if args.LOCAL:
            self.io = process({proc_args})
        elif args.GDB:
            self.io = gdb.debug({proc_args}, gdbscript=gdbscript)
        else:
            host, port = conn_string.split(" ")
            self.io = remote(host, int(port))

        self.sla = lambda self, msg, data: self.io.sendlineafter(msg, data)
        self.sna = lambda self, msg, data: self.io.sendlineafter(msg, str(data).encode())
        self.sa = lambda self, msg, data: self.io.sendafter(msg, data)
        self.sl = lambda self, data: self.io.sendline(data)
        self.sn = lambda self, data: self.io.sendline(str(data).encode())
        self.s = lambda self, data: self.io.send(data)
        self.ru = lambda self, msg: self.io.recvuntil(msg)

    def pick_option(self, opt, index):
        self.io.sendlineafter(b"> ", str(opt).encode())
        self.io.sendlineafter(b"Index? ", str(index).encode())

def main():
    c = Challenge()

    # mrow meow meow

    c.io.interactive()

if __name__ == "__main__":
    main()
