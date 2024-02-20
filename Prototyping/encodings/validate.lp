% check that a schedule given in terms of start/2 or start/3 facts is feasible

start(O,S) :- start(O,S,W).

:- assignment(J,I,M,P), #count{S : start((I,J),S)} != 1.
:- start((I,J),S), #count{M,P : assignment(J,I,M,P)} != 1.

operation((I,J),M,P,S,S+P) :- assignment(J,I,M,P), start((I,J),S).

:- operation((I,J),M1,P1,S1,T1),
   operation((I+1,J),M2,P2,S2,T2), S2 < T1.
:- operation(O1,M,P1,S1,T1),
   operation(O2,M,P2,S2,T2), O1 != O2, S1 <= S2, S2 < T1.

% determine the makespan as optimization value

:~ N = #max{0; T : operation(O,M,P,S,T)}. [N]

% output predicates

#show start/2.
