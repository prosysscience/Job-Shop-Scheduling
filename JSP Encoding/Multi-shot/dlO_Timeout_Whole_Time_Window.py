#!/usr/bin/python
import sys
import clingo
import theory
import time
from clingo import Function

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
    def get_TimeOut(self, JobsNumber, MachinesNumber):
        TimeOutForWindow = 0
        if JobsNumber == 100:
            TimeOutForWindow = 5020
        elif JobsNumber == 50:
            if MachinesNumber == 20:
                TimeOutForWindow = 910
            elif MachinesNumber == 15:
                TimeOutForWindow = 670
            elif MachinesNumber == 10:
                TimeOutForWindow = 509
        elif JobsNumber == 30:
            if MachinesNumber == 15:
                TimeOutForWindow = 935
            elif MachinesNumber == 20:
                TimeOutForWindow = 922
        return TimeOutForWindow
    # ************************************************

    # get the assignment of the operations in a string format to be sent as facts for the next Time Window
    def get_TotalFacts(self, assignment):
        TotalFacts = ''
        to_join = []
        for name, value in assignment:
            if str(name) != "bound":
                FactsFormat = "startTime({}, {}). ".format(name, value)
                to_join.append(FactsFormat)
            else:
                bound = int(value)
        TotalFacts = ''.join(to_join)
        return TotalFacts, bound
    # ****************************************************************************************************

    # get the part that should be grounded and solved
    def step_To_Ground(self, prg, step, TotalFacts):
        parts = []
        if step > 0:
            parts.append(("subproblem", [step]))
            if step > 1:
                parts.append(("solutionTimeWindow", []))
                prg.add("solutionTimeWindow", [], TotalFacts)
        else:
            parts.append(("base", []))
        return parts
    # ***********************************************

    # add a new constraint to get lower value of bound (Optimization Part)
    def add_New_Constraint(self, prg, bound):
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
        numOfTimeWindows = 1
        JobsNumber     = prg.get_const("numOfJobs").number
        MachinesNumber = prg.get_const("numOfMachines").number
        TimeOutForWindow = self.get_TimeOut(JobsNumber, MachinesNumber)
        i, ret = 0, None
        TotalFacts = ''
        Lastbound = 0
        makeSpanTW = []
        while i <= numOfTimeWindows:
            timeUsed = 0
            prg.configuration.solve.models = 0
            parts = self.step_To_Ground(prg, i, TotalFacts)
            prg.cleanup()
            prg.ground(parts)
            self.__theory.prepare(prg)
            adjust = self.__theory.lookup_symbol(clingo.Number(0))
            bound = 0
            while True:
                prg.assign_external(Function("bound", [Lastbound-1]), False)
                Lastbound = bound
                tic = time.time()
                if timeUsed >= TimeOutForWindow:
                    break
                with prg.solve(on_model=self.__on_model, on_statistics=self.__on_statistics, async_=True, yield_=True) as handle:
                    wait = handle.wait(TimeOutForWindow - timeUsed)
                    if not wait:
                    	break
                    for model in handle:
                        a = self.__theory.assignment(model.thread_id)
                        TotalFacts, bound = self.get_TotalFacts(a)
                        break
                    else:
                        # sys.stdout.write("Optimum Found\n")
                        break
                toc = time.time()
                timeUsed += (toc - tic)
                self.add_New_Constraint(prg, bound)
            else:
                ret = prg.solve()
            if i != 0:
                makeSpanTW.append(Lastbound)
            i = i + 1		# Go to the next Time Window
        for x in range(numOfTimeWindows):
            print("Completion Time for Window {} : {} ".format(x+1, makeSpanTW[x]))
sys.exit(int(clingo.clingo_main(Application("test"), sys.argv[1:])))
