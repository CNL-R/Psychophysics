address = hex2dec('C010'); %Address is the first number of the I/O Range of a COM Port. It is given as a Hexadecimal number but must be converted to decimal.
config_io; %Needs to be run once in the beggining of the script before outp or inp can be used

outp(address, 3)
pause(0.005)
outp(address, 0)
