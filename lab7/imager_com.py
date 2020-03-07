import time   
import sys    
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   
import ok     # OpalKelly library

dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("Imager_toplevel.bit") # Configure the FPGA with this bit file

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

#%% define write and read functions
def write(d):
    for addr, data in d.items():
        dev.SetWireInValue(0x00, addr) #Input data for Variable 1 using mamoery spacee 0x00
        dev.SetWireInValue(0x01, data) #Input data for Variable 2 using mamoery spacee 0x01
        dev.SetWireInValue(0x02, 1) #Input data for Variable 2 using mamoery spacee 0x01
        print('Input Address:{}\n Data:{}\n'.format(addr, data))
        dev.UpdateWireIns()

def read(addr_arr):
    ret = {}
    for addr in addr_arr:
        dev.SetWireInValue(0x00, addr)
        dev.SetWireInValue(0x02, 0)
        dev.UpdateWireIns()
        time.sleep(0.1)
        dev.UpdateWireOuts()
        data_out = dev.GetWireOutValue(0x20)
        print('Output Address:{}\n Data:{}\n'.format(addr, data_out))
        ret[addr] = data_out
    return ret

#%% easy test
d = {3:22, 4:44}
write(d)
addr_arr = list(d.keys())
ret = read(addr_arr)
print(ret)

#%% Formal test

d = {57:3, 58:44, 59:240, 60:10, 69:9, 80:2, 83:187, \
    97:240, 98:10, 100:112, 101:98, 102:34, 103:64, \
    106:94, 107:110, 108:91, 109:82, 110:80, \
    117:91 }
write(d)
ret = read(list(d.keys()))
print(ret)
