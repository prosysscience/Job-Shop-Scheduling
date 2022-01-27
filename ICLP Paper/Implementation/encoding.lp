#program step(w).

use(M,w,w) :- operation(J,S,M,P), window(J,S,w). 
use(M,W,w) :- use(M,W,w - 1), not window(J,S,w) : operation(J,S,M,P). 

share((J1,S1),(J2,S2),P1,P2,X,w) :- operation(J1,S1,M,P1), 
                                    operation(J2,S2,M,P2),
                                    window(J1,S1,W),
                                    window(J2,S2,w), (W,J1) < (w,J2),
                                    use(M,W,w - X), X = 0..1. 

order(O1,O2,P1,w)        :- share(O1,O2,P1,P2,1,w). 
order((J,S1),(J,S2),P,w) :- operation(J,S1,M,P), window(J,S2,w), 
                            S1 = S2 - 1. 

{order(O1,O2,P1,w)} :- share(O1,O2,P1,P2,0,w). 
 order(O2,O1,P2,w)  :- share(O1,O2,P1,P2,0,w), 
                       not order(O1,O2,P1,w).  

&diff{O - 0} <=  T :- start(O,T,w - 1). 
&diff{0 - O} <= -T :- start(O,T,w - 1). 

&diff{0 - (J,1)} <=  0 :- window(J,1,w). 
&diff{O1 - O2}   <= -P :- order(O1,O2,P,w). 

&diff{(J,S) - makespan} <= -P :- operation(J,S,M,P), window(J,S,w), 
                                 not window(J,S + 1,w). 

#program optimize(m). 
#external horizon(m).                                           

&diff{makespan - 0} <= m :- horizon(m).                     