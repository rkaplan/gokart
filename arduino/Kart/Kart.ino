
/*

Copyright (c) 2012, 2013 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>
#include <Servo.h>

#define MOTOR_LEFT         9
#define MOTOR_RIGHT        10

#define L_AC               4
#define L_AC2              5

#define M1_IN     A0
#define M2_IN     A1
#define L_AC_IN   A2

#define accelerationSpeed 10
#define decelerationSpeed 50

#define THROTTLETIMER 2
//The smaller the timer, the faster the car accelerates.
#define THROTTLE_MIN  1000
#define THROTTLE_MAX  2000

uint8_t timer;
short rotation;     //init rotation at 0. - for Left, + for right.
int throttle;
Servo left;
Servo right;

void setup()
{
  // Default pins set to 9 and 8 for REQN and RDYN
  // Set your REQN and RDYN here before ble_begin() if you need
  //ble_set_pins(3, 2);

  // Set your BLE Shield name here, max. length 10
  //ble_set_name("My Shield");

  // Init. and start BLE library.
  ble_begin();

  // Enable serial debug
  Serial.begin(57600);
  pinMode(L_AC, OUTPUT);
  pinMode(L_AC2, OUTPUT);
  rotation = 0;
  throttle = THROTTLE_MIN;
  left.attach(MOTOR_LEFT);
  right.attach(MOTOR_RIGHT);
  /*pinMode(DIGITAL_OUT_PIN, OUTPUT);
  pinMode(DIGITAL_IN_PIN, INPUT);*/

  // Default to internally pull high, change it if you need
  timer = 0;
}




void loop()
{
  ble_do_events();
  timer = timer>=THROTTLETIMER?THROTTLETIMER:timer+1;

  if (!ble_connected()) {
    throttle = THROTTLE_MIN;
    process_throttle_and_rotation();
    return;
  }

  // If data is ready
  while(ble_available())
  {
    // read out command and data
    byte data0 = ble_read();
    byte data1 = ble_read();
    byte data2 = ble_read();

    if (data0 == 0x01) { // GO
      Serial.println("Go: ");
      if(timer == THROTTLETIMER){
        int new_throttle = throttle + accelerationSpeed;
        if (new_throttle < throttle) throttle = THROTTLE_MAX; // Overflow
        else if (new_throttle > THROTTLE_MAX) throttle = THROTTLE_MAX;
        else throttle = new_throttle;
        timer = 0;
      }
      Serial.println(throttle);
    }
    else if (data0 == 0x02) { //
      Serial.println("Stop: ");
      decelerate();
      Serial.println(throttle);
    }
    else if (data0 == 0x03) {
        short temp = data1;
        temp <<= 8;
        short temp2 = data2;
        rotation = temp + temp2;
        //Serial.println(data1);
        //Serial.println(data2);
        //Serial.println(rotation);

    }
    else if (data0 == 0x04) {
      Serial.println("Disconnect command received");
        throttle = THROTTLE_MIN;
    }
  }

  process_throttle_and_rotation();
  
  //Read from ARDUINO pins the Motor control and linear actuator readouts.
  //Write the information to the bluetooth.

  //Junk code for reference:
/*
    // Read and send out
    uint16_t value = analogRead(ANALOG_IN_PIN);
    ble_write(0x0B);
    ble_write(value >> 8);
    ble_write(value);

  // If digital in changes, report the state
  if (digitalRead(DIGITAL_IN_PIN) != old_state)
  {
    old_state = digitalRead(DIGITAL_IN_PIN);

    if (digitalRead(DIGITAL_IN_PIN) == HIGH)
    {
      ble_write(0x0A);
      ble_write(0x01);
      ble_write(0x00);
    }
    else
    {
      ble_write(0x0A);
      ble_write(0x00);
      ble_write(0x00);
    }
  }

  if (!ble_connected())
  {
    analog_enabled = false;
    digitalWrite(DIGITAL_OUT_PIN, LOW);
  }*/

  // Allow BLE Shield to send/receive data
  // ble_do_events();
}

void decelerate() {
  if(timer == THROTTLETIMER){
    int new_throttle = throttle - decelerationSpeed;
    if (new_throttle > throttle) throttle = THROTTLE_MIN;
    else if (new_throttle < THROTTLE_MIN) throttle = THROTTLE_MIN;
    else throttle = new_throttle;
    timer = 0;
  }
}

void process_throttle_and_rotation() {
  left.writeMicroseconds(throttle);
  right.writeMicroseconds(throttle);

  //Write something for the Linear actuator pins. depending on the steering value.
  int potentiometer = analogRead(A4);
  //Serial.println(potentiometer);
  if(rotation > potentiometer){
    digitalWrite(L_AC, HIGH);
    digitalWrite(L_AC2, LOW);
  }else{
    digitalWrite(L_AC2, HIGH);
    digitalWrite(L_AC, LOW);
  }
}
