This is a part of my HomeNet Project.

THe Raspberry Pi requires the mysql, apache2 and php are installed. 

The Arduino UNO is a sensor node which samples the temperature/humidity from the DHT22. The sensed data is sent to Raspberry Pi every 10 seconds. The UNO has a web service to display the current status. <br>
The Arduino project includes:<br>
(1) HomeNet_WebSensor : originally from arduino 'Ethernet>WebServer' example<br>
(2) RTOS : the 'Arduino-PreemptiveOS' prject <br>
(3) SysTime : get time by NTP and maintain the time service for whole project<br>
(4) DHT : sourced from http://arduino.cc/playground/Main/DHTLib by Rob Tillaart<br>
Data from UNO is received by the 'SensorReport.php' API.  The 'password' in 'SensorReport.php' is required to be setup according to your own mysql installation.

The NodeMCU is used as a pump motor controller.  <br>
(1) The controller samples the temperature/humidity from the DHT22 and senses the current of the motor. <br>
(2) The sensed data is sent to Raspberry Pi every 10 seconds. <br>
(2) The controller is scheduled to turn on the relay which starts to pump water. <br>
(3) When the water tower is full, the motor will stop automatically, and the current is near zero. <br>
(4) The controller turn off the relay. <br>
