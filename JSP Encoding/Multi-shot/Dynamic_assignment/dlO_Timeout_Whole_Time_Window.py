#!/usr/bin/python
import sys
import clingo
import theory
import time
from clingo import Function
next_window_assignment = ''
NUM_OF_TIME_WINDOWS = 3
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
    def get_timeout(self, num_of_time_windows):
        timeout_for_window = 0
        timeout_for_window = MAX_TIMEOUT/num_of_time_windows
        return timeout_for_window
    # ************************************************

    # get the assignment of the operations in a string format to be sent as facts for the next Time Window
    def get_total_facts(self, assignment):
        total_facts = ''
        to_join = []
        for name, value in assignment:
            if str(name) != "bound":
                facts_format = "startTime({}, {}). ".format(name, value)
                to_join.append(facts_format)
            else:
                bound = int(value)
        total_facts = ''.join(to_join)
        return total_facts, bound
    # ****************************************************************************************************

    # get the part that should be grounded and solved
    def step_To_ground(self, prg, step, total_facts):
        parts = []
        if step > 0:
            parts.append(("subproblem", [step]))
            parts.append(("assign_to_time_window", []))
            prg.add("assign_to_time_window", [], next_window_assignment)
            if step > 1:
                parts.append(("solution_time_window", []))
                prg.add("solution_time_window", [], total_facts)
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

    def get_time_Window(self, text, current_time_window):
        global next_window_assignment
        seperated_time_windows = text.split()
        all_predicates = []
        for single_assignment in seperated_time_windows:
            for_parsing = single_assignment.split(",")
            temp = for_parsing[2].split(")")
            if int(temp[0]) == current_time_window:
                facts_format = "{}. ".format(single_assignment)
                all_predicates.append(facts_format)
        next_window_assignment += ''.join(all_predicates)
        
    def generating_next_time_window(self, total_facts, current_time_window):
        list_files = [sys.argv[2], "dynamic-mtwr.lp", "output-direct.lp"]
        ctl = clingo.Control()
        for f in list_files:
            ctl.load(f)
        ctl.add("base", [], total_facts)
        ctl.ground([("base", [])])
        ctl.solve(on_model=lambda m: self.get_time_Window("{}".format(m), current_time_window))

    def main(self, prg, files):
        self.__theory.configure("propagate", "full,1")
        self.__theory.register(prg)
        if not files:
            files.append("-")
        for f in files:
            prg.load(f)
        NUM_OF_TIME_WINDOWS = 4
        timeout_for_window = self.get_timeout(NUM_OF_TIME_WINDOWS)
        i, ret = 0, None
        total_facts = ''
        last_bound = 0
        interrupted_calls = 0
        non_interrupted_calls = 0
        makespan_time_window = []
        while i <= NUM_OF_TIME_WINDOWS:
            time_used = 0
            prg.configuration.solve.models = 0
            parts = self.step_To_ground(prg, i, total_facts)
            prg.cleanup()
            prg.ground(parts)
            self.__theory.prepare(prg)
            adjust = self.__theory.lookup_symbol(clingo.Number(0))
            bound = 0
            while True:
                prg.assign_external(Function("bound", [last_bound-1]), False)
                last_bound = bound
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
                        total_facts, bound = self.get_total_facts(a)
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
                makespan_time_window.append(last_bound)
            i = i + 1      # Go to the next Time Window
            #next_window_assignment = ''
            self.generating_next_time_window(total_facts, i) # This call is to generate Time Window Assignment for the upcoming Window
        for x in range(NUM_OF_TIME_WINDOWS):
            print("Completion Time for Window {} : {} ".format(x+1, makespan_time_window[x]))
        print("Number of interrupted calls : {} ".format(interrupted_calls))
        print("Number of non-interrupted calls : {} ".format(non_interrupted_calls-1))
        #print(sys.argv[2])

sys.exit(int(clingo.clingo_main(Application("test"), sys.argv[1:])))
