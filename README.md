# Job-shop Scheduling using ASP

## Overview 
This project aims to solve Job-shop Scheduling Problem (JSP) using Answer Set Programming (ASP).

We developed two ways to solve the JSP:- \
The first one is to solve the problem with single shot. \
The second one is to solve the problem using Multi-shot. \
For the Multi-shot solving, we aimed to decompose the problem into sub-problems and solve them sequentially. To do that, we applied a decomposition strategy based on four different strategies to split the problem into Time Windows and get the best number of Time Windows to obtain good solutions in a resonable time. For the decomposition, two different splitting approaches are applied (Static and Dynamic). \
Static decomposition aims to assign the operations into Time Windows before starting the scheduling. \
Dynamic decomposition depends on assigning only the operations that will be scheduled into the next Time Window. \

We tested our Model on Taillard benchmark instances [Taillard’s instances](http://mistic.heig-vd.ch/taillard/problemes.dir/ordonnancement.dir/ordonnancement.html)


## Project Structure

    .
    ├── \Instances                                  # Directory with the benchmark instances 
    │   ├── \Multi-shot                             # Directory contains the instances are splitted into different Time Windows (1 - 10)
    │        ├── \Static_assignment_operations      # 
    │            |── \EST_time-based                # The operations are assigned to Time Windows based on Earliest Starting Time(EST)
    │                |── \02 Time windows               # The instances are splitted into two Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    └── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                |── \: 
    │                |── \:
    │                └── \10 Time windows               # The instances are splitted into ten Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    |── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                    └── \100 X 20                      # A set of instances with 100 jobs and 20 machines
    │
    │            |── \EST_machine-based             # The operations are assigned to Time Windows based on (EST) considering bottleneck machines
    │                |── \02 Time windows               # The instances are splitted into two Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    └── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                |── \: 
    │                |── \:
    │                └── \10 Time windows               # The instances are splitted into ten Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    |── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                    └── \100 X 20                      # A set of instances with 100 jobs and 20 machines
    │
    │            |── \MTWR_time-based               # The operations are assigned to Time Windows based on Most Total Work Remaining (MTWR)
    │                |── \02 Time windows               # The instances are splitted into two Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    └── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                |── \: 
    │                |── \:
    │                └── \10 Time windows               # The instances are splitted into ten Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    |── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                    └── \100 X 20                      # A set of instances with 100 jobs and 20 machines
    │
    │            └── \MTWR_machine-based            # The operations are assigned to Time Windows based on (MTWR) based on bottleneck machines 
    │                |── \02 Time windows               # The instances are splitted into two Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    └── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                |── \: 
    │                |── \:
    │                └── \10 Time windows               # The instances are splitted into ten Time Windows
    │                    |── \50 X 15                       # A set of instances with 50 jobs and 15 machines
    │                    |── \50 X 20                       # A set of instances with 50 jobs and 20 machines
    │                    └── \100 X 20                      # A set of instances with 100 jobs and 20 machines
    │        └── \Dynamic_assignment_operations      # the operations of the instances will be assigned to Time Windows during the optimization process
    │            |── \50 X 15                               # A set of instances with 50 jobs and 15 machines
    │            |── \50 X 20                               # A set of instances with 50 jobs and 20 machines
    │            └── \100 X 20                              # A set of instances with 100 jobs and 20 machines
    │   └── \Single-shot                            # Directory with the instances without splitting
    │       |── \06 X 06                                    # A set of instances with 06 jobs and 06 machines
    │       |── \:                                          
    │       |── \:
    │       └── \100 X 20                                   # A set of instances with 100 jobs and 20 machines
    │
    ├── \JSP Encoding                               # Directory with the encoding files using ASP (Clingo, Clingo-Dl)
    │   ├── \Multi-shot                             # Directory with logic program codes to solve JSP
    |        |── \Dynamic_assignment
    |             |── dlO_Timeout_Whole_Time_Window.py      # Python api with timeout for each Time Window
    |             |── dynamic-est.lp                        # encoding to assign the operations based on (EST)
    |             |── dynamic-mtwr.lp                       # encoding to assign the operations based on (MTWR)
    |             |── input.lp
    |             |── output-direct.lp                      # encoding to assign the operations withtout considering bottleneck machines
    |             └── output-machine.lp                     # encoding to assign the operations with bottleneck machines
    |        |── \Static_assignment
    |             |── dlO_Timeout_Whole_Time_Window.py      # Python api with timeout for each Time Window
    |             └── dlO_Timeout_Solve_Call.py             # Python api with timeout for each solve call
    |        |── \ASP_scheduler
    |            |── JSP.lp                             # Scheduling encoding
    │            └── JSP_TW_Overlapping.lp              # Scheduling encoding with Overlapping between Time Windows
    │   └── \Single-shot              
    |        |── JSP.lp                             # Scheduling encoding with Single-shot 
    ├── \Strategies to create Time windows      # Directory with different strategies to decompose the problem into Time Windows
    |
    │
    └── README.md


## Prerequisites

* [Python3](https://www.python.org/downloads/)
* [Clingo](https://potassco.org/clingo/)
* [Clingo-Dl](https://potassco.org/labs/clingodl/)

## Usage
* python .\JSP Encoding\Multi-shot\Static_assignment\dlO_Timeout_Solve_Call.py  .\JSP Encoding\Multi-shot\ASP_scheduler\JSP.lp .\Instances\Multi-shot\Static_assignment_operations\EST_time-based\03 Time Windows\100 X 20\TA71.lp \

* python .\JSP Encoding\Multi-shot\Static_assignment\dlO_Timeout_Whole_Time_Window  .\JSP Encoding\Multi-shot\ASP_scheduler\JSP.lp .\Instances\Multi-shot\Static_assignment_operations\MTWR_machine-based\03 Time Windows\50 X 20\TA61.lp \

* python .\JSP Encoding\Multi-shot\Static_assignment\dlO_Timeout_Whole_Time_Window  .\JSP Encoding\Multi-shot\ASP_scheduler\JSP_TW_Overlapping.lp .\Instances\Multi-shot\Static_assignment_operations\EST_machine-based\03 Time Windows\50 X 15\TA51.lp \

* python .\JSP Encoding\Multi-shot\Dynamic_assignment\dlO_Timeout_Whole_Time_Window  .\JSP Encoding\Multi-shot\ASP_scheduler\JSP.lp .\Instances\Multi-shot\Dynamic_assignment_operations\50 X 15\TA51.lp \

* clingo-dl .\JSP Encoding\Single-shot\JSP.lp .\Instances\Single shot\15 X 15\TA01.lp --minimize-variable=bound