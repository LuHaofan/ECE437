# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("lab5.bit") # Configure the FPGA with this bit file

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.")
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)))
    print ("Exiting the progam.")
    sys.exit ()
print("----------------------------------------------------")
print("----------------------------------------------------")

#%% 

def bit2Temp(tmp):
    b = bin(tmp)[2:-3]
    if(len(b)<13):
        b = '0'*(13-len(b))+b
    if (b[0] == '1'):
        re = (int(b,2)-8192)/16
    else:
        re = int(b,2)/16
    return re
    
N = 10
temp_arr = []
while(len(temp_arr) < N):              
    dev.UpdateWireOuts()
    result = dev.GetWireOutValue(0x20)
    if result != 0:
        temp_arr.append(bit2Temp(result))
    time.sleep(0.5)   

print('Temperature read from the Temperature sensor is: {}'.format(temp_arr))
dev.Close
    