# The Multi-shot solving encoding for Job-shop Scheduling Problem (JSP)

This project applies a decomposition strategy to solve JSP based on Earliest Starting Time (EST). The encoding files in this directory denotes the implemntation of the proposed model

We tested our Model on Taillard benchmark instances [Taillard’s instances](http://mistic.heig-vd.ch/taillard/problemes.dir/ordonnancement.dir/ordonnancement.html)

The directory consists of following files: 

<table>
<tr><th>File/Folder name</th><th>File description</th></tr>
<tr><td>README.md</td><td>Text version of this file</td></tr>
<tr><td>instances</td><td>A folder has benchmark instances with three different sizes</td></tr>
<tr><td>facts.lp</td><td>Input file of a small example</td></tr>
<tr><td>decomposition.lp</td><td>A decomposition encoding based on EST</td></tr>
<tr><td>TW.lp</td><td>assignment of operations to time windows</td></tr>
<tr><td>encoding.lp</td><td>A Scheduler (Multi-shot solving)</td></tr>
<tr><td>dlO.py</td><td>Python api to control Multi-shot solving</td></tr>
</table>


## Prerequisites

* [Python3](https://www.python.org/downloads/)
* [Clingo](https://potassco.org/clingo/)
* [Clingo-Dl](https://potassco.org/labs/clingodl/)

## Usage
* clingo decomposition.lp instances/50 X 15/TA51.lp (for assigning to time windows) \

* python dlO.py encoding.lp instances/50 X 15/TA51.lp (for optimizing an instance of 50 jobs and 15 machines)