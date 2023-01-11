import sys, getopt
import subprocess
import pkg_resources

required  = {'leglight'} 
#print("required: ",required)
installed = {pkg.key for pkg in pkg_resources.working_set}
#print("installed: ",installed)
missing   = required - installed
#print("missing: ", *missing)

if missing:
    # implement pip as a subprocess:
    subprocess.check_call(['sudo', sys.executable, '-m', 'pip', 'install', *missing])

import leglight

myLight = leglight.LegLight('192.168.178.23',9123)
print(myLight)
# Elgato Light ABC12345689 @ 10.244.244.139:9123

vars(myLight)
# {'address': '10.244.244.139', 'port': 9123, 'name': '', 'server': '', 'productName': 'Elgato Key Light', 'hardwareBoardType': 53, 'firmwareBuildNumber': 192, 'firmwareVersion': '1.0.3', 'serialNumber': 'ABC12345689', 'display': 'Key Light One'}

argList = sys.argv[1:]
options = "hb:c:10"
long_options = ["Help", "brightness =", "color =", "on", "off"]
try:
    arguments, values = getopt.getopt(argList, options, long_options)
    for currentArgument, currentValue in arguments:
        if currentArgument in ("-h", "--Help"):
            print ("elgato-key-light.py [on|off|blink]")
        elif currentArgument in ("-1", "--on"):
            print ("Turn light on")
            myLight.on()
        elif currentArgument in ("-0", "--off"):
            print ("Turn light off")
            myLight.off()
        elif currentArgument in ("-b", "--brightness"):
            #myLight.brightness(% s) % (currentValue)
            print (("myLight.brightness(% s)") % (currentValue))
            myLight.brightness(int(currentValue))
        elif currentArgument in ("-c", "--color"):
            #myLight.color(% s) % (currentValue)
            print (("myLight.color(% s)") % (currentValue))
            myLight.color(int(currentValue))

except getopt.error as err:
    print (str(err))

print (vars(myLight))
