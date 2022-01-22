operation(1,1,1,3).  operation(1,2,2,3).  operation(1,3,3,1). #(\label{prg:facts:ops:begin}#)
operation(2,1,2,4).  operation(2,2,1,6).  operation(2,3,3,2).
operation(3,1,3,9).  operation(3,2,1,3).  operation(3,3,2,8). #(\label{prg:facts:ops:end}#)
%*
operation(1,1).  operation(1,2).  operation(1,3). #(\label{prg:facts:ops:begin}#)
operation(2,1).  operation(2,2).  operation(2,3).
operation(3,1).  operation(3,2).  operation(3,3). #(\label{prg:facts:ops:end}#)

optime(1,1,9).  optime(1,2,3).  optime(1,3,12). #(\label{prg:facts:pro:begin}#)
optime(2,1,4).  optime(2,2,6).  optime(2,3,2).
optime(3,1,4).  optime(3,2,3).  optime(3,3,5).  #(\label{prg:facts:pro:end}#)

assign(1,1,2).  assign(1,2,3).  assign(1,3,1). #(\label{prg:facts:mach:begin}#)
assign(2,1,3).  assign(2,2,2).  assign(2,3,1).
assign(3,1,1).  assign(3,2,3).  assign(3,3,2). #(\label{prg:facts:mach:end}#)
*%
