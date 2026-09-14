#include <Wire.h> //Library for I2C communication
#include <math.h> //Library for roll/pitch angle calculations
#include <WiFi.h> //Library to connect to WiFi Networks
#include <PubSubClient.h> //Library for MQTT Client

#define MPU_ADDR 0x68 //Sensor address

//new additons:
unsigned long lastGestureTime = 0;
const unsigned long GESTURE_COOLDOWN_MS = 2500;


// WiFi and MQTT settings
const char* ssid = "WIFI_NAME";
const char* password = "WIFI_PASSWORD"; 

const char* mqtt_server = "LAPTOP_IP"; 
const int   mqtt_port   = 1883;

WiFiServer telnetServer(23);
WiFiClient telnetClient;

const char* gesture_topic = "accessx/headband/gesture";
const char* status_topic = "accessx/headband/status"; // device online/offline state

const char* mqtt_client_id  = "ESP32_AccessX_01"; //ESP32 ID

WiFiClient espClient; 
PubSubClient client(espClient); //Creating an MQTT client and passing WiFiClient since MQTT needs a TCP connection


// Debug printing
unsigned long lastPrintTime = 0;
const unsigned long printInterval = 300; //How often the info prints


// Neutral timing
unsigned long neutralTimer = 0;
const unsigned long NEUTRAL_HOLD_MS = 1000; //Time for a neutral stance to hold before another gesture is allowed


// Gesture filtering
//Prventing Up/Down from triggering when head is tilted sideways, and vice versa
const float MAX_ROLL_FOR_PITCH  = 25.0;
const float MAX_PITCH_FOR_ROLL  = 8.0; //Degrees

bool gestureReady = true; //Check if a new gesture is allowed to be detected

//Defining what is characterized as neutral head position
const float NEUTRAL_BAND_ROLL  = 25.0;
const float NEUTRAL_BAND_PITCH = 15.0; //in degrees //updated


// Direction flipping
// TODO: might need to change, depending on how the headband acts during testing
const int ROLL_DIR  = -1;
const int PITCH_DIR = -1; //updated


// Raw sensor values directly from sensor
int16_t axRaw, ayRaw, azRaw, gxRaw, gyRaw, gzRaw; //in 16-bit values

float ax, ay, az; //accelerometer converted to (g-force)
float gx, gy, gz; //gyro convrted to (degrees/sec)

float accRoll, accPitch; //accelerometer Roll/Pitch 
float roll = 0.0, pitch = 0.0; //smooth angles

// Calibration offsets for neutral head poisition
float rollOffset = 0.0;
float pitchOffset = 0.0;

// Computing how much time has passed between sensor updates
unsigned long prevTime = 0;
float dt = 0.0; //Time difference between sensor updates

// Gesture thresholds to define how far the head must move to count as a gesture
const float ROLL_THRESHOLD   = 40.0; // TODO: might need to bump this up later, depending on person testing
const float PITCH_UP_TH      = -18.0;
const float PITCH_DOWN_TH    = 18.0; //updated


// WiFi / MQTT helpers
void setup_wifi() {
  Serial.println("Connecting to WiFi...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi connected!");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());
}

void reconnectMQTT() {
  while (!client.connected()) {
    Serial.print("Connecting to MQTT broker... ");

    bool connected =
    client.connect(
      mqtt_client_id, 
      NULL, NULL, 
      status_topic, 1,
      true, "{\"device_status\":\"disconnected\"}"); //LWT, will publish if smth happens to ESP32

    if (connected) {
      Serial.println("connected!");
      client.publish(status_topic, "{\"device_status\":\"connected\"}", true);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" -> retrying in 2 seconds");
      delay(2000);
    }
  }
}

void publishGesture(String gesture) {
  String payload = "{\"gesture\":\"" + gesture + "\"}";

  Serial.print("Publishing to topic: ");
  Serial.println(gesture_topic);
  Serial.print("Payload: ");
  Serial.println(payload);

  client.publish(gesture_topic, payload.c_str());
}


// MPU6050 helpers
void wakeMPU() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);
  Wire.write(0x00);
  Wire.endTransmission(true);
} //Writing to the power registers of the MPU to wake it

void readMPU() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);

  axRaw = (Wire.read() << 8) | Wire.read();
  ayRaw = (Wire.read() << 8) | Wire.read();
  azRaw = (Wire.read() << 8) | Wire.read();

  // Skip temperature bytes
  Wire.read();
  Wire.read();

  gxRaw = (Wire.read() << 8) | Wire.read();
  gyRaw = (Wire.read() << 8) | Wire.read();
  gzRaw = (Wire.read() << 8) | Wire.read();
}

void convertUnits() { 
  ax = axRaw / 16384.0;
  ay = ayRaw / 16384.0;
  az = azRaw / 16384.0; // 1g = 16384 units

  gx = gxRaw / 131.0;
  gy = gyRaw / 131.0;
  gz = gzRaw / 131.0; // 1 d/s = 131 raw units

  //Values 16384 and 131 come from the MPU datasheet
}

void computeAccelAngles() {
  accRoll  = atan2(ay, az) * 180.0 / PI;
  accPitch = atan2(-ax, sqrt(ay * ay + az * az)) * 180.0 / PI;
}

//Combining the gyro and accelerometer
void updateComplementaryFilter() {
  unsigned long now = millis();
  dt = (now - prevTime) / 1000.0;
  prevTime = now;

  if (dt <= 0 || dt > 0.5) dt = 0.01;

  // 98% gyro for smoothness, 2% accelerometer to prevent long-term drift
  roll  = 0.98 * (roll + gx * dt) + 0.02 * accRoll;
  pitch = 0.98 * (pitch + gy * dt) + 0.02 * accPitch;
}

void calibrateNeutral() {
  const int samples = 200;
  float rollSum = 0.0;
  float pitchSum = 0.0;

  Serial.println("Keep head straight and still... calibrating in 3 seconds");
  delay(3000);

  for (int i = 0; i < samples; i++) {
    readMPU();
    convertUnits();
    computeAccelAngles();

    rollSum  += accRoll;
    pitchSum += accPitch;
    delay(10);
  }

  rollOffset  = rollSum / samples;
  pitchOffset = pitchSum / samples;

  roll  = rollOffset;
  pitch = pitchOffset;

  Serial.println("Calibration done.");
  Serial.print("rollOffset = ");
  Serial.println(rollOffset);
  Serial.print("pitchOffset = ");
  Serial.println(pitchOffset);
}


// Gesture detection
String detectGesture(float relRoll, float relPitch) {

  // Cooldown
  if (millis() - lastGestureTime < GESTURE_COOLDOWN_MS) {
    return "NONE";
  }

  // Checking if ready for a new gesture
  if (!gestureReady) {

    if (abs(relRoll) < NEUTRAL_BAND_ROLL &&
        abs(relPitch) < NEUTRAL_BAND_PITCH) {

      if (neutralTimer == 0) {
        neutralTimer = millis();
      }

      // Ensure head returned to neutral
      if (millis() - neutralTimer >= NEUTRAL_HOLD_MS) {
        gestureReady = true;
        neutralTimer = 0;
      }

    } else {
      neutralTimer = 0;
      return "NONE";
    }

    if (!gestureReady) return "NONE";
  }

  // UP / DOWN
  if (abs(relRoll) < MAX_ROLL_FOR_PITCH) {

    if (relPitch <= PITCH_UP_TH) {
      gestureReady = false;
      neutralTimer = 0;
      lastGestureTime = millis();
      return "UP";
    }

    if (relPitch >= PITCH_DOWN_TH) {
      gestureReady = false;
      neutralTimer = 0;
      lastGestureTime = millis();
      return "DOWN";
    }
  }

  // LEFT / RIGHT
  if (abs(relPitch) < MAX_PITCH_FOR_ROLL) {

    if (relRoll >= ROLL_THRESHOLD) {
      gestureReady = false;
      neutralTimer = 0;
      lastGestureTime = millis();
      return "LEFT";
    }

    if (relRoll <= -ROLL_THRESHOLD) {
      gestureReady = false;
      neutralTimer = 0;
      lastGestureTime = millis();
      return "RIGHT";
    }
  }

  return "NONE";
}

void handleTelnet() {
  if (telnetServer.hasClient()) {
    telnetClient = telnetServer.available();
    Serial.println("Telnet client connected");
  }
}

void telnetPrintln(String msg) {
  Serial.println(msg);

  if (telnetClient && telnetClient.connected()) {
    telnetClient.println(msg);
  }
}

// Setup / Loop
void setup() {
  Serial.begin(9600);
  Wire.begin(21, 22);

  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);

  telnetServer.begin();
  Serial.println("Telnet server started");

  wakeMPU();
  delay(100);

  readMPU();
  convertUnits();
  computeAccelAngles();

  prevTime = millis();
  calibrateNeutral();

  Serial.println("MPU6050 gesture test started.");
  Serial.println("Columns: relRoll, relPitch, gesture");
}

void loop() {

  handleTelnet();
   
  if (WiFi.status() != WL_CONNECTED){
    setup_wifi();
    prevTime = millis(); // reset clock so reconnect delay doesn't confuse the filter
  }
  if (!client.connected()){
    reconnectMQTT();
    prevTime = millis();
  }
  client.loop();

  readMPU();
  convertUnits();
  computeAccelAngles();
  updateComplementaryFilter();

  float relRoll  = ROLL_DIR  * (roll  - rollOffset);
  float relPitch = PITCH_DIR * (pitch - pitchOffset);

  String gesture = detectGesture(relRoll, relPitch);

  unsigned long now = millis();

  if (gesture != "NONE") {
    Serial.print("GESTURE -> ");
    Serial.print(gesture);
    Serial.print(" | relRoll: ");
    Serial.print(relRoll, 2);
    Serial.print(" | relPitch: ");
    Serial.println(relPitch, 2);

    telnetPrintln(
    "GESTURE -> " + gesture +
    " | relRoll: " + String(relRoll, 2) +
    " | relPitch: " + String(relPitch, 2)
    );

    publishGesture(gesture);
  }
  else if (now - lastPrintTime >= printInterval) {
    Serial.print("relRoll: ");
    Serial.print(relRoll, 2);
    Serial.print(" | relPitch: ");
    Serial.print(relPitch, 2);
    Serial.print(" | ready: ");
    Serial.println(gestureReady ? "YES" : "NO");

    telnetPrintln(
    "relRoll: " + String(relRoll, 2) +
    " | relPitch: " + String(relPitch, 2) +
    " | ready: " + String(gestureReady ? "YES" : "NO")
    );

    lastPrintTime = now;
  }

  delay(20);
}
