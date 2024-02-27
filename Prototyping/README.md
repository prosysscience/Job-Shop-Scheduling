# JSSP Solving by Time Window Decomposition

This folder contains a prototype implementation for the Job-Shop Scheduling Problem (JSSP) with the goal to integrate diverse time window decomposition strategies. Beyond the built-in options of [clingo-dl](https://potassco.org/labs/clingoDL/), the [`main.py`](./main.py) script, which uses the [clingo-dl](https://potassco.org/labs/clingoDL/) encodings in the [encodings subfolder](./encodings/), can be configured by the following command-line options:

* `--timeout=LIMIT` : Set the overall time limit for a run to `LIMIT` seconds. This time budget will be evenly divided between time windows. The default value `LIMIT=0` means that the time for solving each time window and the overall run is unlimited.

* `--dynamic` : Determine the operations to schedule in each time window dynamically w.r.t. the partial schedule for operations of previous time windows. By default, the operations are statically partitioned into time windows.

* `--const windows=N` : Set the number of time windows into which the operations of a JSP instance will be partitioned to `N`. The default value `N=1` means that all operations belong to a single time window.

* `--const ordering=N` : Select the time window decomposition strategy. The default value `N=1` stands for an operation ordering by earliest start times, `N=2` according to the most total work remaining strategy, and `N=0` as well as `N<0` or `N>2` for operation ordering based on the `START` times in an initial schedule given by facts of the form `start((OPERATION,JOB),START,0)`. Then, the first portion of `|operations|/|windows|` many operations according to the selected ordering will be scheduled in the first time window, the second portion in the second time window, and so on.

  * If `N<0` or `N>2` is used for operation ordering based on an initial schedule, the given `START` times are also exploited to constrain operations' completion times machine-wise to the latest completion time according to the initial schedule of any operation in the current time window. For instance, when the initial schedule is such that the latest operation of those processed by a machine `1` in the first time window is completed at time `23`, all operations processed by machine `1` must also be completed at time `23` upon scheduling the first time window. The functionality to constrain the completion times of operations based on the initial schedule is applied unless the constant `bottleneck` (described below) is set to the value `1`, while the operation ordering otherwise works similar to `N=0`, i.e., without constraining operations' completion times machine-wise.

* `--const bottleneck=N` : The value `N=1` means that the operation ordering according to a selected time window decomposition strategy will be revised based on bottleneck machines with the highest sum of processing times for yet unscheduled operations. For instance, if an operation processed by a machine `1` is first in the ordering, yet machine `2` has a higher sum of processing times for its operations, an operation processed by machine `2` (selected according to the operation ordering) overtakes the operation processed by machine `1`. This propagates further to predecessor operations in the job of a selected operation, which will also be scheduled in the same (or an earlier) time window as the operation selected for a bottleneck machine. That is, the machine-wise sums of processing times for yet unscheduled operations revise the original operation ordering if `N=1`, while any other value, including the default value `N=0`, leave the operation ordering unchanged.

* `--const compress=N` : The default value `N=1` means that the best partial schedule computed per time window is refined by moving operations to earlier idle slots on the machines processing them. For instance, when the predecessor operation in the same job is completed at time `23` and the machine processing an operation is idle from time `21` to `30`, the start time of an operation with processing time `5` can be changed from `40` to `23` and thus take advantage of the idle slot on its machine. This compression approach is greedy and checks the possibility to move operations, scheduled in the current time window, in the order of their start times. The compression is deactivated by setting `N` to any value other than `1`.

* `--const factor=N` : Set the factor for the ratio of operations to take as overlap from the previous into the current time window. Overlapping operations are determined based on their start times, beginning with those started latest, and can be rescheduled together with the operations in the current time window. The default value `N=0` means that there are no overlapping operations.

* `--const divisor=N` : Set the denominator for the ratio of operations to take as overlap from the previous into the current time window. For instance, combining the default value `N=10` with a `factor` of `1` means that 10% of `|operations|/|windows|` many operations to be scheduled will be taken as overlap per time window.

__NOTE :__ The Answer Set Programming (ASP) encoding part for revising the operation ordering of a time window decomposition strategy by bottleneck machines is grounding-intensive, which creates memory stress for large JSSP instances with thousands of operations. Similarly, the ASP encoding for compression, which is activated by default, can be prohibitively grounding-intensive for large JSSP instances. Hence, the option `--const bottleneck=1` should be considered with care, and `--const compress=0` may be needed to keep the memory usage under control. Switching to procedural instead of ASP implementations of the revised operation ordering based on bottleneck machines and of the compression approach would resolve these issues, but they have not yet been implemented in the [`main.py`](./main.py) script.

## Usage Examples

Example calls like the following allow for JSSP solving by [clingo-dl](https://potassco.org/labs/clingoDL/) with different time window decomposition strategies:

* Scheduling all operations in a single time window:

  > `python3 main.py scratch/instance.lp --warn=none`

* Partitioning operations into `4` time windows (based on earliest start times):

  > `python3 main.py scratch/instance.lp --warn=none --const windows=4`

* Partitioning operations into `4` time windows (based on earliest start times) dynamically w.r.t. the best partial schedule for the previous time window:

  > `python3 main.py scratch/instance.lp --warn=none --const windows=4 --dynamic`

* Partitioning operations into `3` time windows based on earliest start times:

  > `python3 main.py scratch/instance.lp --warn=none --const windows=3`

* Partitioning operations into `3` time windows based on the most total work remaining strategy:

  > `python3 main.py scratch/instance.lp --warn=none --const windows=3 --const ordering=2`

* Partitioning operations into `3` time windows based on the most total work remaining strategy with deactivated compression:

  > `python3 main.py scratch/instance.lp --warn=none --const windows=3 --const ordering=2 --const compress=0`

* Partitioning operations into `3` time windows based on an initial schedule with deactivated compression:

  > `python3 main.py scratch/instance.lp scratch/initial1.lp --warn=none --const windows=3 --const ordering=0 --const compress=0`

* Partitioning operations into `3` time windows based on an initial schedule revised by bottleneck machines with deactivated compression:

  > `python3 main.py scratch/instance.lp scratch/initial1.lp --warn=none --const windows=3 --const ordering=0 --const bottleneck=1 --const compress=0`

* Partitioning operations into `2` time windows based on an initial schedule:

  > `python3 main.py scratch/instance.lp scratch/initial2.lp --warn=none --const windows=2 --const ordering=0`

* Partitioning operations into `2` time windows based on an initial schedule with machine-wise constraints on the completion times of operations in the current time window:

  > `python3 main.py scratch/instance.lp scratch/initial2.lp --warn=none --const windows=2 --const ordering=3`

* Partitioning operations into `3` time windows (based on earliest start times)
  with `⌈1/10⌉` ratio of operations from the previous time window taken as overlap:

  > `python3 main.py scratch/instance.lp --warn=none --const windows=3 --const factor=1`

* Partitioning operations into `3` time windows (based on earliest start times)
  with `⌈1/2⌉` ratio of operations from the previous time window taken as overlap:

  > `python3 main.py scratch/instance.lp --warn=none --const windows=3 --const divisor=2`

* Partitioning operations into `3` time windows (based on earliest start times)
  with `⌈2/5⌉` ratio of operations from the previous time window taken as overlap:

  > `python3 main.py scratch/instance.lp --warn=none --const windows=3 --const factor=2 --const divisor=5`

## Schedule Validation

The auxiliary ASP encoding [`validate.lp`](./encodings/validate.lp) can be used to check an initial or computed schedule with [clingo](https://potassco.org/clingo/) (where the outcome `UNSATISFIABLE` indicates that the schedule is infeasible) by means of calls like the following:

  > `clingo encodings/validate.lp scratch/instance.lp scratch/initial1.lp`

  > `clingo encodings/validate.lp scratch/instance.lp scratch/initial2.lp`

  > `python3 main.py scratch/instance.lp --warn=none --const windows=3 | grep -A1 -e "^Schedule:$" | tail -n1 | clingo encodings/validate.lp scratch/instance.lp -`
