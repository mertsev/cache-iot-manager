# cache-iot-manager

**Framework for managing IoT data through Intersystems Cache and simple angularJs web interface**

For more info about this project check out this [User/Developer guide](https://docs.google.com/document/d/1VM7ZiQ7I5A9pwmA0fQvEOZNR2UfmWOoFqvCrJl4v3zI/edit?usp=sharing)

#Contains
* Rest Interface
* Web GUI
* Storage
* Callback mechanism
* [Android application](https://github.com/mertsev/cache-iot-manager/blob/master/mqtt_app.apk) that sends light sensors data to the server

#Installation guide
1. Make sure you have [DeepSeeWeb](https://github.com/intersystems-ru/DeepSeeWeb) installed
2. Download the latest release from [release page](https://github.com/mertsev/cache-iot-manager/releases/)
3. Create MQTTIOT namespace and switch to it
4. Import and compile InstallAll.xml
5. Open terminal and execute the following string:

   ```
   d ##class(IOT.Installer).setup()
   ```
   - It will create mqttrest and mqttweb apps
   - You can delete this class after you initialized the apps
6. In a web-app called mqttrest add a dispatch class:

   ```
   REST.Broker
   ```
7. In a web-app called mqttweb enable DeepSee
8. Copy mqttweb folder into:

 ```
 %CACHEPATH%/CSP
 ```
9. To use IoT Manager open 
 ```
 server:port/csp/mqttweb/index.html
 ```
10. Install mqtt_app.apk on Android device if you need it

#Repo's used
[Attila Tóth's Cache MQTT client](https://github.com/atothISC/COS-MQTTClient)

[DeepSeeWeb](https://github.com/intersystems-ru/DeepSeeWeb)

