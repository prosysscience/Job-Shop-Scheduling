#program schedule(window).

% determine earliest start times w.r.t. the operations of a job and machines

current(O,window) :- assign(O,window).
current(O,window) :- overlap(O,window).

ready((1,J),P,-1,T,T,F,window)  :- current((1,J),window),
                                   assignment((1,J),M,P),
                                   latest(M,T,window),
                                   F = (T+1-|T-1|)/2.
ready((I,J),P,-1,T1,T,F,window) :- current((I,J),window),
                                   assignment((I,J),M,P),
                                   latest(M,T1,window),
                                   scheduled((I-1,J),M',P',S), T2 = S+P',
                                   D = T1-T2, E = D+|D|,
                                   T = (T1+T2+|D|)/2,
                                   F = (E+1-|E-1|)/2.
ready((I,J),P,T2,T1,T,F,window) :- current((I,J),window),
                                   assignment((I,J),M,P),
                                   latest(M,T1,window),
                                   ready((I-1,J),P',T',S',S,F',window), T2 = S+P',
                                   D = T1-T2, E = D+|D|+F',
                                   T = (T1+T2+|D|)/2,
                                   F = (E+1-|E-1|)/2.

ready(O,S,F,window) :- ready(O,P,T,T',S,F,window), T < S,
                       assign(O,window).
ready(O,S,0,window) :- ready(O,P,T,T',S,F,window), T < S,
                       overlap(O,window).

ready(O,S,window) :- ready(O,S,F,window-1),
                     overlap(O,window).
ready(O,0,window) :- ready(O,P,T,T',T,F,window-1),
                     overlap(O,window),
                     assign(O,window-1).
ready(O,S,window) :- ready(O,P,T,T',T,F,window-1),
                     overlap(O,window),
                     ready(O,S,window-1).

% order successive operations of a job

order((I1,J),P,(I2,J),window) :- assignment((I1,J),P),
                                 current((I1,J),window),
                                 assign((I2,J),window), I2 = I1+1.

% guess order between operations sharing a machine

guess((I1,J1),P1,(I2,J2),P2,window) :- assignment((I1,J1),M,P1),
                                       assignment((I2,J2),M,P2), J1 < J2,
                                       assign((I1,J1),window),
                                       assign((I2,J2),window).
guess((I1,J1),P1,(I2,J2),P2,window) :- assignment((I1,J1),M,P1),
                                       assignment((I2,J2),M,P2), J1 != J2,
                                       assign((I1,J1),window),
                                       overlap((I2,J2),window).

{order(O1,P1,O2,window)} :- guess(O1,P1,O2,P2,window).
 order(O2,P2,O1,window)  :- guess(O1,P1,O2,P2,window),
                            not order(O1,P1,O2,window).

% fix order of overlapping operations
%*
:- scheduled(O1,window), overlap(O2,window),
   guess(O1,P1,O2,P2,W), not order(O1,P1,O2,W).
:- scheduled(O1,window), overlap(O2,window),
   guess(O2,P2,O1,P1,W), not order(O1,P1,O2,W).
*%
% constrain the start times of operations

limit(O,M,N,window) :- ups_sort(O,M,N), current(O,window),
                       ups_sort(O1,M,N-1), unscheduled(O1,window+1).
limit(M,S+P,window) :- limit(O,M,N,window), start(O,S,0), assignment(O,P).

#external compressed(O,S,window) : ready(O,S,1,window),
                                   compress, window(window+1).
#external overlap(O,window+1) : current(O,window), overlap_size(K),
                                assignment(O,M,P), limit(O1,M,N,window).

&diff{O - 0} <= S :- scheduled(O,S,window).

&diff{0 - O} <= -S :- scheduled(O,S,window),
                      ready(O,S',F,window-1), S != S'.
&diff{0 - O} <= -S :- scheduled(O,S,window),
                      ready(O,P,T,T',T,F,window-1),
                      assign(O,window-1).
&diff{0 - O} <= -S :- scheduled(O,S,window),
                      ready(O,P,T,T',T,F,window-1),
                      ready(O,S',window-1), S != S'.

&diff{0 - O} <= -S :- ready(O,S,F,window), assign(O,window),
                      not compressed(O,S,window).
&diff{0 - O} <= -S :- ready(O,S,0,window), ready(O,S',window), S' < S.

&diff{O1 - O2} <= -P :- order(O1,P,O2,window).

&diff{O - 0} <= L-P :- assignment(O,M,P), limit(M,L,window),
                       current(O,window), not overlap(O,window+1).

&diff{O - bound} <= -P     :- assignment(O,P), assign(O,window), last(O).
&diff{(I,J) - bound} <= -P :- assignment((I,J),P), assign((I,J),window),
                              unscheduled((I+1,J),window+1).

% constrain bound variable to minimize the makespan for time window(s)

#program optimize(window,makespan).

#external achieve(makespan) : not windows(window).

achieve(makespan) :- windows(window).

&diff{bound - 0} <= makespan :- achieve(makespan).

% output predicates

%*
#show current/2.
#show ready/7.
#show ready/4.
#show ready/3.
#show guess/5.
#show order/4.
#show limit/4.
#show limit/3.
#show achieve/1.
*%
