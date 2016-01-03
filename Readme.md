This is a part of my HomeNet Project.

The Arduino UNO is a sensor node which samples the temperature/humidity from the DHT22. The sensed data is sent to Raspberry Pi every 10 seconds. The UNO has a web service to display the current status. 

The Arduino project includes:
(1) HomeNet_WebSensor : originally from arduino 'Ethernet>WebServer' example
(2) RTOS : the 'Arduino-PreemptiveOS' prject 
(3) SysTime : get time by NTP and maintain the time service for whole project
(4) DHT : sourced from http://arduino.cc/playground/Main/DHTLib by Rob Tillaart

THe Raspberry Pi requires the mysql, apache2 and php are installed. 
Data from UNO is  received by the 'SensorReport.php' API.  The 'password' in 'SensorReport.php' is required to be setup according to your own mysql installation.