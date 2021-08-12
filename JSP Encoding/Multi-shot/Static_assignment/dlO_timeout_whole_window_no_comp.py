#!/usr/bin/python
import sys
import clingo
import theory
import time
from clingo import Function

NUM_OF_TIME_WINDOWS = 2
MAX_TIMEOUT = 600

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
    def get_TimeOut(self):
        return MAX_TIMEOUT/NUM_OF_TIME_WINDOWS
    # ************************************************
    
    def write_old(self, start_time):
        old_start = start_time.split(' ')
        f = open('EST_TA60_solution.lp', 'a')
        for line in old_start:
            f.writelines(line)
            f.write("\n")
        f.close()
    
    # get the assignment of the operations in a string format to be sent as facts for the next Time Window
    def get_total_facts(self, assignment, i):
        total_facts = ''
        to_join = []
        for name, value in assignment:
            if str(name) != "bound":
                facts_format = "startTime({},{},{}). ".format(name, value, i)
                to_join.append(facts_format)
            else:
                bound = int(value)
        total_facts = ''.join(to_join)
        return total_facts, bound
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

    # add a new constraint to get lower value of bound (Optimization Part)
    def add_new_constraint(self, prg, bound):
        prg.cleanup()
        prg.ground([("opt", [bound-1])])
        prg.assign_external(Function("bound", [bound-1]), True)
    # ********************************************************************
    
    def main(self, prg, files):
        self.__theory.configure("propagate", "full,1")
        self.__theory.register(prg)
        if not files:
            files.append("-")
        for f in files:
            prg.load(f)
        time_out_for_window = self.get_TimeOut()
        i, ret = 0, None
        total_facts = ''
        overlapping_facts = ''
        lastbound = 0
        interrupted_calls = 0
        non_interrupted_calls = 0
        makespan_time_window = []
        overlap_atoms = []
        while i <= NUM_OF_TIME_WINDOWS:
            time_used = 0
            prg.configuration.solve.models = 0
            parts = self.step_to_ground(prg, i, total_facts)
            prg.cleanup()
            prg.ground(parts)
            self.__theory.prepare(prg)
            bound = 0
            while True:
                prg.assign_external(Function("bound", [lastbound-1]), False)
                lastbound = bound
                tic = time.time()
                if time_used >= time_out_for_window:
                    interrupted_calls += 1
                    break
                with prg.solve(on_model=self.__on_model, on_statistics=self.__on_statistics, async_=True, yield_=True) as handle:
                    wait = handle.wait(time_out_for_window - time_used)
                    if not wait:
                        interrupted_calls += 1
                        break
                    for model in handle:
                        if i > 1:
                            overlap_atoms = [atom for atom in model.symbols(atoms=True) if atom.name == "overlappedOperation"]
                        a = self.__theory.assignment(model.thread_id)
                        total_facts, bound = self.get_total_facts(a, i)
                        break
                    else:
                        non_interrupted_calls += 1
                        # sys.stdout.write("Optimum Found\n")
                        break
                toc = time.time()
                time_used += (toc - tic)
                self.add_new_constraint(prg, bound)
            else:
                ret = prg.solve()
            if i != 0:
                makespan_time_window.append(lastbound)
                overlapping_facts = ' '.join([str(atom) + "." for atom in overlap_atoms])
            #print(total_facts)
            #print("\n")
            #if i == NUM_OF_TIME_WINDOWS:
                #self.write_old(total_facts)
                #print("Overlapped_Operations {}".format(overlapping_facts))
                #print(overlapping_facts)
            #print("**************************************************************")
            i = i + 1      # Go to the next Time Window
        for x in range(NUM_OF_TIME_WINDOWS):
            print("Completion Time for Window {} : {} ".format(x+1, makespan_time_window[x]))
        print("Number of Interrupted Calls : {} ".format(interrupted_calls))
        print("Number of UnInterrupted Calls : {} ".format(non_interrupted_calls-1))

sys.exit(int(clingo.clingo_main(Application("test"), sys.argv[1:])))
