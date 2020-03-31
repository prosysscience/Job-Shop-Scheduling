import re
import numpy as np
import scipy as sp
import os
import xlsxwriter
# Open files from current dir

directoryName = "test"

for filename in os.listdir(os.getcwd() + "\\" + directoryName):
     with open(directoryName+"\\"+filename) as f:
        text = f.read()
        problems = text.split('+++++++++++++++++++++++++++++\n')
        #print(problems)
        problems = problems[2:]
        counter=0
        Abbreviation = ' '
        row = 1
        #workbook  = xlsxwriter.Workbook("C:\\Users\\mohammed\\Downloads\\Research papers\\Benchmark problems\\test\\Results.xlsx")
        #worksheet = workbook.add_worksheet()
        for problem in problems:
            if counter % 2 != 0:
                #print('Problem')
                #print(problem)
                lines = problem.split('\n')
                InstanceName   = lines[0]
                InstanceName   = '% ' + InstanceName
                NumJobsAndMach = lines[1]
                NumJobsAndMach = NumJobsAndMach.split(' ')
                NumJobsAndMach = NumJobsAndMach[1:]
                NumOfMachines  = NumJobsAndMach[1]
                NumOfJobs      = NumJobsAndMach[0]
                NumOfJobsInt   = int(NumOfJobs)
                NumOfMachInt   = int(NumOfMachines)
                MainData       = lines[2:]
                MainData       = MainData[0:-1]
                MachinesMatrix = [[]*NumOfJobsInt]*NumOfJobsInt
                ProTimeMatrix  = [[]*NumOfJobsInt]*NumOfJobsInt
             

                # ******************** Create The Main Matrix  ********************
                for x in range(0,NumOfJobsInt):
                    MainData[x]    = MainData[x].split()
                # ******************** Create The Main Matrix  ********************

                
                # ****************** Create a Matrix For Machines ******************
                for x in range(0,NumOfJobsInt):
                    temp    = []
                    y       = 0
                    count   = 0
                    while y <= ((2 * NumOfMachInt) - 2):
                        temp.append(MainData[x][y])
                        y       = y + 2
                        count   = count + 1
                    MachinesMatrix[x] = temp
                    #print(MachinesMatrix[x])
                # ****************** Create a Matrix For Machines ******************
                
                
                # *************** Create a Matrix For Processing Time ***************
                for x in range(0,NumOfJobsInt):
                    temp    = []
                    y       = 1
                    count   = 0
                    while y <= ((2 * NumOfMachInt) - 1):
                        temp.append(MainData[x][y])
                        y       = y + 2
                        count   = count + 1
                    ProTimeMatrix[x] = temp
                    #print(ProTimeMatrix[x])
                # *************** Create a Matrix For Processing Time ***************

                
                #fc = open("C:\\Users\\mohammed\\Downloads\\Research papers\\Benchmark problems\\test\\" + InstanceName + ' ' + '[' + Abbreviation + ']' + '.lp', "w+")
                fc = open("C:\\Users\\mohammed\\Downloads\\Research papers\\Benchmark problems\\TestAdams\\" + Abbreviation + '.lp', "w+")
                fc.writelines(InstanceName)
                fc.write("\n")
                fc.writelines('#const' + ' ' + 'numOfJobs'      + '=' + ' ' + str(NumOfJobsInt) + '.')
                fc.write("\n")
                fc.writelines('#const' + ' ' + 'numOfMachines'  + '=' + ' ' + str(NumOfMachInt) + '.')
                fc.write("\n")
                for i in range(NumOfJobsInt):
                    for j in range(NumOfMachInt):
                        fc.writelines("assignment" + '(' + str(i+1) + ','+' ' + str(j+1) + ','+' ' + MachinesMatrix[i][j] + ','+' ' + ProTimeMatrix[i][j] + ')'+'.')
                        fc.write("\n")
                fc.close()
                #NewInstances = InstanceName + ' ' + '[' + Abbreviation + ']'
                NewInstances  = Abbreviation
                #print(NewInstances) 
                #worksheet.write(row, 0, NewInstances)
                #fi.write(NewInstances,row)
                #fi.write("\n")
                # ******************** Create a Matrix For Jobs ********************
                row = row + 1
            else:
                Lines = problem.split()
                if len(Lines) > 1:
                    Abbreviation = Lines[1]
                
            counter = counter+1
        #workbook.close()