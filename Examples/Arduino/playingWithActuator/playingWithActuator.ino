// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  Serial.begin(57600);
}

// the loop routine runs over and over again forever:
void loop() {
  digitalWrite(4, LOW);   // turn the LED on (HIGH is the voltage level)
  digitalWrite(5, HIGH);
  for(int i = 0; i < 15; i++){
    int potentiometer = analogRead(A4);
    Serial.print(potentiometer);
    Serial.print('\n');
    delay(200);
  }
  
  digitalWrite(4, HIGH);
  digitalWrite(5, LOW);
  for(int i = 0; i < 15; i++){
    int potentiometer = analogRead(A4);
    Serial.print(potentiometer);
    Serial.print('\n');
    delay(200);
  }
}
