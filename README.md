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

