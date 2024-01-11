start((1,1),0,0) :- not est.
start((1,2),0,0) :- not est.
start((1,3),0,0) :- not est.
start((2,1),4,0) :- not est.
start((2,2),4,0) :- not est.
start((2,3),10,0) :- not est.
start((3,1),12,0) :- not est.
start((3,2),10,0) :- not est.
start((3,3),13,0) :- not est.

start(O,S,1) :- start(O,S,0).

start((1,1),0,1) :- est, not mtwr.
start((1,2),0,1) :- est, not mtwr.
start((1,3),0,1) :- est, not mtwr.
start((2,1),4,1) :- est, not mtwr.
start((2,2),4,1) :- est, not mtwr.

start((1,2),0,1)  :- mtwr.
start((1,3),0,1)  :- mtwr.
start((2,2),12,1) :- mtwr.
start((2,3),9,1)  :- mtwr.
start((3,3),12,1) :- mtwr.

start(O,S,2) :- start(O,S,1).

start((2,3),10,2) :- est, not mtwr.
start((3,1),12,2) :- est, not mtwr.
start((3,2),10,2) :- est, not mtwr.
start((3,3),13,2) :- est, not mtwr.

start((1,1),18,2) :- mtwr.
start((2,1),21,2) :- mtwr.
start((3,1),24,2) :- mtwr.
start((3,2),18,2) :- mtwr.
