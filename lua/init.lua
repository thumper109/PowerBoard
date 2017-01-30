dofile("settings.lua")

myMACAddress = wifi.sta.getmac()
myIPAddress= wifi.sta.getip()

relay1 = 1
relay2 = 2
relay3 = 3
relay4 = 4

R1=gpio.HIGH
R2=gpio.HIGH
R3=gpio.HIGH
R4=gpio.HIGH
    
r1Topic = "relays/" .. myMACAddress .. "/1"
r2Topic = "relays/" .. myMACAddress .. "/2"
r3Topic = "relays/" .. myMACAddress .. "/3"
r4Topic = "relays/" .. myMACAddress .. "/4"

local function readState()
    stateFile=file.open("relay.state", "r")
    R1=stateFile.read(1)
    R2=stateFile.read(1)
    R3=stateFile.read(1)
    R4=stateFile.read(1)
    stateFile.close()
end

local function writeState()
    stateFile=file.open("relay.state", "w")
    stateFile.write(R1)
    stateFile.write(R2)
    stateFile.write(R3)
    stateFile.write(R4)
    stateFile.close()
end

if file.exists("relay.state") then
    readState()
else
    writeState()
end

local function connectWifi()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(wifiSSID, wifiPassword)
    wifi.sta.connect()
end

local function mqttConnected(client)
    print("MQTT connected")
    print("Listening for relay 1 requests at '" .. r1Topic .. "'")
    mqttClient:subscribe(r1Topic, 0, mqttGetState)
    print("Listening for relay 2 requests at '" .. r2Topic .. "'")
    mqttClient:subscribe(r2Topic, 0, mqttGetState)
    print("Listening for relay 3 requests at '" .. r3Topic .. "'")
    mqttClient:subscribe(r3Topic, 0, mqttGetState)
    print("Listening for relay 4 requests at '" .. r4Topic .. "'")
    mqttClient:subscribe(r4Topic, 0, mqttGetState)
end

local function mqttGetState(client)
    print(client)
end

local function mqttDisconnected(client)
    print ("MQTT offline")
end

local function setupRelays()
    gpio.mode(relay1, gpio.OUTPUT)
    gpio.mode(relay2, gpio.OUTPUT)
    gpio.mode(relay3, gpio.OUTPUT)
    gpio.mode(relay4, gpio.OUTPUT)

    gpio.write(relay1, R1)
    gpio.write(relay2, R2)
    gpio.write(relay3, R3)
    gpio.write(relay4, R4)

end

local function receiveMqttMessage(connection, topic, message)
    if topic == r1Topic then
		if message == "on" then
            gpio.write(relay1, gpio.LOW)
            R1=gpio.LOW
		else
			gpio.write(relay1, gpio.HIGH)
            R1=gpio.HIGH
		end
    end
    if topic == r2Topic then
		if message == "on" then
            gpio.write(relay2, gpio.LOW)
            R2=gpio.LOW
		else
			gpio.write(relay2, gpio.HIGH)
            R2=gpio.HIGH
		end
    end
    if topic == r3Topic then
		if message == "on" then
            gpio.write(relay3, gpio.LOW)
            R3=gpio.LOW
		else
			gpio.write(relay3, gpio.HIGH)
            R3=gpio.HIGH
		end
    end
    if topic == r4Topic then
		if message == "on" then
            gpio.write(relay4, gpio.LOW)
            R4=gpio.LOW
		else
			gpio.write(relay4, gpio.HIGH)
            R4=gpio.HIGH
		end
    end
    writeState()
end

local function setupMqtt()
    mqttClient = mqtt.Client("pwBoard1", 120, mqttUser, mqttPassword)
    
    mqttClient:on("connect", mqttConnected)
    mqttClient:on("offline", mqttDisconnected)
    mqttClient:on("message", receiveMqttMessage)

    mqttClient:connect(mqttServerAddress, mqttPort, 0, 1)
end

local function wifiConnected()
    ssid, password, bssid_set, bssid = wifi.sta.getconfig()
    ip, netmask, gateway = wifi.sta.getip()
    print("Connected to " .. ssid .. " with ip address " .. ip)

    setupMqtt()
end

local function checkConnection()
    if (1 == wifi.sta.status()) then
        print("Not connected")
    else
        tmr.stop(1)
        wifiConnected()
    end
end

connectWifi()
setupRelays()
tmr.alarm(1,1000, 1, checkConnection)
