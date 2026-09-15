# AccessX

**Head-Motion Wearable Interface for Hands-Free Hospital App Navigation**

AccessX lets people with limited or no hand mobility (e.g., quadriplegia, ALS, or temporary limb limitations) control **AccessCare** — a hospital services app — using simple head gestures. A lightweight headband detects head movement and translates it into navigation commands, sent wirelessly to the app in real time.

AI Hackathon for People with Disabilities · King Salman Center for Disability Research (KSCDR) · Riyadh 2026
Team AccessX (KSCDR_Hackathon_98) — Software Engineering Department, Alfaisal University

## How it works

1. A user wears the headband, which contains an **ESP32** microcontroller and an **MPU6050** motion sensor.
2. The ESP32 samples accelerometer/gyroscope data at 10Hz and feeds a rolling 2-second window into a **trained Edge Impulse neural network** running on-device, which classifies the movement as **UP / DOWN / LEFT / RIGHT / IDLE**. A complementary filter also runs alongside it for roll/pitch debugging.
3. Once the AI model accepts a gesture above its confidence threshold, it's published over **MQTT** to a Mosquitto broker.
4. A **Node.js bridge script** forwards the gesture to **Firebase** for logging, and the **Flutter app** subscribes to the same MQTT topic and turns the gesture into a navigation action.
5. The user sees the result live in AccessCare — moving between items, selecting, or going back — entirely hands-free.

| Gesture | Action |
|---|---|
| Left tilt | Previous |
| Right tilt | Next |
| Downward nod | Select |
| Upward tilt | Back |

## Repository structure

```
AccessX/
├── mobile-app/       # Flutter/Dart source for the AccessCare app
├── esp32-firmware/   # Arduino (C++) sketch for the headband — gesture detection
└── mqtt-bridge/       # Node.js script forwarding MQTT gesture messages to Firebase
```

## Getting started

### Mobile app (`mobile-app/`)
Built with Flutter and Dart.
```
cd mobile-app
flutter pub get
flutter run
```
Requires a Firebase project connected (see [Firebase](#firebase) below) for authentication and user data.

### ESP32 firmware (`esp32-firmware/`)
Built with the Arduino IDE, using the `Wire` library for I2C communication with the MPU6050, and a trained **Edge Impulse** model for on-device gesture classification.
1. Install the exported Edge Impulse Arduino library for this project (`AccessX_Gesture_Recognition_inferencing`) via Arduino IDE → Sketch → Include Library → Add .ZIP Library.
2. Open `esp32-firmware/AccessX_Gesture_Recognition.ino` in the Arduino IDE.
3. Replace the placeholder values at the top of the sketch — `WIFI_NAME`, `WIFI_PASSWORD`, and `LAPTOP_IP` (the IP address of the machine running the Mosquitto broker) — with your actual network details. These are left as placeholders in this repo on purpose.
4. Select your ESP32 board and port, then upload.
5. On startup, keep the headband still for a few seconds — the firmware calibrates a neutral head position before gesture detection begins.
6. A Telnet server also runs on the ESP32 (port 23) for wireless debug output, as an alternative to the Serial monitor.

### MQTT bridge (`mqtt-bridge/`)
A Node.js script that subscribes to the gesture topic on the Mosquitto broker and forwards messages to Firebase for logging.
```
cd mqtt-bridge
npm install
node bridge.js
```
Requires a running Mosquitto broker reachable by both the ESP32 and this script.

This script needs a Firebase service account key (`serviceAccountKey.json`) to authenticate with Firebase. That file is **not included** in this repo, since it grants full access to the Firebase project. To run the bridge yourself:
1. Generate your own key from the Firebase Console → Project Settings → Service Accounts → Generate new private key.
2. Save it as `mqtt-bridge/serviceAccountKey.json` (this exact filename is already git-ignored).

### Firebase
This project uses **Firebase Realtime Database** for:
- User authentication and profile data (name, email, phone, appointments)
- Logging of detected head gestures for debugging and history

The database export/config file isn't included in this repo, since it contains user records from testing. To run the project yourself, connect your own Firebase project and update the credentials referenced in `mobile-app/` and `mqtt-bridge/`.

## Tech stack

- **Mobile app:** Flutter, Dart, Figma (design)
- **Wearable:** ESP32, MPU6050 (6-axis IMU), Arduino/C++, Edge Impulse (on-device gesture classification model)
- **Communication:** MQTT (Mosquitto broker)
- **Backend:** Firebase (Authentication, Realtime Database)
- **Bridge:** Node.js

## Team

- Mays Altaleb
- Sara Abbara
- Dana Alobaidan
- Maha Shaheen
- Norah Alreshoodi

Software Engineering Department, College of Engineering and Advanced Computing, Alfaisal University, Riyadh, Saudi Arabia

## Contact

Mays Altaleb — maltaleb@alfaisal.edu
