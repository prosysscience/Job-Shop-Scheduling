#program previous(window).

% candidate operations for overlap into current window

consider(O,S,P,T,window) :- start(O,S,window-1),
                            ready(O,P,T',T,window-1).

previous(O,S,P,T,window) :- consider(O,S,P,T,window),
                            overlap_size(K).

previous((-I,-J),-S,-P,window) :- previous((I,J),S,P,T,window), T <= S,
                                  last((I,J)).
previous((-I,-J),-S,-P,window) :- previous((I,J),S,P,T,window), T <= S,
                                  unscheduled((I+1,J),window).
previous((-I,-J),-S,-P,window) :- previous((I,J),S,P,T,window), T <= S,
                                  previous((-I-1,-J),S',P',window).

#program overlap(window).

% determine the operations to take as overlap into current window

overlap(O,window) :- pre_sort(O,N,window), overlap_now(window,N).

% determine occupation of machines by scheduled (non-overlapping) operations

scheduled(O,S,window)     :- previous(O,S,P,T,window),
                             ready(O,window-1), S < T.
scheduled((I,J),S,window) :- previous((I,J),S,P,T,window), compress,
                             scheduled((I+1,J),S',window).
scheduled((I,J),S,window) :- previous((-I,-J),-S,-P,window),
                             pre_sort((I,J),N,window), overlap_out(window,N).
scheduled(O,S,window)     :- consider(O,S,P,T,window), overlap_none.
scheduled(O,M,P,S,window) :- scheduled(O,S,window), assignment(O,M,P).
scheduled(O,M,P,S)        :- scheduled(O,M,P,S,window).
% scheduled(O,window)       :- scheduled(O,S,window).

compressed(O,window) :- consider(O,S,P,T,window),
                        ready(O,window-1), S < T.

% output predicates

#show overlap/2.

%*
#show consider/5.
#show previous/5.
#show previous/4.
#show pre_sort/3.
#show scheduled/3.
#show scheduled/5.
#show scheduled/4.
% #show scheduled/2.
#show compressed/2.
*%
