#const n = 2.  #(\label{prg:predeco:tw:begin}#)
windows(1..n). #(\label{prg:predeco:tw:end}#)

widthTW((N + n - 1) / n) :- N = #count{J,S : operation(J,S,M,P)}. #(\label{prg:predeco:optw:begin}#)

est(J,1,P,0)      :- operation(J,1,M,P).        #(\label{prg:assignment_process:est:begin}#)
est(J,S,P,P' + E) :- operation(J,S,M,P), est(J,S - 1,P',E).  #(\label{prg:assignment_process:est:end}#)

index(J,S,N) :- est(J,S,P,E),  #(\label{prg:assignment_process:rank:begin}#)
         N = #count{J',S' : est(J',S',P',E'), (E',P',J') < (E,P,J)}.   #(\label{prg:assignment_process:rank:end}#)

window(J,S,(N + W) / W) :- index(J,S,N), widthTW(W). #(\label{prg:assignment_process:assign:begin}#) #(\label{prg:assignment_process:assign:end}#)
