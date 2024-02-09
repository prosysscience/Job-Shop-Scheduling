#program schedule(window).

% determine earliest start times w.r.t. the operations of a job and machines

current(O,window) :- assign(O,window).
current(O,window) :- overlap(O,window).

delay((1,J),0,-1,window)  :- current((1,J),window).
delay((I,J),P,S+P,window) :- current((I,J),window),
                             scheduled((I-1,J),M,P,S).
delay((I,J),P,T,window)   :- current((I,J),window),
                             ready((I-1,J),P,S,T,P1,T1,window).

ready(O,P,S,S+P,P1,T1,window) :- delay(O,P1,T1,window),
                                 assignment(O,M,P),
                                 latest(M,T,window),
                                 S = (T+T1+|T-T1|)/2.
ready(O,S,P1,T1,window)       :- ready(O,P,S,T,P1,T1,window),
                                 assign(O,window).
ready(O,S,window)             :- ready(O,S,P,T,window), T < S.

% order successive operations of a job

other((1,J),S,window) :- ready((1,J),S,window),
                         not windows(window).
other((I,J),S,window) :- ready((I,J),S,window),
                         scheduled((I-1,J),M,P,S1),
                         not windows(window).

order((I-1,J),P,(I,J),window) :- ready((I,J),S,P,S,window).
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

:- scheduled(O1,window), overlap(O2,window),
   guess(O1,P1,O2,P2,W), not order(O1,P1,O2,W).
:- scheduled(O1,window), overlap(O2,window),
   guess(O2,P2,O1,P1,W), not order(O1,P1,O2,W).

% constrain the start times of operations

patch((I2,J),S,window) :- order((I1,J),P,(I2,J),window-1),
                          start((I2,J),S,window-1), scheduled((I2,J),window),
                          start((I1,J),S1,window-1), S1+P < S.

% limit(O,M,1,window) :- ups_sort(O,M,1), current(O,window), not windows(window).
limit(O,M,N,window) :- ups_sort(O,M,N), current(O,window),
                       ups_sort(O1,M,N-1), unscheduled(O1,window+1).
limit(M,S+P,window) :- limit(O,M,N,window), start(O,S,0), assignment(O,P).

#external compressed(O,S,window) : ready(O,S,window), 0 < S,
                                   compress, not windows(window).
#external overlap(O,window+1) : current(O,window), overlap_size(K),
                                assignment(O,M,P), limit(O1,M,N,window). % , 1 < N.

&diff{O - 0} <= S :- scheduled(O,window), start(O,S,window-1).

&diff{0 - O} <= -S :- start(O,S,window-1), scheduled(O,window),
                      other(O,T,window-1), S != T.
&diff{0 - O} <= -S :- patch(O,S,window),
                      ready(O,T,window-1), S != T.
&diff{0 - O} <= -S :- patch(O,S,window),
                      ready(O,T,P,T,window-1).

&diff{0 - O} <= -S :- ready(O,S,window), not compressed(O,S,window).

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
#show delay/4.
#show ready/7.
#show ready/5.
#show ready/3.
#show other/3.
#show guess/5.
#show order/4.
#show patch/3.
#show limit/4.
#show limit/3.
#show achieve/1.
*%
