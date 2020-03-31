#!/usr/bin/env python3

import clingo
import json
import sys
import argparse
import csv
import os
import ntpath
from pandas import DataFrame
from pathlib import Path
import difference_logic as dl

CSV_FILE_NAME = str(Path().absolute())

class App:
    def __init__(self, args):
        self.control = clingo.Control()
        self.args = args
        self.numberOfMachines = 0
        self.numberOfJobs = 0
       
    def on_model(m):
      print(m)

    def run(self):
        # load the input files and define the values maxNode, firstNode and nodes 
        for source in self.args.file:
            self.control.load(source)
        self.numberOfJobs = self.control.get_const("numOfJobs").number
        self.numberOfMachines = self.control.get_const("numOfMachines").number
        p = dl.Propagator()
        self.control.register_propagator(p)
        self.control.ground([("base", [])])
        #ret = self.control.solve(on_model=self.show)
        
        #bound = 0
        count=10
        while count>0:
            count = count-1
            with self.control.solve(yield_=True, async_=True) as handle:
                    handle.resume()
                    if handle.wait(10):
                        m = next(handle, None)
                        print(m)
                        if m is not None:
                            a = p.get_assignment(m.thread_id)
                            for n, v in a:
                                if n == "bound":
                                    bound = v
                                    break
                            print(bound)
                            break
                    handle.cancel()
                    ret = handle.get()

            print(ret)
 
            #-R

            #count=count-1

            
            '''
            with self.control.solve(yield_=True, async_=True) as handle:

                wait = handle.wait(0.000060)
                print(wait)
                count= count-1
                for m in handle:
                    a = p.get_assignment(m.thread_id)
                    for n, v in a:
                        if n == "bound":
                            bound = v
                            break
                    print ("Valid assignment for constraints found:")
                    print (" ".join(["{}={}".format(n, v) for n, v in a]))
                    print ("Found new bound: {}".format(bound))
                        

            self.control.ground([("bound", [bound-1])])
            '''

#main code
parser = argparse.ArgumentParser(description="Find Optimal schedule.", epilog="""Example: main.py instance.lp encoding.lp""")

parser.add_argument("-q", "--quiet", action='store_true', help="do not print models")
parser.add_argument("-s", "--stats", action='store_true', help="print solver statistics")
parser.add_argument("-i", "--instanceNumber", nargs=1, metavar=("NUM"), help="number of input instance")
parser.add_argument("file", nargs="*", default=[], help="gringo source files")

args = parser.parse_args()
# run the application with the parsed args
App(args).run() 