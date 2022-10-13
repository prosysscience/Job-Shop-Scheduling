f1 = open("Dmu60.lp", 'r')
f2 = open("Dmu60_new.lp", 'w')
l = []
text = f1.readlines()
count = 1
for line in text:
	if count > 3:
		atom = line
		#print(atom)
		atom = atom.split(',')
		atom[2] = str(int(atom[2]) + 1)
		count = count + 1
		atom = atom[0] + ',' + atom[1] + ', ' + atom[2] + ',' + atom[3]
		l.append(atom)
		#print(atom)
		#print('*****************')
	else:
		count = count + 1
f1.close()
f2.writelines(l)
f2.close()