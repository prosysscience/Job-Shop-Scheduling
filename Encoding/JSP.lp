
job 	 (JobNum) 			:- operation (JobNum, StepNum).
step 	 (StepNum) 			:- operation (JobNum, StepNum).
machine  (MachNum) 			:- assignment(JobNum, StepNum, MachNum, ProTime).
operation(JobNum, StepNum) 	:- assignment(JobNum, StepNum, MachNum, ProTime).


% ************************************************************ To Get The Maximum Horizon ************************************************************
maxTime1 (TotalTime) 		:- TotalTime = #sum {ProTime, JobNum, StepNum, MachNum : assignment(JobNum, StepNum, MachNum, ProTime)}.
% ************************************************************ To Get The Maximum Horizon ************************************************************

% *********************************************** To define each operation is assigned to which a machine ********************************************
{assign(JobNum, StepNum, MachNum) : assignment(JobNum, StepNum, MachNum, ProTime)} = 1 :- operation(JobNum, StepNum).
% *********************************************** To define each operation is assigned to which a machine ********************************************

% ************************************************* To define the processing time for each operation *************************************************
proTime(JobNum, StepNum, ProTime) 			   :- assign(JobNum, StepNum, MachNum), assignment(JobNum, StepNum, MachNum, ProTime).
% ************************************************* To define the processing time for each operation *************************************************

% ***************************************** To Detect Which Operations are performed with the Same Machine *******************************************
sameMach(JobNum1, StepNum1, JobNum2, StepNum2) :- assign(JobNum1, StepNum1, MachNum),
                                                  assign(JobNum2, StepNum2, MachNum),
                                                  JobNum1 < JobNum2.
% ***************************************** To Detect Which Operations are performed with the Same Machine *******************************************

% *************** To Make the order which operation should be performed first, if I have Operations should be performed on the same machine **********
{seq((JobNum1, StepNum1), (JobNum2, StepNum2), ProTime1)} :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2), proTime(JobNum1, StepNum1, ProTime1),
															 proTime (JobNum2, StepNum2, ProTime2).

 seq((JobNum2, StepNum2), (JobNum1, StepNum1), ProTime2)  :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2), proTime(JobNum2, StepNum2, ProTime2), 
 															 proTime (JobNum1, StepNum1, ProTime1),
 															 not seq((JobNum1, StepNum1), (JobNum2, StepNum2), ProTime1).
% ************* To Make the order which operation should be performed first, if I have Operations should be performed on the same machine ************

% ************************************** To Determine the logical dependency for all operations in the same Job **************************************
 seq((JobNum1, StepNum1), (JobNum1, StepNum2), ProTime1)  :- proTime(JobNum1, StepNum1, ProTime1), proTime(JobNum1, StepNum2, ProTime2),
 															 StepNum2 = StepNum1 + 1. % StepNum1 < StepNum2.
% ************************************** To Determine the logical dependency for all operations in the same Job **************************************

% **************** To Determine the Lower bound for the First Operations in All Jobs & the Upper bound for the Operations in all Jobs ****************
&diff{  0 - (JobNum, StepNum)  } 	<= 0 		  	:- operation(JobNum, StepNum), StepNum = 1.

&diff{  (JobNum, StepNum) - 0  } 	<= TotalTime 	:- operation(JobNum, StepNum), maxTime1(TotalTime).
% **************** To Determine the Lower bound for the First Operations in All Jobs & the Upper bound for the Operations in all Jobs ****************

&diff{ Operation1 - Operation2 } 	<= -ProTime1 	:- seq(Operation1, Operation2, ProTime1).

% ****************************************************** To minimize the total Completion Time *******************************************************
&diff{(JobNum, StepNum) - bound} 	<= -ProTime 	:- operation(JobNum, StepNum), proTime(JobNum, StepNum, ProTime).
% ****************************************************** To minimize the total Completion Time *******************************************************

% &minimize{ bound }.

 &show_assignment{}.
 #show.