#include <Wire.h> //Library for I2C communication
#include <math.h> //Library for roll/pitch angle calculations
#include <WiFi.h> //Library to connect to WiFi Networks
#include <PubSubClient.h> //Library for MQTT Client
#include <string.h>

//Library for the trained Edge Impulse AI model
#include <AccessX_Gesture_Recognition_inferencing.h>

#define MPU_ADDR 0x68 //Sensor address
// AI SETTINGS
//AI model settings: 2 second window at 10Hz using 6 MPU6050 values
const size_t AI_AXES = 6;
const size_t AI_WINDOW_SAMPLES = EI_CLASSIFIER_RAW_SAMPLE_COUNT;
const size_t AI_FRAME_SIZE = EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE;

//Run AI prediction every 500ms using the latest 2 second window
const size_t AI_INFERENCE_STRIDE_SAMPLES = 5;

//Minimum AI confidence needed to accept a gesture
const float AI_CONFIDENCE_THRESHOLD = 0.60;

//Change to true to print all AI probabilities
const bool PRINT_AI_PROBABILITIES = false;

float aiFeatures[EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE];

size_t aiSamplesCollected = 0;
size_t aiSamplesSinceInference = 0;

unsigned long nextAISampleMicros = 0;

String lastAIPrediction = "WAITING";
float lastAIConfidence = 0.0;

//Gesture control
unsigned long lastGestureTime = 0;
const unsigned long GESTURE_COOLDOWN_MS = 2500;

//Wait for IDLE before allowing another gesture
unsigned long neutralTimer = 0;
const unsigned long NEUTRAL_HOLD_MS = 1000;
bool gestureReady = true;
//WiFi and MQTT settings
const char* ssid = "WIFI_NAME";
const char* password = "WIFI_PASSWORD";

const char* mqtt_server = "LAPTOP_IP"; //IP address of the machine running the Mosquitto broker
const int mqtt_port = 1883;

WiFiServer telnetServer(23);
WiFiClient telnetClient;

const char* gesture_topic = "accessx/headband/gesture";
const char* status_topic = "accessx/headband/status";

const char* mqtt_client_id = "ESP32_AccessX_01";

WiFiClient espClient;
PubSubClient client(espClient);
//Debug printing
unsigned long lastPrintTime = 0;
const unsigned long printInterval = 300;
//Raw MPU6050 values
int16_t axRaw, ayRaw, azRaw, gxRaw, gyRaw, gzRaw;

float ax, ay, az;
float gx, gy, gz;

float accRoll, accPitch;
float roll = 0.0, pitch = 0.0;

float rollOffset = 0.0;
float pitchOffset = 0.0;

unsigned long prevTime = 0;
float dt = 0.0;
//WiFi / MQTT helpers
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
        true, "{\"device_status\":\"disconnected\"}"
      );

    if (connected) {
      Serial.println("connected!");
      client.publish(
        status_topic,
        "{\"device_status\":\"connected\"}",
        true
      );
    }
    else {
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

  //Publishing the detected gesture using the same MQTT topic
  client.publish(gesture_topic, payload.c_str());
}
//MPU6050 helpers
void wakeMPU() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);
  Wire.write(0x00);
  Wire.endTransmission(true);
}

void readMPU() {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);

  if (Wire.available() < 14) {
    return;
  }

  axRaw = (Wire.read() << 8) | Wire.read();
  ayRaw = (Wire.read() << 8) | Wire.read();
  azRaw = (Wire.read() << 8) | Wire.read();

  //Skip temperature bytes
  Wire.read();
  Wire.read();

  gxRaw = (Wire.read() << 8) | Wire.read();
  gyRaw = (Wire.read() << 8) | Wire.read();
  gzRaw = (Wire.read() << 8) | Wire.read();
}

void convertUnits() {
  //Convert to the same units used during AI training
  ax = axRaw / 16384.0;
  ay = ayRaw / 16384.0;
  az = azRaw / 16384.0;

  gx = gxRaw / 131.0;
  gy = gyRaw / 131.0;
  gz = gzRaw / 131.0;
}
//Roll and pitch are kept for debugging; AI uses ax, ay, az, gx, gy, gz
void computeAccelAngles() {
  accRoll = atan2(ay, az) * 180.0 / PI;
  accPitch = atan2(
    -ax,
    sqrt(ay * ay + az * az)
  ) * 180.0 / PI;
}

void updateComplementaryFilter() {
  unsigned long now = millis();

  dt = (now - prevTime) / 1000.0;
  prevTime = now;

  if (dt <= 0 || dt > 0.5) {
    dt = 0.01;
  }

  roll =
    0.98 * (roll + gx * dt) +
    0.02 * accRoll;

  pitch =
    0.98 * (pitch + gy * dt) +
    0.02 * accPitch;
}

void calibrateNeutral() {
  const int samples = 200;

  float rollSum = 0.0;
  float pitchSum = 0.0;

  Serial.println(
    "Keep head straight and still... calibrating in 3 seconds"
  );

  delay(3000);

  for (int i = 0; i < samples; i++) {
    readMPU();
    convertUnits();
    computeAccelAngles();

    rollSum += accRoll;
    pitchSum += accPitch;

    delay(10);
  }

  rollOffset = rollSum / samples;
  pitchOffset = pitchSum / samples;

  roll = rollOffset;
  pitch = pitchOffset;

  Serial.println("Calibration done.");
  Serial.print("rollOffset = ");
  Serial.println(rollOffset);

  Serial.print("pitchOffset = ");
  Serial.println(pitchOffset);
}
//AI gesture detection
void resetAIBuffer() {
  aiSamplesCollected = 0;
  aiSamplesSinceInference = 0;

  memset(
    aiFeatures,
    0,
    sizeof(aiFeatures)
  );

  nextAISampleMicros =
    micros() +
    ((unsigned long)EI_CLASSIFIER_INTERVAL_MS * 1000UL);
}

void storeSixValues(
  size_t index,
  float sax,
  float say,
  float saz,
  float sgx,
  float sgy,
  float sgz
) {
  aiFeatures[index + 0] = sax;
  aiFeatures[index + 1] = say;
  aiFeatures[index + 2] = saz;
  aiFeatures[index + 3] = sgx;
  aiFeatures[index + 4] = sgy;
  aiFeatures[index + 5] = sgz;
}

bool runAIClassifier(
  String &prediction,
  float &confidence
) {
  signal_t signal;

  int err = numpy::signal_from_buffer(
    aiFeatures,
    EI_CLASSIFIER_DSP_INPUT_FRAME_SIZE,
    &signal
  );

  if (err != 0) {
    Serial.print("AI signal error: ");
    Serial.println(err);
    return false;
  }

  ei_impulse_result_t result = {0};

  err = run_classifier(
    &signal,
    &result,
    false
  );

  if (err != EI_IMPULSE_OK) {
    Serial.print("AI classifier error: ");
    Serial.println(err);
    return false;
  }

  float bestConfidence = 0.0;
  const char* bestLabel = "UNCERTAIN";

  if (PRINT_AI_PROBABILITIES) {
    Serial.println("AI probabilities:");
  }

  for (
    size_t i = 0;
    i < EI_CLASSIFIER_LABEL_COUNT;
    i++
  ) {
    float value =
      result.classification[i].value;

    if (PRINT_AI_PROBABILITIES) {
      Serial.print("  ");
      Serial.print(
        result.classification[i].label
      );
      Serial.print(": ");
      Serial.print(value * 100.0, 1);
      Serial.println("%");
    }

    if (value > bestConfidence) {
      bestConfidence = value;
      bestLabel =
        result.classification[i].label;
    }
  }

  confidence = bestConfidence;

  if (
    bestConfidence <
    AI_CONFIDENCE_THRESHOLD
  ) {
    prediction = "UNCERTAIN";
  }
  else {
    prediction = String(bestLabel);
  }

  return true;
}

void handleAIPrediction(
  String prediction,
  float confidence
) {
  lastAIConfidence = confidence;

  //After a gesture is accepted, ignore all AI predictions during the cooldown
  if (!gestureReady) {

    if (millis() - lastGestureTime < GESTURE_COOLDOWN_MS) {
      lastAIPrediction = "LOCKED";
      neutralTimer = 0;
      return;
    }

    //After the cooldown, IDLE or UNCERTAIN both mean no gesture is being made
    if (prediction == "IDLE" || prediction == "UNCERTAIN") {

      lastAIPrediction = "WAITING_NEUTRAL";

      if (neutralTimer == 0) {
        neutralTimer = millis();
      }

      //Require a stable neutral/no-gesture period before allowing another gesture
      if (millis() - neutralTimer >= NEUTRAL_HOLD_MS) {
        gestureReady = true;
        neutralTimer = 0;
        lastAIPrediction = "IDLE";

        Serial.println("AI: neutral confirmed -> ready for next gesture");

        if (telnetClient && telnetClient.connected()) {
          telnetClient.println("AI: neutral confirmed -> ready for next gesture");
        }
      }
    }
    else {
      //A confident gesture during the neutral period means the head is still moving
      neutralTimer = 0;
      lastAIPrediction = "WAITING_NEUTRAL";
    }

    return;
  }

  //When ready, show the current AI result
  lastAIPrediction = prediction;

  //IDLE and UNCERTAIN never trigger a command
  if (prediction == "IDLE" || prediction == "UNCERTAIN") {
    return;
  }

  //Do not block the first gesture after startup
  if (
    lastGestureTime != 0 &&
    millis() - lastGestureTime < GESTURE_COOLDOWN_MS
  ) {
    return;
  }

  //Only the four AccessX gestures are accepted
  if (
    prediction == "LEFT" ||
    prediction == "RIGHT" ||
    prediction == "UP" ||
    prediction == "DOWN"
  ) {
    gestureReady = false;
    neutralTimer = 0;
    lastGestureTime = millis();

    Serial.println();
    Serial.print("AI GESTURE -> ");
    Serial.print(prediction);
    Serial.print(" | confidence: ");
    Serial.print(confidence * 100.0, 1);
    Serial.println("%");

    telnetPrintln(
      "AI GESTURE -> " +
      prediction +
      " | confidence: " +
      String(confidence * 100.0, 1) +
      "%"
    );

    publishGesture(prediction);
  }
}

void addCurrentReadingToAI() {
  //First fill the 2 second AI window
  if (
    aiSamplesCollected <
    AI_WINDOW_SAMPLES
  ) {
    size_t index =
      aiSamplesCollected * AI_AXES;

    storeSixValues(
      index,
      ax, ay, az,
      gx, gy, gz
    );

    aiSamplesCollected++;

    //Run AI when the first full window is ready
    if (
      aiSamplesCollected ==
      AI_WINDOW_SAMPLES
    ) {
      String prediction;
      float confidence;

      if (
        runAIClassifier(
          prediction,
          confidence
        )
      ) {
        handleAIPrediction(
          prediction,
          confidence
        );
      }

      aiSamplesSinceInference = 0;
    }

    return;
  }
  // Sliding 2-second window
  // Remove oldest 6 values,
  // then append newest 6 values.
  memmove(
    aiFeatures,
    aiFeatures + AI_AXES,
    (AI_FRAME_SIZE - AI_AXES) *
      sizeof(float)
  );

  size_t endIndex =
    AI_FRAME_SIZE - AI_AXES;

  storeSixValues(
    endIndex,
    ax, ay, az,
    gx, gy, gz
  );

  aiSamplesSinceInference++;

  //New AI prediction every 500ms
  if (
    aiSamplesSinceInference >=
    AI_INFERENCE_STRIDE_SAMPLES
  ) {
    aiSamplesSinceInference = 0;

    String prediction;
    float confidence;

    if (
      runAIClassifier(
        prediction,
        confidence
      )
    ) {
      handleAIPrediction(
        prediction,
        confidence
      );
    }
  }
}

void updateAIAtModelFrequency() {
  unsigned long nowMicros = micros();

  if (
    (long)(
      nowMicros -
      nextAISampleMicros
    ) >= 0
  ) {
    //Use the sampling interval stored in the AI model
    nextAISampleMicros =
      nowMicros +
      ((unsigned long)
        EI_CLASSIFIER_INTERVAL_MS *
        1000UL);

    addCurrentReadingToAI();
  }
}
//Telnet helpers
void handleTelnet() {
  if (telnetServer.hasClient()) {
    telnetClient =
      telnetServer.available();

    Serial.println(
      "Telnet client connected"
    );
  }
}

void telnetPrintln(String msg) {
  Serial.println(msg);

  if (
    telnetClient &&
    telnetClient.connected()
  ) {
    telnetClient.println(msg);
  }
}
//Setup
void setup() {
  Serial.begin(9600);
  Wire.begin(21, 22);

  setup_wifi();

  client.setServer(
    mqtt_server,
    mqtt_port
  );

  telnetServer.begin();
  Serial.println(
    "Telnet server started"
  );

  wakeMPU();
  delay(100);

  readMPU();
  convertUnits();
  computeAccelAngles();

  prevTime = millis();

  //Calibration is kept for roll/pitch debugging only
  calibrateNeutral();

  resetAIBuffer();

  Serial.println();
  Serial.println(
    "AccessX AI gesture system started."
  );

  Serial.print(
    "AI sample interval: "
  );
  Serial.print(
    EI_CLASSIFIER_INTERVAL_MS
  );
  Serial.println(" ms");

  Serial.print(
    "AI window samples: "
  );
  Serial.println(
    EI_CLASSIFIER_RAW_SAMPLE_COUNT
  );

  Serial.print(
    "AI confidence threshold: "
  );
  Serial.println(
    AI_CONFIDENCE_THRESHOLD
  );
}
//Loop
void loop() {
  handleTelnet();

  if (
    WiFi.status() !=
    WL_CONNECTED
  ) {
    setup_wifi();

    //Restart the AI window after reconnecting
    resetAIBuffer();

    prevTime = millis();
  }

  if (!client.connected()) {
    reconnectMQTT();

    resetAIBuffer();

    prevTime = millis();
  }

  client.loop();

  //Read MPU6050 values
  readMPU();
  convertUnits();

  //Send the raw sensor values to the AI at 10Hz
  updateAIAtModelFrequency();

  //Update roll/pitch for debugging
  computeAccelAngles();
  updateComplementaryFilter();

  float relRoll =
    roll - rollOffset;

  float relPitch =
    pitch - pitchOffset;

  unsigned long now = millis();

  //Print debug information
  if (
    now - lastPrintTime >=
    printInterval
  ) {
    Serial.print("AI state: ");
    Serial.print(lastAIPrediction);

    Serial.print(" | conf: ");
    Serial.print(
      lastAIConfidence * 100.0,
      1
    );
    Serial.print("%");

    Serial.print(" | relRoll: ");
    Serial.print(relRoll, 2);

    Serial.print(" | relPitch: ");
    Serial.print(relPitch, 2);

    Serial.print(" | ready: ");
    Serial.println(
      gestureReady ?
      "YES" :
      "NO"
    );

    if (
      telnetClient &&
      telnetClient.connected()
    ) {
      telnetClient.println(
        "AI state: " +
        lastAIPrediction +
        " | conf: " +
        String(
          lastAIConfidence *
          100.0,
          1
        ) +
        "%" +
        " | relRoll: " +
        String(relRoll, 2) +
        " | relPitch: " +
        String(relPitch, 2) +
        " | ready: " +
        String(
          gestureReady ?
          "YES" :
          "NO"
        )
      );
    }

    lastPrintTime = now;
  }

  delay(20);
}
