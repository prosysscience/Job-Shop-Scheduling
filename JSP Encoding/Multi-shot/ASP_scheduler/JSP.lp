#program base.

job 	 (JobNum) 			:- operation (JobNum, StepNum).
step 	 (StepNum) 			:- operation (JobNum, StepNum).
machine  (MachNum) 			:- assignment(JobNum, StepNum, MachNum, ProTime).
operation(JobNum, StepNum) 	:- assignment(JobNum, StepNum, MachNum, ProTime).


% *********************************************** To define each operation is assigned to which a machine ********************************************
{assign(JobNum, StepNum, MachNum) : assignment(JobNum, StepNum, MachNum, ProTime)} = 1 :- operation(JobNum, StepNum).
% *********************************************** To define each operation is assigned to which a machine ********************************************

% ************************************************* To define the processing time for each operation *************************************************
proTime(JobNum, StepNum, ProTime) 			   :- assign(JobNum, StepNum, MachNum), assignment(JobNum, StepNum, MachNum, ProTime).
% ************************************************* To define the processing time for each operation *************************************************

% ************************************** To Determine the logical dependency for all operations in the same Job **************************************
 seqL((JobNum1, StepNum1), (JobNum1, StepNum2), ProTime1)  :- proTime(JobNum1, StepNum1, ProTime1), proTime(JobNum1, StepNum2, ProTime2),
 															  StepNum2 = StepNum1 + 1.
% ************************************** To Determine the logical dependency for all operations in the same Job **************************************

% ************************************************************ To Get The Maximum Horizon ************************************************************
maxTime1 (TotalTime) 		:- TotalTime = #sum {ProTime, JobNum, StepNum, MachNum : assignment(JobNum, StepNum, MachNum, ProTime)}.
% ************************************************************ To Get The Maximum Horizon ************************************************************

% ***************************************** To Detect Which Operations are performed with the Same Machine *******************************************
sameMach(JobNum1, StepNum1, JobNum2, StepNum2) :- assign(JobNum1, StepNum1, MachNum),
                                                  assign(JobNum2, StepNum2, MachNum),
                                                  JobNum1 < JobNum2.
% ***************************************** To Detect Which Operations are performed with the Same Machine *******************************************

#program subproblem(t).
% *************** To Make the order which operation should be performed first, if I have Operations should be performed on the same machine **********
{seqM((JobNum1, StepNum1), (JobNum2, StepNum2), ProTime1)} :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2), proTime(JobNum1, StepNum1, ProTime1),
															  assignToTimeWindow(JobNum1, StepNum1, t),       proTime(JobNum2, StepNum2, ProTime2),
                                                  			  assignToTimeWindow(JobNum2, StepNum2, t).

 seqM((JobNum2, StepNum2), (JobNum1, StepNum1), ProTime2)  :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2), proTime(JobNum2, StepNum2, ProTime2), 
 															  assignToTimeWindow(JobNum1, StepNum1, t),       proTime(JobNum1, StepNum1, ProTime1),
                                                  			  assignToTimeWindow(JobNum2, StepNum2, t),
 															  not seqM((JobNum1, StepNum1), (JobNum2, StepNum2), ProTime1).
% ************* To Make the order which operation should be performed first, if I have Operations should be performed on the same machine ************

% *************************** To Make the order between two operations sharing same machine and in different Time Windows ****************************
 seqM((JobNum1, StepNum1), (JobNum2, StepNum2), ProTime1)  :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2), proTime(JobNum1, StepNum1, ProTime1),
															  assignToTimeWindow(JobNum1, StepNum1, t-1),     proTime(JobNum2, StepNum2, ProTime2),
                                                  			  assignToTimeWindow(JobNum2, StepNum2, t  ).

 seqM((JobNum2, StepNum2), (JobNum1, StepNum1), ProTime2)  :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2), proTime(JobNum1, StepNum1, ProTime1),
															  assignToTimeWindow(JobNum1, StepNum1, t  ),     proTime(JobNum2, StepNum2, ProTime2),
                                                  			  assignToTimeWindow(JobNum2, StepNum2, t-1).
% *************************** To Make the order between two operations sharing same machine and in different Time Windows ****************************

% **************** To Determine the Lower bound for the First Operations in All Jobs & the Upper bound for the Operations in all Jobs ****************
&diff{  0 - (JobNum, StepNum)  } 	<= 0 		  	:- operation(JobNum, StepNum),
													   assignToTimeWindow(JobNum, StepNum, t).

&diff{  (JobNum, StepNum) - 0  } 	<= TotalTime 	:- operation(JobNum, StepNum), maxTime1(TotalTime),
													   assignToTimeWindow(JobNum, StepNum, t).
% **************** To Determine the Lower bound for the First Operations in All Jobs & the Upper bound for the Operations in all Jobs ****************

% ************************************** To Assign the Starting Time based on the Logical and machines sequences *************************************
&diff{ Operation1 - Operation2 } 	<= -ProTime1 	:- seqM(Operation1, Operation2, ProTime1).

&diff{ Operation1 - Operation2 } 	<= -ProTime1 	:- seqL(Operation1, Operation2, ProTime1),
													   assignToTimeWindow(JobNum, StepNum1, t),   Operation1 = (JobNum, StepNum1),
													   assignToTimeWindow(JobNum, StepNum2, t),   Operation2 = (JobNum, StepNum2).

&diff{ Operation1 - Operation2 }	<= -ProTime1	:- seqL(Operation1, Operation2, ProTime1),
													   assignToTimeWindow(JobNum, StepNum1, t-1), Operation1 = (JobNum, StepNum1),
													   assignToTimeWindow(JobNum, StepNum2, t  ), Operation2 = (JobNum, StepNum2),
													   StepNum2 = StepNum1 + 1.
% ************************************** To Assign the Starting Time based on the Logical and machines sequences *************************************

% ****************************************************** To minimize the total Completion Time *******************************************************
&diff{(JobNum, StepNum) - bound} 	<= -ProTime 	:- operation(JobNum, StepNum), proTime(JobNum, StepNum, ProTime),
													   assignToTimeWindow(JobNum, StepNum, t).
% ****************************************************** To minimize the total Completion Time *******************************************************

&diff{  0 - (JobNum, StepNum)  } 	<= -StartTime 	:- startTime((JobNum, StepNum), StartTime), 
													   assignToTimeWindow(JobNum, StepNum, t-1).

&diff{  (JobNum, StepNum) - 0  } 	<=  StartTime 	:- startTime((JobNum, StepNum), StartTime), 
													   assignToTimeWindow(JobNum, StepNum, t-1).

#show maxTime1/1.

#program opt(b).
#external bound(b).
&diff{  bound		- 		  0} 	<= b :- bound(b).