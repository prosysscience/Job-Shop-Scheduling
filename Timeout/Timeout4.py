import time
import subprocess
import os
import csv

path = "C:\\Users\\mohammed\\Downloads\\Research papers\\Benchmark problems"
os.chdir(path)
InputFolder = "Groupped Benchmarks"
constant1   = "clingo-dl JSPSaadClingoDL_V2.lp "
constant2   = " --minimize-variable=bound"
constant3   = " --time-limit="
TimeSec     = 15

filenames= os.listdir (InputFolder) # get all files' and folders' names in the current directory
counter=1

for foldername in filenames: # loop through all the files and folders
    if os.path.isdir(os.path.join(os.path.abspath(InputFolder), foldername)): # check whether the current object is a folder or not
        JobsAndMach = foldername.split("X")
        NumOfJobs	= int(JobsAndMach[0])
        NumOfMach	= int(JobsAndMach[1])
        if NumOfJobs >= 50:
            if NumOfJobs == 50:
                TimeSec = 60 * 900
            elif NumOfJobs == 100:
                continue
        else:
            if NumOfJobs == 6:
                #TimeSec = 200
                continue
            elif NumOfJobs <= 10:
                continue
                if NumOfMach < 10:
                    #TimeSec = 10 * 60
                    continue
                else:
                    #TimeSec = 15 * 60
                    continue
            elif NumOfJobs == 15:
                if NumOfMach == 5:
                    #TimeSec = 10 * 60
                    continue
                elif NumOfMach == 10:
                    #TimeSec = 20 * 60
                    continue
                elif NumOfMach == 15:
                    #TimeSec = 30 * 60
                    continue
            elif NumOfJobs == 20:
                if NumOfMach == 5:
                    #TimeSec = 15 * 60
                    continue
                elif NumOfMach == 10:
                    #TimeSec = 150 * 60
                    continue
                elif NumOfMach == 15:
                    #TimeSec = 210 * 60
                    continue
                elif NumOfMach == 20:
                    #TimeSec = 300 * 60
                    continue
            elif NumOfJobs == 30:
                if NumOfMach == 10:
                    #TimeSec = 150 * 60
                    continue
                elif NumOfMach == 15:
                    #TimeSec = 300 * 60
                    continue
                elif NumOfMach == 20:
                    TimeSec = 600 * 60

        FirstTimeInFolder = True
        print("Started This Folder " + foldername)
        print("Time Out is ------> " + str(TimeSec))
        time.sleep(5)
        for instance in os.listdir(os.getcwd() + "\\" + InputFolder + "\\" + foldername):
            if instance == 'Results':
                continue
            instanceNameWithoutExe = instance.split('.')
            instanceNameWithoutExe = instanceNameWithoutExe[0]
            TotalCall	= constant1 + '"' + InputFolder + "\\" + foldername+ "\\" + instance + '"' + constant2 + constant3 + str(TimeSec)+" --stat" + " --q" + "> " + '"' + InputFolder + "\\" + foldername+ "\\"+"Results\\" +instanceNameWithoutExe + ".csv" + '"'
            print("The next Instance is --> " + instance)
            time.sleep(3)
            os.system(TotalCall)
            with open(InputFolder + '\\' + foldername+ "\\"+"Results\\" +instanceNameWithoutExe + ".csv", 'r') as f:
                lines       = f.read().splitlines()
                if lines[-50] == 'UNSATISFIABLE':
                    last_lines  = lines[-50 : ]
                else:
                    last_lines  = lines[-51 : ]

                writer=csv.writer(open(InputFolder + '\\' + foldername+ "\\"+"Results\\" +foldername + ".csv",'a'))
                ActualData = []
                Header     = []
                for x in last_lines:
                    Record  = x.split(':')
                    if len(Record) == 1:
                        Header.append(Record[0])
                        ActualData.append(' ')
                    elif len(Record) > 1:
                        Header.append(Record[0])
                        ActualData.append(Record[1:])
                if Header[0] == 'UNKNOWN':
                    Header.pop(2)
                    ActualData.pop(2)
                # I have the data and I need to write them in csv file horrizontally
                ActualData[0] = Header[0]
                ActualData[1] = instanceNameWithoutExe
                if FirstTimeInFolder == True:
                    Header[0] = 'Optimal Found Or Timeout'
                    Header[1] = 'Instances'
                    writer.writerow(Header)
                    FirstTimeInFolder=False
                writer.writerow(ActualData)
        print("Finished This Folder " + foldername)
        print(counter)
        counter = counter + 1