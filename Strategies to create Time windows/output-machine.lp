todo(JobNum, StepNum, N, 1)     :- index(JobNum, StepNum, N).
todo(JobNum, StepNum, N, I + 1) :- todo(JobNum, StepNum, N, I),
                                   pick(JobNuM, StepNuM, M, I), JobNum != JobNuM.
todo(JobNum, StepNum, N, I + 1) :- todo(JobNum, StepNum, N, I),
                                   pick(JobNum, StepNuM, M, I), StepNuM < StepNum.
todo(I)                         :- todo(JobNum, StepNum, N, I).

done(JobNum, StepNum, 0, I) :- todo(I),
                               startTime((JobNum, StepNum), StartTime).
done(JobNum, StepNum, N, I) :- todo(I),
                               fill(JobNum, StepNum, N, I - 1).
done(JobNum, StepNum, N, I) :- todo(I),
                               done(JobNum, StepNum, N, I - 1).

curr(0, 1) :- todo(1),
              not scheduled(_). % THIS RULE CAN BE REMOVED IF scheduled/1 IS ALWAYS INCLUDED
curr(M, 1) :- todo(1),
              scheduled(M).
curr(M, I) :- todo(I),
              pick(JobNum, StepNum, N, I - 1),
              number(JobNum, StepNum, M - 1).

load(MachNum, JobNum, ProTime, I)     :- assignment(JobNum, StepNum, MachNum, ProTime),
                                         numOfJobs(JobNum),
                                         todo(JobNum, StepNum, N, I).
load(MachNum, JobNum, 0, I)           :- assignment(JobNum, StepNum, MachNum, ProTime),
                                         numOfJobs(JobNum),
                                         done(JobNum, StepNum, N, I).
load(MachNum, JobNum, ProTime + L, I) :- assignment(JobNum, StepNum, MachNum, ProTime),
                                         load(MachNum, JobNum + 1, L, I),
                                         todo(JobNum, StepNum, N, I).
load(MachNum, JobNum, L, I)           :- assignment(JobNum, StepNum, MachNum, ProTime),
                                         load(MachNum, JobNum + 1, L, I),
                                         done(JobNum, StepNum, N, I).

high(MachNum, MachNum, L, I) :- load(MachNum, 1, L, I),
                                numOfMachines(MachNum).
high(MachNum, MachNum, L, I) :- load(MachNum, 1, L, I),
                                high(MachNum + 1, LoadNum, L2, I), L2 <= L.
high(MachNum, LoadNum, L, I) :- load(MachNum, 1, L1, I),
                                high(MachNum + 1, LoadNum, L, I), L1 < L.

poss(0, I)     :- todo(I),
                  not scheduled(_). % THIS RULE CAN BE REMOVED IF scheduled/1 IS ALWAYS INCLUDED
poss(N, I)     :- todo(I),
                  scheduled(N).
poss(N + 1, I) :- poss(N, I),
                  done(JobNum, StepNum, N, I).
poss(N + 1, I) :- keep(JobNum, StepNum, N, I).

keep(JobNum, StepNum, N, I) :- poss(N, I),
                               todo(JobNum, StepNum, N, I),
                               assignment(JobNum, StepNum, MachNum, ProTime),
                               high(1, LoadNum, L, I), LoadNum != MachNum.

pick(JobNum, StepNum, N, I) :- poss(N, I),
                               todo(JobNum, StepNum, N, I),
                               assignment(JobNum, StepNum, MachNum, ProTime),
                               high(1, MachNum, L, I).

fill(JobNum, StepNum, N, I) :- pick(JobNum, StepNum, N, I).
fill(JobNum, StepNum, N, I) :- todo(JobNum, StepNum, N, I),
                               fill(JobNum, StepNum + 1, NN, I).

number(JobNum, 1, M)       :- fill(JobNum, 1, N, I),
                              curr(M, I).
number(JobNum, StepNum, M) :- fill(JobNum, StepNum, N, I),
                              done(JobNum, StepNum - 1, NN, I),
                              curr(M, I).
number(JobNum, StepNum, M) :- fill(JobNum, StepNum, N, I),
                              number(JobNum, StepNum - 1, M - 1),
                              curr(MM, I), MM < M.

assignToTimeWindow(JobNum, StepNum, M) :- number(JobNum, StepNum, N), operationWindow(M, N).

#show assignToTimeWindow/3.
