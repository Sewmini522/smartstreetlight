💡 Smart Street Light Control and Illumination Monitoring System

An intelligent IoT-based Smart Street Light Control and Illumination Monitoring System developed using ESP32, LDR sensor, RGB LED, Street Light LED, I2C LCD, and Supabase.

The system automatically controls a street light according to the surrounding light intensity. The measured light intensity, street light status, and RGB LED condition are sent to a Supabase database every 5 seconds.

A Flutter mobile application is also developed to monitor the street light system remotely. The application retrieves data from the same Supabase database and displays the current light intensity, street light status, RGB condition, and recent readings.



📌 Project Overview

The system consists of two main parts:

Task 01 – Smart Street Light Monitoring System

The ESP32-based IoT system:

Reads ambient light intensity using an LDR sensor.

Converts the analog LDR value into a percentage.

Automatically controls the street light according to the light level.

Uses an RGB LED to indicate the current environmental condition.

Displays light intensity and street light status on a 16x2 I2C LCD.

Sends sensor data to Supabase every 5 seconds.


Task 02 – Mobile Application

A Flutter mobile application is developed to:

Connect to the same Supabase project.

Retrieve the latest street light data.

Display the current light intensity.

Display the street light ON/OFF status.

Display the current RGB condition.

Show the latest update time.

Display recent sensor readings.

Provide a manual refresh option.

Support real-time monitoring through Supabase updates.

🎯 Aims

The main aim of this project is to design and implement an intelligent street light automation and monitoring system using an ESP32 microcontroller and LDR sensor.

The system is designed to:

Automatically control street lights based on ambient light conditions.

Monitor the surrounding light intensity.

Indicate different lighting conditions using an RGB LED.

Display system information using an I2C LCD.

Store real-time sensor data in Supabase.

Provide remote monitoring through a Flutter mobile application

🛠️ Technologies and Components Used

Software and Platforms
    Arduino / C++    
    VS Code    
    PlatformIO    
    Wokwi    
    Flutter    
    Dart    
    Supabase    
    GitHub
    
Libraries
    ESP32    
    LiquidCrystal_I2C    
    ArduinoJson    
    WiFi    
    HTTPClient
    
Flutter

    supabase_flutter


💡 Light Condition Logic

The system uses the LDR sensor to determine the surrounding light intensity.    

| Light Intensity | Condition           | RGB LED         | Street Light |
| --------------- | ------------------- | --------------- | ------------ |
| > 70%           | Bright / Day        | 🟢 Green ON     | OFF          |
| 30% – 70%       | Moderate / Twilight | 🔵 Blue ON      | OFF          |
| < 30%           | Dark / Night        | 🔴 Red ON       | ON           |
| < 15%           | Very Dark           | 🔴 Red Blinking | ON           |


☁️ Supabase Integration
The ESP32 sends data to the Supabase database every 5 seconds.

The stored data includes:

Light intensity

Street light status

RGB LED state

Timestamp

📱 Flutter Mobile Application
The mobile application provides a simple dashboard for monitoring the smart street light system.

The dashboard displays:

☀️ Light Intensity

Shows the current ambient light intensity as a percentage.

💡 Street Light Status

Displays whether the street light is currently:

ON

OFF


🔴🟢🔵 Current Condition

Displays the current environmental condition using a colored indicator:

🟢 Green – Bright

🔵 Blue – Moderate

🔴 Red – Dark

🔴 Red Blinking – Very Dark

🕒 Latest Update

Displays the timestamp of the most recent sensor reading.

📊 Recent Readings

Displays the latest sensor readings retrieved from Supabase.

🔄 Refresh

Allows the user to manually refresh the latest data.


🚀 How to Run the Flutter Application
1. Clone the Repository
        git clone GITHUB_REPOSITORY_URL

2. Open the Project
Open the project in VS Code or Android Studio.

3. Install Dependencies
Run:
      flutter pub get

4. Configure Supabase
Update the Supabase project URL and anonymous API key in the Supabase service file.
      static const String _url = 'SUPABASE_URL';
      static const String _anonKey = 'SUPABASE_ANON_KEY';

5. Run the Application
For Chrome:
      flutter run -d chrome
For Android:
      flutter run


🧪 Testing

The system was tested by changing the LDR sensor values in the Wokwi simulation.

The following conditions were tested:

Bright environment
Moderate light environment
Dark environment
Very dark environment

The ESP32 successfully:

Reads the LDR sensor value.
Calculates the light intensity.
Controls the street light.
Controls the RGB LED.
Displays the information on the I2C LCD.
Sends data to Supabase.

The Flutter application retrieves the stored data and displays the monitoring information through the dashboard.


📸 Screenshots

wokwi project design:
![image](https://github.com/user/repo/assets/xxxx)<img width="1321" height="787" alt="Picture1" src="https://github.com/user-attachments/assets/77f70d5d-bd3f-4e87-8790-ce0b3efe8c4c" />

Bright (Day) → Intensity > 70% ,LED behavior: Green ON (Street light OFF)
![image](https://github.com/user/repo/assets/xxxx)<img width="1917" height="1021" alt="Picture2" src="https://github.com/user-attachments/assets/0e2bd2c3-846c-41f3-90a3-b617a5752a5d" />

Moderate (Twilight) → 30% – 70% , LED behavior: Blue ON
![image](https://github.com/user/repo/assets/xxxx)<img width="1917" height="1022" alt="Picture3" src="https://github.com/user-attachments/assets/9847cd2a-0812-4d4c-9a4a-5e8454c8d959" />

Dark (Night) → < 30% , LED behavior: Red ON (Street light ON)
![image](https://github.com/user/repo/assets/xxxx)<img width="1917" height="1015" alt="Picture4" src="https://github.com/user-attachments/assets/953bb187-2672-4eff-b387-0277921d8e91" />

Very Dark → < 15%  , LED behavior: Red BLINKING
![image](https://github.com/user/repo/assets/xxxx)<img width="1912" height="1012" alt="Picture5" src="https://github.com/user-attachments/assets/7c652bb1-3ae4-40fa-89fc-a0d7b298666d" />

Supabase screen:
![image](https://github.com/user/repo/assets/xxxx)<img width="1275" height="697" alt="Picture6" src="https://github.com/user-attachments/assets/d163e2c1-6a27-4ded-91d3-ce3b8cf59f72" />


