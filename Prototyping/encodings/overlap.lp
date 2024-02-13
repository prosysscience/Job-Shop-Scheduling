#program previous(window).

% candidate operations for overlap into current window

previous(O,S,window)           :- start(O,S,window-1), assign(O,window-1).
previous(O,S,window)           :- start(O,S,window-1), overlap(O,window-1).
previous((-I,-J),-S,-P,window) :- previous((I,J),S,window),
                                  assignment((I,J),M,P),
                                  latest(M,T,window-1), T <= S,
                                  overlap_size(K).

#program overlap(window).

% determine the operations to take as overlap into current window

overlap(O,window) :- pre_sort(O,N,window), overlap_now(window,N).

% determine occupation of machines by scheduled (non-overlapping) operations

compressed(O,S,window-1) :- ready(O,S,window-1), compress,
                            start(O,S',window-1), S' < S.

scheduled(O,S,window)     :- compressed(O,S,window-1).
scheduled(O,S,window)     :- previous(O,S,window),
                             pre_sort(O,N,window), overlap_out(window,N).
scheduled(O,S,window)     :- previous(O,S,window), overlap_none.
scheduled(O,M,P,S,window) :- scheduled(O,S,window), assignment(O,M,P).
scheduled(O,M,P,S)        :- scheduled(O,M,P,S,window).
scheduled(O,window)       :- scheduled(O,S,window).

% output predicates

#show overlap/2.

%*
#show previous/3.
#show previous/4.
#show pre_sort/3.
#show scheduled/3.
#show scheduled/5.
#show scheduled/2.
*%
