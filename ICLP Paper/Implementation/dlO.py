#!/usr/bin/python
import sys
import clingo
import theory
import time
from clingo import Function

NUM_OF_TIME_WINDOWS = 2
MAX_TIMEOUT = 1000

class Application:
    def __init__(self, name):
        self.program_name = name
        self.version = "1.0"
        self.__theory = theory.Theory("clingodl", "clingo-dl")

    def __on_model(self, model):
        self.__theory.on_model(model)

    def register_options(self, options):
        self.__theory.register_options(options)

    def validate_options(self):
        self.__theory.validate_options()
        return True

    def __on_statistics(self, step, accu):
        self.__theory.on_statistics(step, accu)
        pass
    
    # get the Time out per Time Window
    def get_timeout(self):
        return MAX_TIMEOUT/NUM_OF_TIME_WINDOWS
    # ************************************************

    # get the assignment of the operations in a string format to be sent as facts for the next Time Window
    def get_total_facts(self, assignment, i):
        total_facts = ''
        to_join = []
        for name, value in assignment:
            if str(name) != "makespan":
                facts_format = "startTime({}, {}, {}). ".format(name, value, i)
                to_join.append(facts_format)
            else:
                makespan = int(value)
        total_facts = ''.join(to_join)
        return total_facts, makespan
    # ****************************************************************************************************

    # get the part that should be grounded and solved
    def step_to_ground(self, prg, step, total_facts):
        parts = []
        if step > 0:
            parts.append(("subproblem", [step]))
            if step > 1:
                parts.append(("solutionTimeWindow", []))
                prg.add("solutionTimeWindow", [], total_facts)
        else:
            parts.append(("base", []))
        return parts
    # ***********************************************

    # add a new constraint to get lower value of makespan (Optimization Part)
    def add_new_constraint(self, prg, makespan):
        prg.cleanup()
        prg.ground([("opt", [makespan-1])])
        prg.assign_external(Function("makespan", [makespan-1]), True)
    # ********************************************************************

    def main(self, prg, files):
        self.__theory.configure("propagate", "full,1")
        self.__theory.register(prg)
        if not files:
            files.append("-")
        for f in files:
            prg.load(f)
        timeout_for_window = self.get_timeout()
        i, ret = 0, None
        total_facts = ''
        lastmakespan = 0
        interrupted_calls = 0
        non_interrupted_calls = 0
        makespan_time_window = []
        while i <= NUM_OF_TIME_WINDOWS:
            time_used = 0
            prg.configuration.solve.models = 0
            parts = self.step_to_ground(prg, i, total_facts)
            prg.cleanup()
            prg.ground(parts)
            self.__theory.prepare(prg)
            #adjust = self.__theory.lookup_symbol(clingo.Number(0))
            makespan = 0
            while True:
                prg.assign_external(Function("makespan", [lastmakespan-1]), False)
                lastmakespan = makespan
                tic = time.time()
                if time_used >= timeout_for_window:
                    interrupted_calls += 1
                    break
                with prg.solve(on_model=self.__on_model, on_statistics=self.__on_statistics, async_=True, yield_=True) as handle:
                    wait = handle.wait(timeout_for_window - time_used)
                    if not wait:
                        interrupted_calls += 1
                        break
                    for model in handle:
                        a = self.__theory.assignment(model.thread_id)
                        total_facts, makespan = self.get_total_facts(a, i)
                        
                        break
                    else:
                        non_interrupted_calls += 1
                        # sys.stdout.write("Optimum Found\n")
                        break
                toc = time.time()
                time_used += (toc - tic)
                self.add_new_constraint(prg, makespan)
            else:
                ret = prg.solve()
            if i != 0:
                makespan_time_window.append(lastmakespan)
            i = i + 1      # Go to the next Time Window
            print("Makespan {} : Assignment {}".format(lastmakespan, total_facts))
            print("**************************************************************")
        for x in range(NUM_OF_TIME_WINDOWS):
            print("Completion Time for Window {} : {} ".format(x+1, makespan_time_window[x]))
        print("Number of Interrupted Calls : {} ".format(interrupted_calls))
        print("Number of UnInterrupted Calls : {} ".format(non_interrupted_calls-1))

sys.exit(int(clingo.clingo_main(Application("test"), sys.argv[1:])))
