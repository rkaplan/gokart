# Software to control an electric go-kart
Divided into 2 master directories (arduino, app).

### arduino
This software runs on our Arduino microcontroller. It operates and checks the status of various go-kart parts (e.g. motors, battery, and linear actuator). It also communicates with a smartphone via bluetooth shield.

To use: (1) Download this repository (2) Copy (or move) the files under the directory "arduino/libraries" to the "libraries" directory inside your Arduino IDE directory (3) Open the Arduino IDE, and select "Examples" from the "File" menu (4) enjoy.

### app
This software runs on your smartphone **. It allows you to drive, break, steer, and power-on/off the electric go-kart from a Graphical User Interface.

Footnotes:
\* We extend RedBearLabs open-software (github.com/RedBearLab)

\*\* Our Go-Kart uses the Bluetooth Low Energy 4.0 Shield by RedBearLab (redbearlab.com/bleshield)
which only supports iPhone 4s/5 (iOS 6 & 7), & Android 4.1.
