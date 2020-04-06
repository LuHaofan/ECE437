# import various libraries necessery to run your Python code
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
from PIL import Image
import time
#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()   # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")       # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("U:\\Desktop\\ECE437_Yiqingx2\\lab8_v3\\lab8_v3\\lab8_v3.runs\\impl_1\\BTPipeExample.bit")  # Configure the FPGA with this bit file

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
#%% define SPI read/write functions
def write(d):
    for addr, data in d.items():
        dev.SetWireInValue(0x10, addr) #Input data for Variable 1 using mamoery spacee 0x00
        dev.SetWireInValue(0x11, data) #Input data for Variable 2 using mamoery spacee 0x01
        dev.SetWireInValue(0x12, 1) #Input data for Variable 2 using mamoery spacee 0x01
        print('Input Address:{}\n Data:{}\n'.format(addr, data))
        dev.UpdateWireIns()
        dev.SetWireInValue(0x12, 0)
        dev.UpdateWireIns()
    return

def read(addr_arr):
    ret = {}
    for addr in addr_arr:
        dev.SetWireInValue(0x10, addr)
        dev.SetWireInValue(0x15, 1)     # set up write enable
        dev.UpdateWireIns()
        time.sleep(0.1)
        dev.UpdateWireOuts()
        data_out = dev.GetWireOutValue(0x20)
        print('Output Address:{}\n Data:{}\n'.format(addr, data_out))
        ret[addr] = data_out
        dev.SetWireInValue(0x15, 0)
        dev.UpdateWireIns()
    return ret    
#%% define the register addresses and values
d = {57:3,      # parallel CMOS output mode 
     58:44,     # required value 
     59:240,    # required value 
     60:10,     # required value 
     68:1,      # bit-mode: 10 bits per pixel 
     69:9,      # output the CLOCK_OUT Channel
     80:2,      # required value PGA_gain = 1.5x
     83:187,    # PLL_range:  CLK_IN is between 20.83MHz and 41.67MHz 
     97:240,    # required value
     98:10,     # required value
     100:112,   # required value
     101:98,    # required value
     102:34,    # required value
     103:64,    # required value
     106:94,    # required value
     107:110,   # required value
     108:91,    # required value
     109:82,    # required value
     110:80,    # required value
     117:91     # required value
     }
#%% Start up sequence
dev.SetWireInValue(0x13, 0)  #set system reset request
dev.SetWireInValue(0x14, 0)
dev.UpdateWireIns() 
time.sleep(0.000001) 
dev.SetWireInValue(0x13, 1)  #Reset FIFOs and counter
dev.UpdateWireIns() 
time.sleep(0.000001) 

#%% program the Imager and read out the registers value
write(d)
ret = read(list(d.keys()))
assert(ret == d)

#%% Reset FIFO
dev.SetWireInValue(0x00, 1)  #Reset FIFOs and counter
dev.UpdateWireIns()   # Update the WireIns

dev.SetWireInValue(0x00, 0)  #Release reset signal
dev.UpdateWireIns()   # Update the WireIns
#%% Request a frame
time.sleep(0.1)
dev.SetWireInValue(0x14, 1)  # set up request frame
dev.UpdateWireIns() 
time.sleep(1/25000000)
dev.SetWireInValue(0x14, 0)  # set down request frame
dev.UpdateWireIns() 
#%% Aquire the image data
buf = bytearray((650*488+240)*4)
re = dev.ReadFromBlockPipeOut(0xa0, 1024, buf)   # Read data from BT PipeOut
print(re)
print(buf[:100])
for i in range(0,len(buf),4):
    if buf[i] != 21:
        print(i)
        break

#%% parse the data
re = bytearray([buf[i] for i in range(0,len(buf),4)])
result = bytearray([])
for i in range(650*488):
    if (i%325 != 324):
        result.append(re[i])
    
#print(result[648*100:648*101])
#%%
imdata = bytes(result)
print(len(result))
img = Image.frombytes("L", (648, 488), imdata[:316224]) 
img.show()

#%%
dev.Close