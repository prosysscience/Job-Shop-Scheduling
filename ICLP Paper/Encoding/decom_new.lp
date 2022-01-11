#const numTW = 2.  % #(\label{prg:predeco:tw:begin}#)
windows(1..numTW). % #(\label{prg:predeco:tw:end}#)

operation(Job, Step) :- assignment(Job, Step, Machine, PT).
assign(Job, Step, Machine) :- assignment(Job, Step, Machine, PT).

job(Job) :- operation(Job, Step).
mch(Machine) :- assign(Job, Step, Machine).

numJob(Job)  :- job(Job), not job(Job + 1).   % #(\label{prg:predeco:jmo:begin}#)
numMch(Machine) :- mch(Machine), not mch(Machine + 1). % #(\label{prg:predeco:jmo:end}#)

numOps(Job * Machine) :- numJob(Job), numMch(Machine). % #(\label{prg:predeco:o:begin}#) #(\label{prg:predeco:o:end}#)

numOpsTW((N + numTW - 1) / numTW) :- numOps(N). % #(\label{prg:predeco:optw:begin}#)

est(Job, 1, 0) :- operation(Job, 1).       % #(\label{prg:assignment_process:est:begin}#)

est(Job, Step, ST + PT) :- est(Job, Step - 1, ST),
                           pro(Job, Step - 1, PT),
                           operation(Job, Step). % #(\label{prg:assignment_process:est:end}#)

index(Job, Step, M) :- est(Job, Step, ST), % #(\label{prg:assignment_process:rank:begin}#)
                       pro(Job, Step, PT),
   M = #count{J', S' : est(J', S', ST'),
                       pro(J', S', PT'),
     (ST', PT', S', J') < (ST, PT, Step, Job)}. %  #(\label{prg:assignment_process:rank:end}#)

window(Job, Step, (M+N) / N) :- index(Job, Step, M), % #(\label{prg:assignment_process:assign:begin}#)
                                numOpsTW(N).       % #(\label{prg:assignment_process:assign:end}#)
#show window/3.