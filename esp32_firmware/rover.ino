#include <WiFi.h>
#include <WebServer.h>
#include <DHT.h>
#include <TinyGPS++.h>

// ---------------- WIFI ----------------
const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

// ---------------- SERVER ----------------
WebServer server(80);

// ---------------- PINS ----------------
#define MQ2_PIN 34
#define DHT_PIN 4
#define DHTTYPE DHT11

#define IN1 13
#define IN2 26
#define IN3 14
#define IN4 27

#define LED_PIN 2

// ---------------- OBJECTS ----------------
DHT dht(DHT_PIN, DHTTYPE);
TinyGPSPlus gps;
HardwareSerial gpsSerial(2);

// ---------------- VARIABLES ----------------
bool ledState = false;

// MQ2 smoothing
int readMQ2() {
  long sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += analogRead(MQ2_PIN);
    delay(2);
  }
  return sum / 10;
}

// ---------------- MOTOR CONTROL ----------------
void stopMotors() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);
}

void moveForward() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
}

void moveBackward() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
}

void moveLeft() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);
}

void moveRight() {
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);
}

// ---------------- API HANDLERS ----------------

// /move?dir=forward
void handleMove() {
  if (!server.hasArg("dir")) {
    server.send(400, "text/plain", "Missing dir");
    return;
  }

  String dir = server.arg("dir");

  if (dir == "forward") moveForward();
  else if (dir == "backward") moveBackward();
  else if (dir == "left") moveLeft();
  else if (dir == "right") moveRight();

  server.send(200, "text/plain", "OK");
}

// /stop
void handleStop() {
  stopMotors();
  server.send(200, "text/plain", "STOP");
}

// /led?state=on/off
void handleLED() {
  if (!server.hasArg("state")) {
    server.send(400, "text/plain", "Missing state");
    return;
  }

  String state = server.arg("state");

  if (state == "on") {
    digitalWrite(LED_PIN, HIGH);
    ledState = true;
  } else {
    digitalWrite(LED_PIN, LOW);
    ledState = false;
  }

  server.send(200, "text/plain", "OK");
}

// /data
void handleData() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();
  int gas = readMQ2();

  double lat = 0.0;
  double lon = 0.0;

  if (gps.location.isValid() && gps.satellites.value() >= 4) {
    lat = gps.location.lat();
    lon = gps.location.lng();
  }

  String json = "{";
  json += "\"temperature\":" + String(temp) + ",";
  json += "\"humidity\":" + String(hum) + ",";
  json += "\"gas\":" + String(gas) + ",";
  json += "\"lat\":" + String(lat, 6) + ",";
  json += "\"lon\":" + String(lon, 6);
  json += "}";

  server.send(200, "application/json", json);
}

// ---------------- SETUP ----------------
void setup() {
  Serial.begin(115200);

  // Pins
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
  pinMode(LED_PIN, OUTPUT);

  stopMotors();
  dht.begin();

  // GPS
  gpsSerial.begin(9600, SERIAL_8N1, 16, 17);

  // WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nConnected!");
  Serial.println(WiFi.localIP());

  // Routes
  server.on("/move", handleMove);
  server.on("/stop", handleStop);
  server.on("/led", handleLED);
  server.on("/data", handleData);

  server.begin();
}

// ---------------- LOOP ----------------
void loop() {
  server.handleClient();

  // continuously parse GPS
  while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
  }
}
