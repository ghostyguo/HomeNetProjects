#include <SPI.h>
#include <Ethernet.h>
#include "RTOS.h"
#include "SysTime.h"
#include "dht.h"

#define DHT22_PIN   6

byte mac[] = {0x00,0x1A,0x4B,0x38,0x0C,0x5C}; //clone from DLINK

IPAddress ip(192, 168, 2, 177);
EthernetServer localWebServer(80);
EthernetClient remoteSqlClient;
char remoteSqlServer[] = "192.168.2.211";
//IPAddress remoteSqlServer(192,168,2,211);

dht DHT;

Task *pLocalWebServerClientConnectTask;
Task *pUpdateRemoteSqlServerTask;
Task *pReadDhtTask;

void setup() {
    Serial.begin(57600);

    // start the Ethernet connection and the server:
    Ethernet.begin(mac, ip);
    localWebServer.begin();
    Serial.print(F("server is at "));
    Serial.println(Ethernet.localIP());
  
    // Initialzie the time  
    SysTime_Init();

    // Add tasks to RTOS
    pLocalWebServerClientConnectTask = RTOS.taskManager.addTask(LocallocalWebServerClientConnectTask, "LocalWebServerClientConnectTask", 5); 
    pUpdateRemoteSqlServerTask = RTOS.taskManager.addTask(UpdateRemoteSqlServerTask, "UpdateRemoteSqlServerTask", 10000); 
    pReadDhtTask = RTOS.taskManager.addTask(ReadDhtTask, "ReadDhtTask", 1000); 
  
    RTOS.init();
}


void loop() {
    RTOS.run(); //Always run th OS
}

void LocallocalWebServerClientConnectTask()
{  
    // listen for incoming clients
    EthernetClient client = localWebServer.available();
    if (client) {
        Serial.println(F("new client"));
        // an http request ends with a blank line
        boolean currentLineIsBlank = true;
        while (client.connected()) {            
            if (client.available()) {
                char c = client.read();
                Serial.write(c);
                if (c == '\n' && currentLineIsBlank) {
                    // send a standard http response header
                    client.println(F("HTTP/1.1 200 OK"));
                    client.println(F("Content-Type: text/html"));
                    client.println(F("Connection: close"));  // the connection will be closed after completion of the response
                    client.println(F("Refresh: 5"));  // refresh the page automatically every 5 sec
                    client.println();
                    client.println(F("<!DOCTYPE HTML>"));
                    client.println(F("<html>"));
                    client.print(F("Time = "));
                    client.println(SysTime_String);
                    client.print(F("<br>"));
                    client.print(F("Humidity = "));
                    client.print(DHT.humidity, 1);                    
                    client.print(F("<br>"));
                    client.print(F("Temperature = "));
                    client.println(DHT.temperature, 1); 
                    client.println(F("</html>"));
                    break;               
                }
                if (c == '\n') {
                    // you're starting a new line
                    currentLineIsBlank = true;
                }
                else if (c != '\r') {
                    // you've gotten a character on the current line
                    currentLineIsBlank = false;
                }
            } //if (client.available()) 
        } //while (client.connected())         
        delay(1); // give the web browser time to receive the data
        client.stop();  // close the connection:
        Serial.println(F("client disconnected"));
    
        RTOS.taskManager.activeTaskReport();    
    } // if (client)
}

void UpdateRemoteSqlServerTask() 
{
    remoteSqlClient.stop();

    // if there's a successful connection:
    if (remoteSqlClient.connect(remoteSqlServer, 80)) {
        String params;
        params = "loc=" + String("4F1") + "&temp=" +  String(DHT.temperature,1) + "&hum=" + String(DHT.humidity, 1);
        Serial.print("params= '");
        Serial.println(params);
        remoteSqlClient.println("POST /SensorReport.php HTTP/1.1"); 
        remoteSqlClient.print("Host: "); 
        remoteSqlClient.println(remoteSqlServer); // SERVER ADDRESS HERE TOO
        remoteSqlClient.println("Content-Type: application/x-www-form-urlencoded"); 
        remoteSqlClient.print("Content-Length: "); 
        remoteSqlClient.println(params.length()); 
        remoteSqlClient.println(); 
        remoteSqlClient.print(params); 
    }
    else {
        // if you couldn't make a connection:
        Serial.println(F("connection SQL failed"));
    }
    RTOS.taskManager.activeTaskReport();
}

void ReadDhtTask()
{
    int chk = DHT.read22(DHT22_PIN);
    Serial.print(F("Read DHT22 : "));
    switch (chk)
    {
        case DHTLIB_OK:  
            Serial.print(F("OK")); 
            break;
        case DHTLIB_ERROR_CHECKSUM: 
            Serial.print(F("Checksum error")); 
            break;
        case DHTLIB_ERROR_TIMEOUT: 
            Serial.print(F("Time out error")); 
            break;
        default: 
            Serial.print(F("Unknown error")); 
        break;
    }
    // DISPLAY DATA
    Serial.print(F(", H="));
    Serial.print(DHT.humidity, 1);
    Serial.print(F(", T="));
    Serial.println(DHT.temperature, 1);
    RTOS.taskManager.activeTaskReport();
}


