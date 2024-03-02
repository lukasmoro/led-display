#include <WiFi101.h>
#include <Adafruit_NeoPixel.h>

// LED Strip
const int pin = 7;
Adafruit_NeoPixel strip = Adafruit_NeoPixel(70, pin, NEO_GRB + NEO_KHZ800);

// WiFi Credentials
char ssid[] = "TP-Link_0CC9";             
char pass[] = "14906435";                     
int status = WL_IDLE_STATUS;      
WiFiServer server(80);
WiFiClient client;

void setup() 
{
  Serial.begin(115200);
  pinMode(pin, OUTPUT);

  delay(10);

  //Connect WiFi
  enable_WiFi();
  connect_WiFi();
  server.begin();
  printWifiStatus();

  //Initialise Strip
  strip.begin();
  strip.show();
}

void loop() 
{
  WiFiClient client = server.available();
  
  if (client)
  { 
    int counter = 0;
    
    Serial.println("Client available");

    while(client.connected())
    {
      if(client.available())
      {
        
      //Read bytes
      char r = client.read();
      char b = client.read();
      char g = client.read();
      char a = client.read();

      //Check for Commands
      if(a == 'b')
      {
        strip.setBrightness(r);
        strip.show();
        counter = 0;
      }
      else if (a == 'c')
      {
        strip.clear();
        strip.show();
        counter = 0;
      }
        else
        {
          if(counter < strip.numPixels())
          {
            strip.setPixelColor(counter, strip.Color(r,b,g));
          }
  
          if(counter < strip.numPixels() - 1)
          {
            counter++;
          } 
          else
          {
            strip.show();
            counter = 0;
          }
        }
      } 
    }
  }
  
  client.stop();
}

//TCPIP Config
void enable_WiFi() 
{
  String fv = WiFi.firmwareVersion();
  if (fv < "1.0.0") 
  {
    Serial.println("Please upgrade the firmware");
  }
}

void connect_WiFi() 
{
    while (status != WL_CONNECTED) 
    {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    status = WiFi.begin(ssid, pass);

    delay(5000);
    }
}

void printWifiStatus() 
{
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());
  
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}
