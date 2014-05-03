#include <Servo.h>
 
int sensor = A0;
int motor = 9;

Servo esc;
int sensorValue = 0;
 
// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communi  cation at 9600 bits per second:
  Serial.begin(9600);
  pinMode(sensor, INPUT);
  esc.attach(motor);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  sensorValue = analogRead(sensor);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  sensorValue = map(sensorValue, 0, 1023, 1000, 2000);
  // at 1032 it's still a stop
  // sensorValue * (5.0 / 1023.0);
  // print out the value you read:
  Serial.println(sensorValue);
  esc.writeMicroseconds(sensorValue);
}
