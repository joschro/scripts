#!/bin/python3

import sys
from smllib import SmlStreamReader

stream = SmlStreamReader()
data = sys.stdin.buffer.read()
#stream.add(b'BytesFromSerialPort')
stream.add(data)
sml_frame = stream.get_frame()
if sml_frame is None:
    print('Bytes missing')

# Shortcut to extract all values without parsing the whole frame
obis_values = sml_frame.get_obis()

# return all values but slower
parsed_msgs = sml_frame.parse_frame()
for msg in parsed_msgs:
    # prints a nice overview over the received values
    print(msg.format_msg())
