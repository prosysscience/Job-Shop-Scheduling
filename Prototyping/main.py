#!/usr/bin/python
'''
This module provides an application class similar to clingo-dl plus a main
function to execute it.
'''

import os
import sys
import math
import time
import bisect

import clingo
from clingo import ast, Number, Function, Control
from clingo.application import Flag
from clingodl import ClingoDLTheory

directory = os.path.dirname(__file__)
lp_windows = directory + "/encodings/windows.lp"
lp_overlap = directory + "/encodings/overlap.lp"
lp_ordering = directory + "/encodings/ordering.lp"
lp_schedule = directory + "/encodings/schedule.lp"
lp_compress = directory + "/encodings/compress.lp"

class Application(clingo.Application):
    '''
    Application class similar to clingo-dl (excluding optimization).
    '''
    _files: list
    _dynamic: Flag
    _timeout: int
    _window: int
    _windows: int
    _maxima: list
    _assignment: str
    _bound: int
    _bounds: list
    _compress: bool
    _current: str

    def __init__(self, name):
        self._dynamic = Flag()
        self._timeout = 0
        self._maxima = []
        self._bounds = []
        self.__theory = ClingoDLTheory()
        self.program_name = name
        self.version = ".".join(str(x) for x in self.__theory.version())

    def _parse_timeout(self, value):
        try:
            self._timeout = int(value)
        except ValueError:
            return False
        return self._timeout >= 0

    def register_options(self, options):
        self.__theory.register_options(options)
        options.add_flag("JSSP Options", "dynamic",
            "dynamically partition operations into time windows",
            self._dynamic)
        options.add("JSSP Options", "timeout",
            "set time limit in seconds (divided between time windows)",
            self._parse_timeout, argument="<n>")

    def validate_options(self):
        self.__theory.validate_options()
        return True

    def add_ordering(self, control, window, prefix, input, output):
        tuples = []
        for atom in control.symbolic_atoms.by_signature(input, 4):
            if atom.symbol.arguments[3].number == window:
#                print(atom.symbol)
                operation = atom.symbol.arguments[0]
                tuples.append((atom.symbol.arguments[1].number, atom.symbol.arguments[2].number, operation.arguments[0].number, operation.arguments[1].number))

        facts = ""
        n = 0
        for operation in sorted(tuples):
            facts += "{}(({},{}),{},{}).\n".format(output, abs(operation[2]), abs(operation[3]), n, window)
            n += 1

        program = "{}_{}".format(prefix, window)
        control.add(program, [], facts)
#        print("#program {}.".format(program))
#        print(facts)
        return program

    def add_maxima(self, control, window):
        for atom in control.symbolic_atoms.by_signature("scheduled", 5):
            if atom.symbol.arguments[4].number == window:
#                print(atom.symbol)
                m = atom.symbol.arguments[1].number - 1
                t = atom.symbol.arguments[2].number + atom.symbol.arguments[3].number
                if self._maxima[m] < t: self._maxima[m] = t

        facts = ""
        for m in range(len(self._maxima)):
            facts += "latest({},{},{}).\n".format(m + 1, self._maxima[m], window)

        program = "maxima_{}".format(window)
        control.add(program, [], facts)
#        print("#program {}.".format(program))
#        print(facts)
        return program

    def del_bounds(self, control):
        while True:
            bound = self._bounds[0]
            del self._bounds[0]
            control.release_external(Function("achieve", [Number(bound)]))
            if bound == self._bound: break

    def get_assignment(self, model):
        current = []
        self._current = ""
        self._assignment = ""
        for key, value in self.__theory.assignment(model.thread_id):
            if key.name == "bound": self._bound = value
            else:
                operation = Function("", [*key.arguments])
                self._assignment += "start({},{},{}). ".format(operation, value, self._window)
                if self._compress:
                    atom = Function("current", [operation, Number(self._window)])
                    if model.contains(atom): current.append((-value, (operation.arguments[0].number, operation.arguments[1].number)))
                    else: self._current += "previous(({},{}),{}).\n".format(*operation.arguments, self._window)
        if self._compress:
            n = 1
            for operation in sorted(current):
                self._current += "current({},{},{}).\n".format(operation[1], n, self._window)
                n += 1
            self._current += "previous(0,{}).\ncurrent({},{}).\n".format(self._window, n, self._window)
        self._bound -= 1

    def print_settings(self, control):
        print("% +++++++ SETTINGS/ +++++++")
        print("% Files:                ", self._files)
        print("% Timeout:", f"{self._timeout:{' '}{'<'}{13}}", "[--timeout=LIMIT: time limit per time window in seconds; unlimited if LIMIT=0] (default: LIMIT=0)")
        if self._dynamic.flag:
            print("% Dynamic:", self._dynamic.flag, "         [--dynamic: dynamically partition operations into time windows] (default: False)")
        else:
            print("% Dynamic:", self._dynamic.flag, "        [--dynamic: dynamically partition operations into time windows] (default: False)")
        print("% --const windows:", f"{self._windows:{' '}{'<'}{5}}", "[number of time windows] (default: --const windows=1)")
        print("% --const ordering:", control.get_const("ordering"), "   [1: EST; 2: MTWR; other: start time of a schedule represented by facts 'start((OPERATION,JOB),START,0).';\n%                         other than 0, 1, and 2 & --const bottleneck != 1: assert machine-wise upper bounds according to schedule] (default: --const ordering=1)")
        print("% --const bottleneck:", control.get_const("bottleneck"), " [1: (re)order operations by bottleneck machines; other: ignore machines] (default: --const bottleneck=0)")
        print("% --const compress:", control.get_const("compress"), "   [1: activate compression; other: deactivate compression] (default: --const compress=1)")
        print("% --const factor:", f"{control.get_const('factor').number:{' '}{'<'}{6}}", "[numerator of overlapping ratio] (default: --const factor=0)")
        print("% --const divisor:", f"{control.get_const('divisor').number:{' '}{'<'}{5}}", "[denominator of overlapping ratio] (default: --const divisor=10)")
        print("% +++++++ /SETTINGS +++++++")

    def print_header(self, window):
        print("% +++++++ OPTIMIZE/ +++++++")
        print("% Window:", window)

    def print_footer(self, control, timeopt, interrupt):
        print("% Assignment:", end=" ")
        if 0 <= self._bound: print(self._assignment)
        else: print("")
        print("% Bound:", self._bound + 1)
        print("% Variables:", int(control.statistics["problem"]["generator"]["vars"]))
#        print("% Constraints:", int(control.statistics["problem"]["generator"]["constraints"]))
        print("% Edges:", int(control.statistics["user_step"]["DifferenceLogic"]["Edges"]))
        print("% Solve Time:", "{:.2f}".format(timeopt))
        print("% Interrupts:", interrupt)
        print("% +++++++ /OPTIMIZE +++++++")

    def print_model(self, model, printer):
        # print model
        for atom in map(str, model.symbols(shown=True)): sys.stdout.write(f"{atom}. ")
        sys.stdout.write("\n")

        # print assignment
        sys.stdout.write("Assignment:\n")
        sys.stdout.write(self._assignment)
        sys.stdout.write("\n")
        sys.stdout.write("Bound: {}".format(self._bound + 1))
        sys.stdout.write("\n")
        sys.stdout.flush()

    def main(self, control, files):
        files.extend([lp_windows, lp_overlap, lp_ordering, lp_schedule])
        self._files = files
        self.__theory.register(control)
        with ast.ProgramBuilder(control) as bld:
            ast.parse_files(files, lambda stm: self.__theory.rewrite_ast(stm, bld.add))

        programs = [("base", [])]
        if not self._dynamic.flag: programs.append(("preorder", [Number(0)]))
#        print("GROUND:", programs)
        control.ground(programs)

        self._compress = control.get_const("compress").number == 1
        if self._compress:
            compress = Control()
            facts = "occupy(M,0,0,0,1,1,0) :- assignment(O,M,P).\n"
            for atom in control.symbolic_atoms.by_signature("assignment", 3): facts += "{}.\n".format(atom.symbol)
            compress.add("base", [], facts)
            compress.load(lp_compress)
            compression = [("base", [])]

        programs = []
        upper, given = False, {}
        for atom in control.symbolic_atoms.by_signature("upper", 0): upper = True
        try: machines = next(control.symbolic_atoms.by_signature("machines", 1)).symbol.arguments[0].number
        except StopIteration: machines = 0
        for m in range(machines):
            self._maxima.insert(m,0)
            if upper: given[m] = []
        for atom in control.symbolic_atoms.by_signature("upper", 3):
            m = atom.symbol.arguments[1].number - 1
            given[m].append((-atom.symbol.arguments[2].number, atom.symbol.arguments[0]))
        if upper:
            facts = ""
            for m in given:
                n = 1
                for tuple in sorted(given[m]):
                    facts += "ups_sort(({},{}),{},{}).\n".format(tuple[1].arguments[0].number, tuple[1].arguments[1].number, m+1, n)
                    n += 1
            control.add("upper", [], facts)
            programs = [("upper", [])]
        self._windows = next(control.symbolic_atoms.by_signature("windows", 1)).symbol.arguments[0].number
        if self._windows: self._timeout = math.ceil(self._timeout / self._windows)
        else: self._bound = -1
        self.print_settings(control)

        if not self._dynamic.flag:
            programs.extend([(self.add_ordering(control, 0, "ordering", "preorder", "ops_sort"), []), ("ordering", [Number(0)]), ("static", [])])

        interrupt = 0
        for i in range(self._windows):
            if 0 < i:
                control.cleanup()
                programs = []
                if 0 <= self._bound:
                    program = "start_{}".format(self._window)
                    control.add(program, [], self._assignment)
                    programs.append((program, []))

            self._window = i + 1
            programs.append(("previous", [Number(self._window)]))
#            print("GROUND:", programs)
            control.ground(programs)

            programs = [(self.add_ordering(control, self._window, "overlap", "previous", "pre_sort"), []), ("overlap", [Number(self._window)])]
#            print("GROUND:", programs)
            control.ground(programs)
            for atom in control.symbolic_atoms.by_signature("overlap", 2): control.release_external(atom.symbol)
            for atom in control.symbolic_atoms.by_signature("compressed", 3): control.release_external(atom.symbol)

            programs = [(self.add_maxima(control, self._window), [])]
            if self._dynamic.flag:
                programs.append(("preorder", [Number(self._window)]))
#                print("GROUND:", programs)
                control.ground(programs)
                programs = [(self.add_ordering(control, self._window, "ordering", "preorder", "ops_sort"), []), ("ordering", [Number(self._window)])]

            programs.append(("schedule", [Number(self._window)]))
#            print("GROUND:", programs)
            control.ground(programs)
            self.__theory.prepare(control)

            for bound in self._bounds: control.assign_external(Function("achieve", [Number(bound)]), False)
            self._bound = -1
            timeopt = 0
            self.print_header(self._window)
            while True:
                with control.solve(on_model=self.__on_model, on_statistics=self.__on_statistics, async_=True, yield_=True) as handle:
                    timeold = time.time()
                    if self._timeout <= 0: wait = handle.wait()
                    else: wait = handle.wait(self._timeout - timeopt)
                    timeopt += time.time() - timeold

                    if not wait:
                        interrupt += 1
                        break

                    result = handle.get()
                    if result.exhausted:
                        if result.unsatisfiable: self.del_bounds(control)
                        break

                if 0 < self._timeout and self._timeout <= timeopt:
                    interrupt += 1
                    break

                if not self._bound in self._bounds:
                    bisect.insort(self._bounds, self._bound)
                    control.ground([("optimize", [Number(self._window), Number(self._bound)])])
                control.assign_external(Function("achieve", [Number(self._bound)]), True)

            if self._compress:
                if 0 <= self._bound:
                    program = "current_{}".format(self._window)
                    compress.add(program, [], self._current)
                    compression.extend([(program, []), ("compress", [Number(self._window)])])
                    compress.ground(compression)
                    self._assignment = ""
                    for atom in compress.symbolic_atoms.by_signature("start", 3):
                        if atom.symbol.arguments[2].number == self._window: self._assignment += "{}. ".format(atom.symbol)
                    for atom in compress.symbolic_atoms.by_signature("bound", 3):
                        if atom.symbol.arguments[2].number == self._window and atom.symbol.arguments[0].number == machines: self._bound = atom.symbol.arguments[1].number - 1
                    compression = []
                else: self._compress = False
            self.print_footer(control, timeopt, interrupt)

        print("Schedule:")
        if 0 <= self._bound: print(self._assignment)
        else: print("fail.")
        print("Makespan:", self._bound + 1)
        print("Windows:", self._windows)
        print("Interrupted:", interrupt)
        self.print_settings(control)

    def __on_model(self, model):
        self.get_assignment(model)
        self.__theory.on_model(model)

    def __on_statistics(self, step, accu):
        self.__theory.on_statistics(step, accu)

    def __hidden(self, symbol):
        return symbol.type == clingo.SymbolType.Function and symbol.name.startswith("__")

if __name__ == "__main__":
    sys.exit(int(clingo.clingo_main(Application("clingo-dl"), sys.argv[1:])))
