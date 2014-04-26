#include <Servo.h>
 
Servo esc;
int throttlePin = A0;
 
void setup()
{
  Serial.begin(9600);
  esc.attach(6);
}
 
void loop()
{
  int throttle = analogRead(throttlePin);
  throttle = map(throttle, 0, 1023, 0, 179);
  Serial.println(throttle);
  esc.write(throttle);
}
