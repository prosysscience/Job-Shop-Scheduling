#const numTW =2.  #(\label{prg:predeco:tw:begin}#)
timeWindows(1..numTW). #(\label{prg:predeco:tw:end}#)

job(Job) :- operation(Job, MachNum).
mach(MachNum) :- assign(Job, Step, MachNum).

numJobs(Job)  :- job(Job), not job(Job + 1).   #(\label{prg:predeco:jmo:begin}#)
numMach(MachNum) :- mach(MachNum), not mach(MachNum + 1). #(\label{prg:predeco:jmo:end}#)

numOper(M1) :- numJobs(Job), numMach(MachNum), #(\label{prg:predeco:o:begin}#)
               M1 = Job * MachNum.             #(\label{prg:predeco:o:end}#)

numOperTW(M2) :- numOper(M1), M2 = (M1 + numTW - 1) / numTW. #(\label{prg:predeco:optw:begin}#)