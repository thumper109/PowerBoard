#!/usr/bin/env python
#####################
# File: pb.py
#
# Description:
# Main execution script fot the power Board Control Command Line.
#
# Version   Date     Author   Description.
# -------   -------  ------   -------------------------------------------------
# 0.1       29Jan17  RSC      Initial Cut.
#
# External modules.
import os
import sys
import pickle
import pb_mqtt as mqtt


# Global objects.
cfg_filename = '.pb.cfg'
conf_file = os.environ["HOME"] + '/' + cfg_filename
status = ''


# ****** Methods ******
# Make a configuration file with data entered by the user.
def make_cfg():
    """Create a configuration file."""
    mqtt_server = raw_input("Please enter the hostname or IP address of" +
                            " the MQTT server : ")
    esp8266_mac = raw_input("Please enter the mac address of the esp8166" +
                            " module : ")
    no_relays = raw_input("Please enter the number of relays the board" +
                          " has : ")

    board_cfg = {'mqtt': mqtt_server, 'esp8266': esp8266_mac,
                 'relays': no_relays}
    pickle.dump(board_cfg, cfg_file)
    return board_cfg


# Print usage and exit.
def usage():
    print("Usage: " + sys.argv[0] + " <status|on|off|toggle> <unit no.>\n"
          "Where: \n"
          "    status       Gives current state of relay\n"
          "    on           Set the relay on\n"
          "    off          Set the relay off\n"
          "    toggle       Toggle current state\n"
          "\n"
          "    unit no.     Relay number (1 to 4)\n")
    exit(0)


# ****** Main execution block ******
# Grab the command lines options.
command = sys.argv[1]
unit = sys.argv[2]

# If there is a config file, read it else create one.
if os.path.isfile(conf_file):
    cfg_file = open(conf_file, "r")
    cfg = pickle.load(cfg_file)
else:
    cfg_file = open(conf_file, "w")
    cfg = make_cfg()

# Close the config file.
cfg_file.close()

# Validate the command
if command != 'status' and command != 'on' and command != 'off' and command != 'toggle':
    print("Error: unknown command: " + command)
    usage()
# Ensure there is an appropriate number of arguments.
elif len(sys.argv) != 3:
    usage()
# Ensure the relay number is with in bounds set by config file.
elif unit < 0 or unit > cfg['relays']:
    print("Error: boar only has " + cfg['relays' + " configured."])
    usage()

# Initiate the relay we are controlling.
relay = mqtt.Relay(cfg['esp8266'], unit, cfg['mqtt'])

# Act on the choice of command from the arguments.
# Get the current status.
if command == 'status':
    status = relay.get_status()
# Turn the relay on.
elif command == 'on':
    status = relay.set_status('on')
# Turn the relay off.
elif command == 'off':
    status = relay.set_status('off')
# Toggle the relays state.
elif command == 'toggle':
    status = relay.toggle()
else:
    usage()

# Let the user know what the state in now.
print("Relay " + unit + " has been set to " + status)

#
# End of file
#
