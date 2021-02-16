# Job-shop Scheduling using ASP

## Overview 
This project aims to solve Job-shop Scheduling Problem (JSP) using Answer Set Programming (ASP).

We developed two ways to solve the JSP:- \
The first one is to solve the problem with single shot. \
The second one is to solve the problem using Multi-shot. \
For the Multi-shot solving, we aimed to decompose the problem into sub-problems and solve them sequentially. To do that, we applied a decomposition strategy based on Earliest Starting Time to split the problem into Time Windows and get the best number of Time Windows to obtain good solutions in a resonable time.

We tested our Model on Taillard benchmark instances [Taillard’s instances](http://mistic.heig-vd.ch/taillard/problemes.dir/ordonnancement.dir/ordonnancement.html)


## Project Structure

    .
    ├── \Instances                                  # Directory with the benchmark instances 
    │   ├── Multi-shot                              # Directory in which the instances are splitted into different Time Windows from 1 - 10 (based on Earliest Starting Time Strategy)
    │   └── Single-shot                             # Directory with the instances without splitting 
    │
    ├── \JSP Encoding                               # Directory with the encoding files using ASP (Clingo, Clingo-Dl)
    │   ├── \Multi-shot                             # Directory with logic program codes to solve JSP
    |        |── JSP.lp                             # Scheduling encoding
    │        ├── JSP_TW_Overlapping.lp              # Scheduling encoding with Overlapping between Time Windows
    │        └── dlO_Timeout_Solve_Call.py          # Python api with timeout for each solve call
    |        └── dlO_Timeout_Whole_Time_Window.py   # Python api with timeout for each Time Window
    │   ├── \Single-shot              
    |        |── JSP.lp                             # Scheduling encoding with Single-shot 
    │   └── \Strategies to create Time windows      # Directory with different strategies to decompose the problem into Time Windows
    |
    │
    └── README.md


## Prerequisites

* [Python3](https://www.python.org/downloads/)
* [Clingo](https://potassco.org/clingo/) 
* [Clingo-Dl](https://potassco.org/labs/clingodl/) 

## Usage
* python .\JSP Encoding\Multi-shot\dlO_Timeout_Solve_Call.py  .\JSP Encoding\Multi-shot\JSP.lp .\Instances\Multi-shot\03 Time Windows\100 X 20\TA71.lp 
* python .\JSP Encoding\Multi-shot\dlO_Timeout_Solve_Call.py  .\JSP Encoding\Multi-shot\JSP_TW_Overlapping.lp .\Instances\Multi-shot\03 Time Windows\100 X 20\TA71.lp 
* clingo-dl .\JSP Encoding\Single-shot\JSP.lp .\Instances\Single shot\100 X 20\TA71.lp --minimize-variable=bound