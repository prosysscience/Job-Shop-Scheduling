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
        self.version = '1.0'
        self.__theory = theory.Theory('clingodl', 'clingo-dl')
        self.compressed_start_time = ''
        self.next_window_assignment = ''

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

    # get the assignment of the operations in a string format to be sent as facts for the next Time Window
    def get_total_facts(self, assignment, i):
        start_time = ''
        to_join = []
        for name, value in assignment:
            if str(name) != 'bound':
                facts_format = 'startTime({},{},{}).'.format(name, value, i)
                to_join.append(facts_format)
            else:
                bound = int(value)
        start_time = ' '.join(to_join)
        return start_time, bound
    # ****************************************************************************************************

    # get the part that should be grounded and solved
    def step_to_ground(self, prg, step):
        #print('Start Time : {} '.format(step), start_time)
        string1 = 'assign_to_time_window' + str(step)
        string2 = 'solution_time_window' + str(step)
        parts = []
        if step > 0:
            parts.append(('subproblem', [step]))
            parts.append((string1, []))
            prg.add(string1, [], self.next_window_assignment)
            if step > 1:
                parts.append((string2, []))
                prg.add(string2, [], self.compressed_start_time)
        else:
            parts.append(('base', []))
        return parts
    # ***********************************************

    # add a new constraint to get lower value of bound (Optimization Part)
    def add_new_constraint(self, prg, bound):
        prg.cleanup()
        prg.ground([('opt', [bound-1])])
        prg.assign_external(Function('bound', [bound-1]), True)
    # ********************************************************************

    def get_time_Window(self, text, current_time_window):
        #global next_window_assignment
        seperated_time_windows = text.split()
        all_predicates = []
        for single_assignment in seperated_time_windows:
            for_parsing = single_assignment.split(",")
            temp = for_parsing[2].split(")")
            if int(temp[0]) == current_time_window:
                facts_format = "{}. ".format(single_assignment)
                all_predicates.append(facts_format)
        self.next_window_assignment += ''.join(all_predicates)
        
    def generating_next_time_window(self, total_facts, current_time_window):
        list_files = [sys.argv[2], "dynamic-est.lp", "output-machine.lp"]
        ctl = clingo.Control()
        for f in list_files:
            ctl.load(f)
        ctl.add("base", [], total_facts)
        ctl.ground([("base", [])])
        ctl.solve(on_model=lambda m: self.get_time_Window("{}".format(m), current_time_window))

    def write_facts(self, start_time):
        old_start = start_time.split(' ')
        new_start = self.compressed_start_time.split(' ')
        f = open('old.lp', 'a')
        for line in old_start:
            f.writelines(line)
            f.write("\n")
        f.close()
        
        f = open('new.lp', 'a')
        for line in new_start:
            f.writelines(line)
            f.write("\n")
        f.close()
        
    def post(self, model):
        list_atom =[]
        list_of_args = []
        atoms = model.symbols(terms = True)
        for atom in atoms:
            if atom.name == 'startTime':
                list_atom.append(str(atom) + '.')
        self.compressed_start_time = ' '.join(list_atom)

    def compression(self, start_time, overlapping_facts, i):
        list_files = [sys.argv[2], 'compress_schedule.lp']
        compress = clingo.Control()
        for f in list_files:
            compress.load(f)
        compress.add('base', [], start_time + ' ' + overlapping_facts)
        compress.ground([('base', [])])
        compress.solve(on_model=self.post)
        

    def main(self, prg, files):
        self.__theory.configure('propagate', 'full,1')
        self.__theory.register(prg)
        if not files:
            files.append('-')
        for f in files:
            prg.load(f)
        time_out_for_window = self.get_TimeOut()
        i, ret = 0, None
        start_time = ''
        total_facts = ''
        overlapping_facts = ''
        self.compressed_start_time = ''
        lastbound = 0
        interrupted_calls = 0
        non_interrupted_calls = 0
        makespan_time_window = []
        overlap_atoms = []
        while i <= NUM_OF_TIME_WINDOWS:
            time_used = 0
            prg.configuration.solve.models = 0
            prg.cleanup()
            parts = self.step_to_ground(prg, i)
            prg.ground(parts)
            self.__theory.prepare(prg)
            bound = 0
            while True:
                prg.assign_external(Function('bound', [lastbound-1]), False)
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
                        a = self.__theory.assignment(model.thread_id)
                        start_time, bound = self.get_total_facts(a, i)
                        overlap_atoms = [atom for atom in model.symbols(atoms=True) if atom.name == 'overlappedOperation']
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
                overlapping_facts = ' '.join([str(atom) + '.' for atom in overlap_atoms])
                self.compression(start_time, overlapping_facts, i)
                self.compressed_start_time = self.compressed_start_time + ' '
            i = i + 1      # Go to the next Time Window
            if i > 1:
                total_facts = self.compressed_start_time
            self.generating_next_time_window(total_facts, i)
        for x in range(NUM_OF_TIME_WINDOWS):
            print('Completion Time for Window {} : {} '.format(x+1, makespan_time_window[x]))
        print('Number of Interrupted Calls : {} '.format(interrupted_calls))
        print('Number of UnInterrupted Calls : {} '.format(non_interrupted_calls-1))

sys.exit(int(clingo.clingo_main(Application('test'), sys.argv[1:])))
