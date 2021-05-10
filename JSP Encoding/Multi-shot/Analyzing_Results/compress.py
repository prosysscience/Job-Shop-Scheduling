#!/usr/bin/env python

# import re
import sys
import clingo

if len(sys.argv) == 1:
    sys.exit("Please call with schedule file, e.g.: python compress.py TA76_Info_0%_not_compressed.lp")

windows = 6
instance = 'TA76.lp'
schedule = sys.argv[1]
compress = 'Compress_schedule.lp'
factor = schedule[10]
divisor = '10'

overbase = '''
numOfOperations(M1)  :- M1 = numOfJobs * numOfMachines.
numOfTimeWindows(TW) :- TW = #max{TimeWindow : assignToTimeWindow(JobNum, StepNum, TimeWindow)}.
numOfOperPerTWin(M2) :- numOfOperations(M1), numOfTimeWindows(TW), M2 = (M1 + TW - 1) / TW.
'''
overstep = '''
% #program step(t).

this(t).

#external this(t+1).

previous(JobNum, StepNum, t) :- assignToTimeWindow(JobNum, StepNum, t-1).
previous(JobNum, StepNum, t) :- overlapping(JobNum, StepNum, t-1).

index(JobNum1, StepNum1, N, t) :- starting((JobNum1, StepNum1), StartTime1, t-1),
                                  assignment(JobNum1, StepNum1, MachNum1, ProTime1),
                                  previous  (JobNum1, StepNum1, t),
                                  N = #count{JobNum2, StepNum2 : starting((JobNum2, StepNum2), StartTime2, t-1),
				                                 assignment(JobNum2, StepNum2, MachNum2, ProTime2),
				                                 previous  (JobNum2, StepNum2, t),
							         (StartTime1, ProTime1, StepNum1, JobNum1) < (StartTime2, ProTime2, StepNum2, JobNum2)}.

overlapping(JobNum, StepNum, t) :- index(JobNum, StepNum, N, t), numOfOperPerTWin(M), N < (factor * M / divisor).

overlapreal(JobNum, StepNum, t) :- overlapping(JobNum, StepNum, t), overlappedOperation(JobNum, StepNum, t).

#show.
#show overlapping(JobNum, StepNum, t) : overlapping(JobNum, StepNum, t).
#show overlapshow(JobNum, StepNum, t) : overlapping(JobNum, StepNum, t), not this(t+1).
#show overlappedOperation(JobNum, StepNum, t) : overlapreal(JobNum, StepNum, t).
#show startTime((JobNum, StepNum), StartTime, t) : startTime((JobNum, StepNum), StartTime, t), assignToTimeWindow(JobNum, StepNum, t).
#show startTime((JobNum, StepNum), StartTime, t) : startTime((JobNum, StepNum), StartTime, t), overlapreal(JobNum, StepNum, t).
#show startTime((JobNum, StepNum), StartTime, t) : starting((JobNum, StepNum), StartTime, t-1), not overlapreal(JobNum, StepNum, t).
'''

# print(overbase + overstep)
overlap = clingo.Control(['--const','factor={}'.format(factor),'--const','divisor={}'.format(divisor)])
overlap.add('base', [], overbase)
overlap.add('step', ['t'], overstep)
overlap.load(instance)
overlap.load(schedule)
overlap.ground([('base', [])])
current = ''

def prepare(model):
    global data
    atoms = model.symbols(shown=True)
    for atom in atoms:
        data += str(atom) + '.\n'
        if atom.name == 'overlapshow':
            print('overlappedOperation(' + ','.join(str(sym) for sym in atom.arguments) + ').')

def process(model):
    global current
    current = ''
    atoms = model.symbols(shown=True)
    for atom in atoms:
        print(str(atom) + '.')
        current += 'starting(' + ','.join(str(sym) for sym in atom.arguments) + ').'

for i in range(1, windows + 1):

    data = '#show.\n'
    print('% WINDOW {}'.format(i))

    overlap.add('step', ['t'], current)
    overlap.ground([('step', [i])])
    overlap.solve(on_model=prepare)

    compression = clingo.Control(['--const','compress={}'.format(i)])
    compression.load(instance)
    compression.load(compress)
    compression.add('base', [], data)
    compression.ground([('base', [])])
    compression.solve(on_model=process)
