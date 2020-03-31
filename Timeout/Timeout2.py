import time
import subprocess
import os
import csv

path = "C:\\Users\\mohammed\\Downloads\\Research papers\\Benchmark problems"
os.chdir(path)
InputFolder	= "Groupped Benchmarks"
constant1 	= "clingo-dl JSPSaadClingoDL_V2.lp "
constant2 	= " --minimize-variable=bound"
constant3 	= " --time-limit="
TimeSec		= 15

filenames= os.listdir (InputFolder) # get all files' and folders' names in the current directory
counter=1
MainCounter=1
for foldername in filenames: # loop through all the files and folders
    if os.path.isdir(os.path.join(os.path.abspath(InputFolder), foldername)): # check whether the current object is a folder or not
        JobsAndMach = foldername.split("X")
        NumOfJobs	= int(JobsAndMach[0])
        NumOfMach	= int(JobsAndMach[1])
        if NumOfJobs >= 50:
        	continue
        else:
        	if NumOfJobs <= 10:
        		if NumOfMach < 10:
        			TimeSec = 10 * 60
        		else:
        			TimeSec = 15 * 60
        	else if NumOfJobs == 15:
        		if NumOfMach == 5:
        			TimeSec = 10 * 60
        		else if NumOfMach == 10:
        			TimeSec = 20 * 60
        		else if NumOfMach == 15:
        			TimeSec = 30 * 60
        	else if NumOfJobs == 20:
        		if NumOfMach == 5:
        			TimeSec = 15 * 60
        		else if NumOfMach == 10:
        			TimeSec = 150 * 60
        		else if NumOfMach == 15:
        			TimeSec = 210 * 60
        		else if NumOfMach == 20:
        			TimeSec = 300 * 60
        	else if NumOfJobs == 30:
        		if NumOfMach == 10:
        			TimeSec = 150 * 60
        		else if NumOfMach == 15:
        			TimeSec = 300 * 60
        		else if NumOfMach == 20:
        			TimeSec = 600 * 60
        			
        print("Started This Folder " + foldername)
        time.sleep(5)
        for instance in os.listdir(os.getcwd() + "\\" + InputFolder + "\\" + foldername):
        	instanceNameWithoutExe = instance.split('.')
        	instanceNameWithoutExe = instanceNameWithoutExe[0]
        	#print(instanceNameWithoutExe)
        	TotalCall	= constant1 + '"' + InputFolder + "\\" + foldername+ "\\" + instance + '"' + constant2 + constant3 + str(TimeSec)+" --stat" + " --q" + "> " + '"' + InputFolder + "\\" + foldername+ "\\"+"Results\\" +instanceNameWithoutExe + ".csv" + '"'
        	print("The next Instance is --> " + instance)
        	time.sleep(3)
        	os.system(TotalCall)
        	#print(TotalCall)

        	#break
        print("Finished This Folder " + foldername)
        print(counter)
        #break
        counter = counter + 1
        if counter > 2:
        	break

'''
        	# This section is used to get the statistics for one instance
        	with open(InputFolder + '\\' + foldername+ "\\"+"Results\\" +instanceNameWithoutExe + ".csv", 'r') as f:
        		lines		= f.read().splitlines()
        		if lines[-50] == 'UNSATISFIABLE':
        			last_lines	= lines[-50 : ]
        		else:
        			last_lines	= lines[-51 : ]

        		writer=csv.writer(open(InputFolder + '\\' + foldername+ "\\"+"Results\\" +instanceNameWithoutExe + ".csv",'wb'))
        		ActualData = []      	
        		for x in last_lines:
        			#print(x)
        			Record	= x.split(':')
        			#print(Record)
        			print(Record)
        			if len(Record) > 1:
        				ActualData.append(Record[1:])

        			#writer.writerow([Record[0]])
        			print('*******************')
        		print(ActualData)
        		# I have the data and I need to write them in csv file horrizontally
        		writer.writerow(ActualData)
        	#print(last_lines)	
'''