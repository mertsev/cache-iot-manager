# cache-iot-manager

**Framework for managing IoT data through Intersystems Cache and simple angularJs web interface**

For more info about this project check out this [User/Development guide](https://docs.google.com/document/d/1VM7ZiQ7I5A9pwmA0fQvEOZNR2UfmWOoFqvCrJl4v3zI/edit?usp=sharing)

#Contains
* Rest Interface
* Web GUI
* Storage
* Callback Mechanishm
* Adnroid application mqtt_app that sends light sensors data on server

#Installation guide
1. Make sure you have [CacheUpdater](https://github.com/intersystems-ru/CacheUpdater) installed
2. Import and compile [InstallApp.xml](/InstallApp.xml)
3. Open terminal and execute following string:

   ```
   d ##class(IOT.Installer).setup()
   ```
   - It will create mqttrest and mqttweb apps
4. In a web-app called mqttrest add a dispatch class:

   ```
   REST.Broker
   ```
5. Open terminal and execute following string with GitHub your username/password:

  ``` 
  w ##class(CacheUpdater.Task).Update("mertsev", "cache-iot-manager", "master", "Username", "Password", "mqttiot")  
  ```
  - It will import all necessary files directly from GitHub
6. To use IoT Manager open 
 ```
 server:port/csp/mqttiot/mqttweb/index.html
 ```

#Repo's used
[Attila Tóth's Cache MQTT client](https://github.com/atothISC/COS-MQTTClient)

