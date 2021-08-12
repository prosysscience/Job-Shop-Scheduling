#const compress = 0.

start_window(W) :- startTime(JO,S,W).

compress_window(compress) :- compress != 0.
compress_window(W)        :- compress = 0, start_window(W), not start_window(W+1).

compress_operation(J,O,W) :- assignToTimeWindow(J,O,W),
                             compress_window(W).
compress_operation(J,O,W) :- overlappedOperation(J,O,W),
                             compress_window(W).

compress_operation(J,O,S,M,T) :- compress_operation(J,O,W),
                                 startTime((J,O),S,W),
                                 assignment(J,O,M,T).

order(J,O,S,M,T,I) :- compress_operation(J,O,S,M,T),
                      I = #count{J1,O1 : compress_operation(J1,O1,S1,M1,T1),
                                         (S1,J1) < (S,J)}.
order(I)           :- order(J,O,S,M,T,I).

fix_startTime(J,O,S,S+T,M) :- startTime((J,O),S,W),
                              assignment(J,O,M,T),
                              compress_window(W),
                              not compress_operation(J,O,W).

machine(M) :- assignment(J,O,M,T).

fix_endTime(M,0) :- machine(M).
fix_endTime(M,E) :- fix_startTime(J,O,S,E,M).

max_endTime(M,E2,0) :- machine(M), E2 = #max{E : fix_endTime(M,E)}.
max_endTime(M,E2,I) :- max_endTime(M,E2,I-1),
                       order(J,O,S,M1,T,I-1), M1 != M,
                       order(I).
max_endTime(M,E2,I) :- max_endTime(M,E1,I-1),
                       order(J,O,S,M,T,I-1),
                       order(I),
                       new_startTime(J,O,S1,E,M),
                       E2 = (E + E1 + |E - E1|)/2.

order_endTime(M,E1,E2,0) :- fix_endTime(M,E2), 0 < E2,
                            E1 = #max{E : fix_endTime(M,E), E < E2}.
order_endTime(M,E1,E2,I) :- order_endTime(M,E1,E2,I-1),
                            order(J,O,S,M1,T,I-1), M1 != M,
                            order(I).
order_endTime(M,E1,E2,I) :- order_endTime(M,E1,E2,I-1),
                            order(J,O,S,M,T,I-1),
                            order(I),
                            new_startTime(J,O,S1,E,M), E < E1.
order_endTime(M,E1,E2,I) :- order_endTime(M,E1,E2,I-1),
                            order(J,O,S,M,T,I-1),
                            order(I),
                            new_startTime(J,O,S1,E,M), E2 < E.
order_endTime(M,E1,E,I)  :- order_endTime(M,E1,E2,I-1),
                            order(J,O,S,M,T,I-1),
                            order(I),
                            new_startTime(J,O,S1,E,M), E1 < E, E < E2.
order_endTime(M,E,E2,I)  :- order_endTime(M,E1,E2,I-1),
                            order(J,O,S,M,T,I-1),
                            order(I),
                            new_startTime(J,O,S1,E,M), E1 < E, E < E2.
order_endTime(M,E1,E2,I) :- max_endTime(M,E1,I-1), max_endTime(M,E2,I), E1 < E2.

inspect_endTime(J,O,M,T,0,I)  :- order(J,O,S,M,T,I).
inspect_endTime(J,O,M,T,E2,I) :- inspect_endTime(J,O,M,T,E1,I),
                                 order_endTime(M,E1,E2,I),
                                 lower_bound(J,O,E0),
                                 new_startTime(J2,O2,S2,E2,M),
                                 S = (E0 + E1 + |E0 - E1|)/2,
                                 S2 < S + T.

lower_bound(J,1,0) :- compress_operation(J,1,W).
lower_bound(J,O,E) :- compress_operation(J,O,W),
                      new_startTime(J,O-1,S,E,M).

new_startTime(J,O,S,E,M) :- fix_startTime(J,O,S,E,M).
new_startTime(J,O,S,E,M) :- inspect_endTime(J,O,M,T,E1,I),
                            order_endTime(M,E1,E2,I),
                            lower_bound(J,O,E0),
                            new_startTime(J2,O2,S2,E2,M),
                            S = (E0 + E1 + |E0 - E1|)/2,
                            E = S + T,
                            E <= S2.
new_startTime(J,O,S,E,M) :- inspect_endTime(J,O,M,T,E1,I),
                            max_endTime(M,E1,I),
                            lower_bound(J,O,E0),
                            S = (E0 + E1 + |E0 - E1|)/2,
                            E = S + T.

% output(J,O,S,E,20) :- fix_startTime(J,O,S,E,20).

#show overlappedOperation/3.
#show startTime((J,O),S,W) : new_startTime(J,O,S,E,M), compress_window(W).

%#show. 
