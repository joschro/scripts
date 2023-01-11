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
#print(myLight)
# Elgato Light ABC12345689 @ 10.244.244.139:9123

vars(myLight)
# {'address': '10.244.244.139', 'port': 9123, 'name': '', 'server': '', 'productName': 'Elgato Key Light', 'hardwareBoardType': 53, 'firmwareBuildNumber': 192, 'firmwareVersion': '1.0.3', 'serialNumber': 'ABC12345689', 'display': 'Key Light One'}

argList = sys.argv[1:]
options = "hb:c:10"
long_options = ["Help", "brightness =", "color =", "on", "off"]

print (myLight.isOn)
