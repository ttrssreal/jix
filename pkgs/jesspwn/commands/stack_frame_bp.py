from pwndbg.commands import CommandCategory
import pwndbg
import gdb
import argparse

class BreakOnMatchingCallStack(pwndbg.gdblib.bpoint.Breakpoint):
    """
    A breakpoint that only stops the inferior if the call stack looks like given.
    """

    def __init__(self, spec, functions) -> None:
        super().__init__(spec, type=gdb.BP_BREAKPOINT, internal=False)
        self.functions = functions

    def should_stop(self):
        frame = pwndbg.dbg.selected_frame()
        if frame is None:
            print("stack_frame_bp: Cant get stack frame")
            return

        matched = []
        print("function:", self.functions)
        print("frame:", frame)

        while frame:
            for func in list(set(self.functions) - set(matched)):
                if func in frame.name():
                    matched.append(func)

            print("matched:", matched)

            frame = frame.parent()
            print("frame:", frame)

        return len(self.functions) == len(matched)

parser = argparse.ArgumentParser(description="set a breakpoint ...")

parser.add_argument(
    "spec",
    type=str,
    help="where to break"
)

parser.add_argument(
    "-f",
    "--function",
    type=str,
    action="append",
    help="function the stack frame must contain"
)

@pwndbg.commands.Command(parser, category=CommandCategory.STACK)
def stack_frame_bp(spec, function) -> None:
    if function is None:
        print("no function to match")
        return

    BreakOnMatchingCallStack(spec, function)
