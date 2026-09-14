const mqtt = require('mqtt');
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// connect to firebase
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://accessx-afc83-default-rtdb.firebaseio.com',
});

const db = admin.database();

// connect to mosquitto
const client = mqtt.connect('mqtt://localhost:1883');

client.on('connect', () => {
  client.subscribe('accessx/headband/gesture');
  client.subscribe('accessx/headband/status');
  console.log('Bridge running — waiting for data...');
});

client.on('message', async (topic, message) => {
  try {
    const data = JSON.parse(message.toString());

    // only save gestures to firebase — not status
    if (topic === 'accessx/headband/gesture') {
      await db.ref('iot_gestures').push({
        gesture: data.gesture,
        topic: topic,
        timestamp: Date.now(),
        deviceId: 'esp32_headband',
      });
      console.log('Saved gesture to Firebase:', data.gesture);
    }

    if (topic === 'accessx/headband/status') {
      console.log('Device status:', data.device_status);
    }

  } catch (e) {
    console.log('Error:', e.message);
  }
});

client.on('error', (err) => {
  console.log('MQTT error:', err.message);
});
