#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include "SysTime.h"
#include "RTOS.h"

// private functions
void NTP_ParsePacket();
unsigned long NTP_SendPacket(IPAddress& address);
void NTP_UpdateTask();
void NTP_ParsePacketThread();
void NTP_UpdateTimeTask();
void updateSystemTimeString();

// NTP
#define   NTP_LISTEN_PORT   2345    // local port to listen for NTP_ListenUdp packets
#define   NTP_PACKET_SIZE     48    // NTP time stamp is in the first 48 bytes of the message
#define   NTP_UTC_SHIFT       8     // Taipei : UTC+8

byte NTP_PacketBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming and outgoing packets

// An Udp instance to send and receive packets over Udp
EthernetUDP NTP_ListenUdp;
IPAddress timeServer(118, 163, 81, 61); // time.stdtime.gov.tw NTP server

// System time
int SysTime_Hour, SysTime_Minute, SysTime_Second;
char SysTime_String[]="00:00:00";

// global variable
long lastMillis;
Task *pNTP_UpdateTask,*pNTP_ParsePacketThread, *pNTP_UpdateTimeTask;

// Public functions

void SysTime_Init()
{
    NTP_ListenUdp.begin(NTP_LISTEN_PORT);

    //Update
    pNTP_UpdateTask = RTOS.taskManager.addTask(NTP_UpdateTask , "NTP_UpdateTask", 10000, RUNNING, 9000); //run immediately
    pNTP_ParsePacketThread = RTOS.taskManager.addTask(NTP_ParsePacketThread , "NTP_ParsePacketThread", 1000, SUSPEND); 
    pNTP_UpdateTimeTask  = RTOS.taskManager.addTask(NTP_UpdateTimeTask , "NTP_UpdateTimeTask", 1000); 
}

void updateSystemTimeString()
{
    SysTime_String[0] = '0'+SysTime_Hour/10;
    SysTime_String[1] = '0'+SysTime_Hour%10;
    SysTime_String[3] = '0'+SysTime_Minute/10;
    SysTime_String[4] = '0'+SysTime_Minute%10;
    SysTime_String[6] = '0'+SysTime_Second/10;
    SysTime_String[7] = '0'+SysTime_Second%10;
}

void NTP_ParsePacket()
{
    if (NTP_ListenUdp.parsePacket()) {
        NTP_ListenUdp.read(NTP_PacketBuffer, NTP_PACKET_SIZE); // read the packet into the buffer
        unsigned long highWord = word(NTP_PacketBuffer[40], NTP_PacketBuffer[41]);
        unsigned long lowWord = word(NTP_PacketBuffer[42], NTP_PacketBuffer[43]);
        unsigned long secsSince1900 = highWord << 16 | lowWord;
        lastMillis = millis();
        // now convert NTP time into everyday time:       
        unsigned long epoch = secsSince1900 - 2208988800UL; // Unix time starts on Jan 1 1970. In SysTime_Seconds, that's 2208988800
        epoch += 3600*NTP_UTC_SHIFT; //Adjust UCT

        SysTime_Hour = (epoch  % 86400L) / 3600;
        SysTime_Minute = (epoch % 3600) / 60;
        SysTime_Second = epoch % 60;

        updateSystemTimeString();
        Serial.print(F("NTP time is "));       // UTC is the time at Greenwich Meridian (GMT)
        Serial.print(SysTime_String);
    }
    else {
        Serial.println(F("NTP_ParsePacket() fail"));
    }
}

// send an NTP request to the time server at the given address
unsigned long NTP_SendPacket(IPAddress& address)
{
    // set all bytes in the buffer to 0
    memset(NTP_PacketBuffer, 0, NTP_PACKET_SIZE);
    // Initialize values needed to form NTP request
    NTP_PacketBuffer[0] = 0b11100011;   // LI, Version, Mode
    NTP_PacketBuffer[1] = 0;     // Stratum, or type of clock
    NTP_PacketBuffer[2] = 6;     // Polling Interval
    NTP_PacketBuffer[3] = 0xEC;  // Peer Clock Precision
    // 8 bytes of zero for Root Delay & Root Dispersion
    NTP_PacketBuffer[12]  = 49;
    NTP_PacketBuffer[13]  = 0x4E;
    NTP_PacketBuffer[14]  = 49;
    NTP_PacketBuffer[15]  = 52;

    NTP_ListenUdp.beginPacket(address, 123); //NTP requests are to port 123
    NTP_ListenUdp.write(NTP_PacketBuffer, NTP_PACKET_SIZE);
    NTP_ListenUdp.endPacket();
}

// RTOS Tasks

void NTP_UpdateTask()
{ 
    NTP_SendPacket(timeServer); // send an NTP packet to a time server

    (*pNTP_UpdateTask).setState(SUSPEND);  
    (*pNTP_ParsePacketThread).setState(RUNNING);  
    RTOS.taskManager.activeTaskReport();
}

void NTP_ParsePacketThread()
{
    NTP_ParsePacket();
     
    (*pNTP_UpdateTask).setState(RUNNING);  
    (*pNTP_ParsePacketThread).setState(SUSPEND);
    RTOS.taskManager.activeTaskReport();
}

void NTP_UpdateTimeTask()
{
    // update the Clock Info by Arduino timer
    int timediff = millis() - lastMillis;
    if ( timediff> 1000) {
        SysTime_Second += timediff/1000;
        lastMillis = millis();
        if (SysTime_Second>=60) {
            SysTime_Second -= 60;
            SysTime_Minute++;
        }
        if (SysTime_Minute>=60) {
          SysTime_Minute=0;
          SysTime_Hour++;
        }
        if (SysTime_Hour>=24) {
          SysTime_Hour=0;
        }
        updateSystemTimeString();
        Serial.print(F("System Time is "));       // UTC is the time at Greenwich Meridian (GMT)
        Serial.print(SysTime_String);
    }
    RTOS.taskManager.activeTaskReport();
}

