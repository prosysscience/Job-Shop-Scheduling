#program step(w).

use(M,w,w) :- operation(J,S,M,P), window(J,S,w). #(\label{prg:encoding:use1}#)
use(M,W,w) :- use(M,W,w - 1), not window(J,S,w) : operation(J,S,M,P). #(\label{prg:encoding:use2}#)

share((J1,S1),(J2,S2),P1,P2,X,w) :- operation(J1,S1,M,P1), #(\label{prg:base:sharing_machine:begin}#)
                                    operation(J2,S2,M,P2),
                                    window(J1,S1,W),
                                    window(J2,S2,w), (W,J1) < (w,J2),
                                    use(M,W,w - X), X = 0..1. #(\label{prg:base:sharing_machine:end}#)

order(O1,O2,P1,w)        :- share(O1,O2,P1,P2,1,w). #(\label{prg:base:ordered}#) 
order((J,S1),(J,S2),P,w) :- operation(J,S1,M,P), window(J,S2,w), #(\label{prg:base:same_job:begin}#) 
                            S1 = S2 - 1. #(\label{prg:base:same_job:end}#)

{order(O1,O2,P1,w)} :- share(O1,O2,P1,P2,0,w). #(\label{prg:base:order}#)
 order(O2,O1,P2,w)  :- share(O1,O2,P1,P2,0,w), #(\label{prg:base:order:begin}#)
                       not order(O1,O2,P1,w).  #(\label{prg:base:order:end}#)

&diff{O - 0} <=  T :- start(O,T,w - 1). #(\label{prg:diff_log:freez1:begin}#) #(\label{prg:diff_log:freez1:end}#)
&diff{0 - O} <= -T :- start(O,T,w - 1). #(\label{prg:diff_log:freez2:begin}#) #(\label{prg:diff_log:freez2:end}#)

&diff{0 - (J,1)} <=  0 :- window(J,1,w). #(\label{prg:diff_log:non_nega:begin}#) #(\label{prg:diff_log:non_nega:end}#)
&diff{O1 - O2}   <= -P :- order(O1,O2,P,w). #(\label{prg:diff_log:oper_const:begin}#)

&diff{(J,S) - makespan} <= -P :- operation(J,S,M,P), window(J,S,w), #(\label{prg:diff_log:oper_limit:begin}#)
                                 not window(J,S + 1,w). #(\label{prg:diff_log:oper_limit:end}#)

#program optimize(m). #(\label{prg:diff_log:oper_min}#)
#external horizon(m).                                           #(\label{prg:diff_log:oper_min:begin}#)

&diff{makespan - 0} <= m :- horizon(m).                     #(\label{prg:diff_log:oper_min:end}#)