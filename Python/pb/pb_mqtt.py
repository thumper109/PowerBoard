#!/usr/bin/env python
#####################
# File: pb_mqtt.py
#
# Description:
# Module that contains the MQTT functions for the pb.py tool.
#
# Version   Date     Author   Description.
# -------   -------  ------   -------------------------------------------------
# 0.1       29Jan17  RSC      Initial Cut.
#
# External modules.
import paho.mqtt.subscribe as subscribe
import paho.mqtt.publish as publish

# **** Relay class for the pb.py tool.
# Describe the class for controlling a relay on the Power Board unit.
class Relay:
    """Relay object used to manipulate the power board relays."""
    def __init__(self, mac, unit, host):
        self.mac = mac
        self.unit = unit
        self.host = host
        self.topic = "relays/" + mac + "/" + unit

    # Return the current status of the relay chosen.
    def get_status(self):
        msg = subscribe.simple(self.topic, hostname=self.host)
        # debug: print("%s %s" % (msg.topic, msg.payload))
        return msg.payload

    # Send a message to set the relay to a specific state.
    def set_status(self, payload):
        publish.single(self.topic, payload, hostname=self.host, retain=True)
        msg = subscribe.simple(self.topic, hostname=self.host)
        return msg.payload

    # Check the current state of the relay nd flip it to the opposite
    # state.
    def toggle(self):
        state = self.get_status()

        if state == "off":
            self.set_status('on')
        else:
            self.set_status('off')

        return self.get_status()
#
# End of file
#
