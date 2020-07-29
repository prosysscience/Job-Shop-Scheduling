#!/usr/bin/python

import sys
import clingo
import theory
from clingo import Function
import threading
import time

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



    def main(self, prg, files):

        self.__theory.configure("propagate", "full,1")
        self.__theory.register(prg)
        if not files:
            files.append("-")
        for f in files:
            prg.load(f)
        
        #JobsNumber     = prg.get_const("numOfJobs").number
        #MachinesNumber = prg.get_const("numOfMachines").number
        numOfTimeWindows = 2
        i, ret = 0, None
        StaticProgramName = "solutionTimeWindow_"
        DynamicProgramName= ""
        TotalFacts = ""
        Lastbound = 0
        wait = True
        while (i <= numOfTimeWindows):
            print("Time Window", i)
            parts = []
            
            if i > 0:
                parts.append(("subproblem", [i]))
                if i > 1:
                    DynamicProgramName = StaticProgramName + str(i)
                    parts.append((DynamicProgramName, []))
                    prg.add(DynamicProgramName, [], TotalFacts)
            else:
                parts.append(("base", []))
            prg.cleanup()
            prg.ground(parts)
            self.__theory.prepare(prg)
            adjust = self.__theory.lookup_symbol(clingo.Number(0))
            
            bound = 0
            
            KillTheSearch = False
            go_out = False
            #startTime = time.time()
            while i > 0:
                #timer = threading.Timer(30.0, StopCurrentTW)
                prg.assign_external(Function("bound", [Lastbound-1]), False)
                #print(bound)
                #print(Lastbound)
                #print("***********************")
                Lastbound = bound
                #currentTime = time.time()
                with prg.solve(on_model=self.__on_model, on_statistics=self.__on_statistics, yield_=True, async_=True) as handle:
                    wait = handle.wait(60)
                    #if (handle.wait(0.000000000000000000000000000000000000011) != True):
                        #print("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR")
                        #break
                        #wait = handle.wait(60)
                    for model in handle:
                        #print(KillTheSearch)
                        #print(bound)
                        #print(Lastbound)
                        to_join = []
                        a = self.__theory.assignment(model.thread_id)

                        # *********** This is to loop on the current assignment to get the operations and starting time ***********
                        for name, value in a:
                            #sys.stdout.write("{} = {} ".format(name, value))
                            if(str(name) != "bound"):
                                FactsFormat = 'startTime({}, {}). '.format(name, value)
                                to_join.append(FactsFormat)
                                
                            else:
                                bound = int(value)
                        # *********** This is to loop on the current assignment to get the operations and starting time ***********
                        
                        TotalFacts = ''.join(to_join)
                        break
                        
                    else:
                        sys.stdout.write("Optimum Found\n")
                        break
                    if self.__theory.has_value(model.thread_id, adjust):
                        sys.stdout.write("adjustment: {}\n".format(self.__theory.get_value(model.thread_id, adjust)))
                prg.cleanup()
                prg.ground([("opt", [bound-1])])
                prg.assign_external(Function("bound", [bound-1]), True)
            else:
                ret = prg.solve()

            i = i+1
        print(TotalFacts)
        print("Total Completion Time: {}".format(Lastbound))
sys.exit(int(clingo.clingo_main(Application("test"), sys.argv[1:])))

'''
def main(prg):
    prg.add("p", "{a;b;c}.")
    prg.ground([("base", [])])
    with prg.solve(on_model=on_model, on_finish=on_finish, async=True) as handle:
        while not handle.wait(20):
            # do something asynchronously
        print(handle.get())
'''
