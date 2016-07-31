#include <Arduino.h>
#include <avr/wdt.h>

#define pinRelay1  13  // relay control
#define pinRelay2  12  // relay control
#define pinRelay3  11  // relay control
#define pinRelay4  10  // relay control
#define pinVcc      9  // +5V to relay board

void setup() {
    wdt_disable();
    pinMode(pinVcc,    INPUT);
    pinMode(pinRelay1, OUTPUT);  digitalWrite(pinRelay1,LOW);
    pinMode(pinRelay2, OUTPUT);  digitalWrite(pinRelay2,LOW);
    pinMode(pinRelay3, OUTPUT);  digitalWrite(pinRelay3,LOW);
    pinMode(pinRelay4, OUTPUT);  digitalWrite(pinRelay4,LOW);
    
    Serial.begin(57600);    
    delay(1000); //wair for Serial up  //while (!Serial);

    //Relay Control
    Serial.println("Relay 1"); RelayControl(pinRelay1,5);
    Serial.println("Relay 2"); RelayControl(pinRelay2,5);
    Serial.println("Relay 3"); RelayControl(pinRelay3,5);
    Serial.println("Relay 4"); RelayControl(pinRelay4,5);
    Serial.println("Shutdown");
}


void loop() {
}

void RelayControl(int pinRelay, int second)
{
     digitalWrite(pinRelay,HIGH);
     for (int s=0; s<second; s++) delay(1000);
     digitalWrite(pinRelay,LOW);
     delay(1000); //wait for relay stable
}

