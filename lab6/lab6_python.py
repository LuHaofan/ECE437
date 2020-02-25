# NOTE 1
# If your power supply goes into an error state (i.e., the word
# error is printed on the front of the device), use this command
# power_supply.write("*CLS")
# to clear the error so that you can rerun your code. The supply
# typically beeps after an error has occured.

import visa
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import time
mpl.style.use('ggplot')

#%%
# This section of the code cycles through all USB connected devices to the computer.
# The code figures out the USB port number for each instrument.
# The port number for each instrument is stored in a variable named “instrument_id”
# If the instrument is turned off or if you are trying to connect to the 
# keyboard or mouse, you will get a message that you cannot connect on that port.
device_manager = visa.ResourceManager()
devices = device_manager.list_resources()
number_of_device = len(devices)

power_supply_id = -1
waveform_generator_id = -1
digital_multimeter_id = -1
oscilloscope_id = -1

# assumes only the DC power supply is connected
for i in range (0, number_of_device):

# check that it is actually the power supply
    try:
        device_temp = device_manager.open_resource(devices[i])
        print("Instrument connect on USB port number [" + str(i) + "] is " + device_temp.query("*IDN?"))
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.2-6.0-2.0\r\n'):
            power_supply_id = i        
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.0-6.0-2.0\r\n'):
            power_supply_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,33511B,MY52301259,3.03-1.19-2.00-52-00\n'):
            waveform_generator_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,34461A,MY53207918,A.01.10-02.25-01.10-00.35-01-01\n'):
            digital_multimeter_id = i 
        if (device_temp.query("*IDN?") == 'Keysight Technologies,34461A,MY53213065,A.02.08-02.37-02.08-00.49-01-01\n'):
            digital_multimeter_id = i            
        if (device_temp.query("*IDN?") == 'KEYSIGHT TECHNOLOGIES,MSO-X 3024T,MY54440298,07.10.2017042905\n'):
            oscilloscope_id = i                        
        device_temp.close()
    except:
        print("Instrument on USB port number [" + str(i) + "] cannot be connected. The instrument might be powered of or you are trying to connect to a mouse or keyboard.\n")
    

#%%
# Open the USB communication port with the power supply.
# The power supply is connected on USB port number power_supply_id.
# If the power supply ss not connected or turned off, the program will exit.
# Otherwise, the power_supply variable is the handler to the power supply
    
if (power_supply_id == -1):
    print("Power supply instrument is not powered on or connected to the PC.")    
else:
    print("Power supply is connected to the PC.")
    power_supply = device_manager.open_resource(devices[power_supply_id]) 
    
if (digital_multimeter_id == -1):
    print("Digital multimeter instrument is not powered on or connected to the PC.")
else:
    print("Digital multimeter is connected to the PC")
    digital_multimeter = device_manager.open_resource(devices[digital_multimeter_id])

#%%
# The power supply output voltage will be swept from 0 to 1.5V in steps of 0.05V.
# This voltage will be applied on the 6V output ports.
# For each voltage applied on the 6V power supply, we will measure the actual 
# voltage and current supplied by the power supply.
# If your circuit operates correctly, the applied and measured voltage will be the same.
# If the power supply reaches its maximum allowed current, 
# then the applied voltage will not be the same as the measured voltage.
    output_voltage = np.arange(0, 4.8, 0.096)
    supply_voltage_mean = np.array([]) # create an empty list to hold our values
    supply_current_mean = np.array([])
    power_consump_mean = np.array([])
    supply_voltage_std = np.array([]) # create an empty list to hold our values
    supply_current_std = np.array([])
    power_consump_std = np.array([])
    
    measured_current = np.array([]) # create an empty list to hold our values
    power_supply.write("*CLS")
    print(power_supply.write("OUTPUT ON")) # power supply output is turned on

    # loop through the different voltages we will apply to the power supply
    # For each voltage applied on the power supply, 
    # measure the voltage and current supplied by the 6V power supply
    for v in output_voltage:
        supply_voltage_tmp = np.array([]) # size 100
        supply_current_tmp = np.array([])
        power_consump_tmp = np.array([])
        print('Measuring data for voltage {}'.format(v))
        # apply the desired voltage on teh 6V power supply and limist the output current to 0.5A
        power_supply.write("APPLy P6V, %0.2f, 0.06" % v)
        # read the output current on the 6V power supply
        measured_current_tmp = digital_multimeter.query("MEAS:CURR:DC?")
        print('Current:{}'.format(measured_current_tmp))
        measured_current = np.append(measured_current, float(measured_current_tmp))
        flag = 0
        # read the output voltage on the 6V power supply
        for i in range(100):
            time.sleep(0.01)
            measured_voltage_sup = power_supply.query("MEASure:VOLTage:DC? P6V")
            supply_voltage_tmp = np.append(supply_voltage_tmp, float(measured_voltage_sup))
            measured_current_sup = power_supply.query("MEASure:CURR:DC? P6V")
            supply_current_tmp = np.append(supply_current_tmp, float(measured_current_sup))   
            power_consump_tmp = np.append(power_consump_tmp, float(measured_current_tmp)*float(measured_voltage_sup))
                # power supply output is turned off
            if float(measured_current_tmp)*float(measured_voltage_sup) > 0.5:
                print(power_supply.write("OUTPUT OFF"))
                flag = 1
            
        if flag == 1:
            break
        # Calculate the mean and standard dev of voltage and current
        upply_voltage_std = np.append(supply_voltage_std, np.std(supply_voltage_tmp))
        upply_voltage_mean = np.append(supply_voltage_mean, np.mean(supply_voltage_tmp))
        supply_current_std = np.append(supply_current_std, np.std(supply_current_tmp))
        supply_current_mean = np.append(supply_current_mean, np.mean(supply_current_tmp))
        power_consump_std = np.append(power_consump_std, np.std(power_consump_tmp))
        power_consump_mean = np.append(power_consump_mean, np.mean(power_consump_tmp))
    # close the power supply USB handler.
    # Otherwise you cannot connect to it in the future
    if flag == 0:
        print(power_supply.write("OUTPUT OFF"))
    power_supply.close()

#%%    
    '''
    # plot results (applied voltage vs measured supplied current)
    plt.figure()
    plt.plot(output_voltage,measured_current)
    plt.title("Applied Volts vs. Measured Supplied Current for Diode")
    plt.xlabel("Applied Volts [V]")
    plt.ylabel("Measured Current [A]")
    plt.draw()
'''
    # plot results (voltage vs current)
    plt.figure()
    plt.plot(output_voltage,supply_current_mean)
    plt.plot(output_voltage, supply_current_std)
    plt.title("Voltage vs. Current for resistor")
    plt.xlabel("Voltage Across the diode [V]")
    plt.ylabel("Current Through the circuit[A]")
    plt.draw()

    # plot results (voltage vs voltage)
    plt.figure()
    plt.plot(output_voltage,supply_voltage_std)
    plt.plot(output_voltage, supply_voltage_mean)
    plt.title("Voltage vs. supply voltage for resistor")
    plt.xlabel("Voltage Across the diode [V]")
    plt.ylabel("Voltage Through the circuit[A]")
    plt.draw()

    plt.figure()
    plt.plot(output_voltage,power_consump_std)
    plt.plot(output_voltage, power_consump_mean)
    plt.title("Voltage vs. power consumption for resistor")
    plt.xlabel("Voltage Across the diode [V]")
    plt.ylabel("Power consumption Through the circuit[A]")
    plt.draw()
    # show all plots
    plt.show()
'''
if (oscilloscope_id == -1):
    print("Oscilloscope instrument is not powered on or connected to the PC.")
else:
    print("Oscilloscope instrument is connected to the PC.")
    oscilloscope = device_manager.open_resource(devices[oscilloscope_id])
'''
