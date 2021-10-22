#const numTW =2.  %#(\label{prg:predeco:tw:begin}#)
timeWindows(1..numTW). %#(\label{prg:predeco:tw:end}#)

job(JobNum) :- operation(JobNum, MachNum).
mach(MachNum) :- assign(JobNum, StepNum, MachNum).

numJobs(JobNum)  :- job(JobNum), not job(JobNum + 1).   %#(\label{prg:predeco:jmo:begin}#)
numMach(MachNum) :- mach(MachNum), not mach(MachNum + 1). %#(\label{prg:predeco:jmo:end}#)

numOper(M1) :- numJobs(JobNum), numMach(MachNum), %#(\label{prg:predeco:o:begin}#)
                        M1 = JobNum * MachNum.   %#(\label{prg:predeco:o:end}#)

numOperTW(M2) :- numOper(M1), M2 = (M1 + numTW - 1) / numTW. %#(\label{prg:predeco:optw:begin}#)
