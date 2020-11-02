The reorganized logic program files include the following:

  * `input.lp`: General analysis of instance data and derivation of predicates for splitting operations into time windows
  * `CreatingTimeWindow(EST).lp`: Rules deriving a predicate `index/3` giving a total order of operations based on their earliest starting times
  * `CreatingTimeWindow(MTWR).lp`: Rules deriving a predicate `index/3` giving a total order of operations based on the (most) work remaining
  * `output-direct.lp`: Derivation of the predicate `assignToTimeWindow/3` splitting operations into time windows w.r.t. the order given by `index/3`
  * `output-machine.lp`: Derivation of the predicate `assignToTimeWindow/3` splitting operations into time windows w.r.t. the (highest) load of machines

The following example calls can be used to try the different splitting strategies:

  * `clingo ../Instances/instance01.lp CreatingTimeWindow\(EST\).lp output-direct.lp`
  * `clingo ../Instances/instance01.lp CreatingTimeWindow\(EST\).lp output-direct.lp --const numOfTimeWindows=5`
  * `clingo ../Instances/instance01.lp CreatingTimeWindow\(MTWR\).lp output-direct.lp`
  * `clingo ../Instances/instance01.lp CreatingTimeWindow\(MTWR\).lp output-direct.lp --const numOfTimeWindows=5`
  * `clingo ../Instances/instance01.lp CreatingTimeWindow\(EST\).lp output-machine.lp`
  * `clingo ../Instances/instance01.lp CreatingTimeWindow\(MTWR\).lp output-machine.lp --const numOfTimeWindows=5`
