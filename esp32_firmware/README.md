# ESP32 Firmware

Responsible for:

- Sensor acquisition
- GPS tracking
- Motor control
- LED control
- HTTP API hosting
- Communication with Flutter application

## Sensors

- MQ2
- DHT11
- Sound Sensor
- NEO-6M GPS

# Wiring Details

## ESP32 Connections

### MQ2 Gas Sensor

| MQ2 Pin | ESP32 Pin |
|----------|-----------|
| AO | GPIO34 |
| VCC | 5V |
| GND | GND |

---

### DHT11 Sensor

| DHT11 Pin | ESP32 Pin |
|------------|-----------|
| DATA | GPIO4 |
| VCC | 3.3V |
| GND | GND |

---

### Sound Sensor

| Sound Sensor Pin | ESP32 Pin |
|------------------|-----------|
| OUT | GPIO35 |
| VCC | 3.3V |
| GND | GND |

---

### NEO-6M GPS Module

| GPS Pin | ESP32 Pin |
|----------|-----------|
| TX | GPIO16 (RX2) |
| RX | GPIO17 (TX2) |
| VCC | 5V |
| GND | GND |

---

### L298N Motor Driver

| L298N Pin | ESP32 Pin |
|------------|-----------|
| IN1 | GPIO13 |
| IN2 | GPIO12 |
| IN3 | GPIO14 |
| IN4 | GPIO27 |

---

### LED Module

| LED Pin | ESP32 Pin |
|----------|-----------|
| Signal | GPIO26 |
| GND | GND |

---

### Power System

#### ESP32

Powered through USB or regulated 5V supply.

#### GPS Module

Powered from 5V rail.

#### MQ2 Sensor

Powered from 5V rail.

#### DHT11 Sensor

Powered from 3.3V rail.

#### Sound Sensor

Powered from 3.3V rail.

#### L298N Motor Driver

Powered from battery supply through motor power input.

#### Buck Converter

Used to provide a stable regulated 5V supply for ESP32 and sensors.

---

## Communication

### WiFi

ESP32 hosts an HTTP server.

Flutter application communicates through WiFi using REST API endpoints.

### UART

GPS communication uses UART2:

RX2 = GPIO16

TX2 = GPIO17

Baud Rate = 9600
## Motor Driver

L298N

## WiFi Communication

HTTP-based REST endpoints
