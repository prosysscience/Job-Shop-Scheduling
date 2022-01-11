#const numTW = 2.  #(\label{prg:predeco:tw:begin}#)
windows(1..numTW). #(\label{prg:predeco:tw:end}#)

job(Job) :- operation(Job, Machine).
mch(Machine) :- assign(Job, Step, Machine).

numJob(Job)  :- job(Job), not job(Job + 1).   #(\label{prg:predeco:jmo:begin}#)
numMch(Machine) :- mch(Machine), not mch(Machine + 1). #(\label{prg:predeco:jmo:end}#)

numOps(Job * Machine) :- numJob(Job), numMch(Machine). #(\label{prg:predeco:o:begin}#) #(\label{prg:predeco:o:end}#)

numOpsTW((N + numTW - 1) / numTW) :- numOps(N). #(\label{prg:predeco:optw:begin}#)