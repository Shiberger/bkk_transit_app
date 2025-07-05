# BKK Transit Route Finder App

A mobile application built with Flutter and Python to help users find optimal public transit routes in Bangkok, Thailand, using the BTS and MRT train systems.

## Overview

This project is a client-server application designed to provide the fastest routes or routes with the fewest transfers between any two train stations in Bangkok. The backend is a lightweight Python Flask server that handles all the data processing and pathfinding logic, while the frontend is a cross-platform Flutter application that provides a clean and interactive user interface.

## ✨ Features

  - ✅ **Route Finding:** Select a start and destination station to find the optimal route.
  - ✅ **Multi-Criteria Search:** Choose between finding the **Fastest Route** (based on time) or the route with the **Fewest Transfers**.
  - ✅ **Detailed Route Display:** View the journey broken down into clear steps, including:
      - Train lines to use (e.g., BTS Sukhumvit Line).
      - Total travel time.
      - Total number of stations.
      - Line transfer points.
      - Estimated fare.
      - Operating hours for each line.
  - ✅ **Visual Route Diagram:** A simple schematic diagram visually represents the journey's steps and transfers.
  - ✅ **Favorites System:** Save frequently used routes for quick access. Users can view, re-run, and delete saved routes.

## 🛠️ Tech Stack

### Backend

  - **Language:** Python 3
  - **Framework:** Flask
  - **WSGI Server:** Gunicorn
  - **Configuration:** python-dotenv
  - **Core Algorithm:** Dijkstra's algorithm for shortest path calculation.
  - **Data:** `database.json` for storing transit network data.

### Frontend

  - **Framework:** Flutter
  - **Language:** Dart
  - **State Management:** `StatefulWidget` (`setState`)
  - **Local Storage:** `shared_preferences` for the Favorites feature.
  - **API Communication:** `http` package.

## 🏗️ Architecture

The application follows a simple and effective client-server model:

  - **Backend API (The Brain):** A Python Flask server, run with Gunicorn, is responsible for all business logic. It reads the `database.json` file, builds a graph representation of the transit network, and runs the pathfinding algorithm based on the user's request. This keeps the frontend app lightweight.
  - **Flutter App (The Client):** The mobile app's sole responsibilities are to provide a user interface and communicate with the backend via REST API calls. It sends the user's selections (stations, preference) to the backend and beautifully displays the route result it receives.

-----

## 📖 API Design

The backend exposes two main API endpoints.

### 1\. Get All Stations

  - **Endpoint:** `GET /api/stations`
  - **Description:** Retrieves a sorted list of all available stations to populate the selection dropdowns in the app.
  - **Request Body:** None
  - **Success Response (200 OK):**
    ```json
    [
        {
            "id": "N5",
            "name": "Ari"
        },
        {
            "id": "E4",
            "name": "Asok"
        },
        ...
    ]
    ```

### 2\. Find a Route

  - **Endpoint:** `POST /api/route`
  - **Description:** The core endpoint that calculates the optimal route based on user input.
  - **Request Body:**
    ```json
    {
      "start_station_id": "N8",
      "end_station_id": "S2",
      "preference": "fastest" // or "fewest_transfers"
    }
    ```
  - **Success Response (200 OK):**
    ```json
    {
      "estimated_fare": 37,
      "steps": [
        {
          "type": "board",
          "line_name": "BTS Sukhumvit Line",
          "line_color": "#76B852",
          "operating_hours": "05:15 - 00:49",
          "start_station": "Mo Chit",
          "end_station": "Siam",
          "stops": 6
        }
      ],
      "total_stations": 8,
      "total_time": 24
    }
    ```

-----

## 🚀 Manual: Project Setup and Running

Follow these steps to get the application running on your local machine.

### Prerequisites

  - Python 3.8 or newer.
  - Flutter SDK installed.
  - A code editor like Visual Studio Code.

### 1\. Backend Setup

These steps prepare and run the backend on a production-grade server.

**A. Navigate to the Backend Directory**

```bash
cd bkk_transit_app/backend_api
```

**B. Create and Activate Virtual Environment**

```bash
# Create the environment (only needs to be done once)
python3 -m venv venv

# Activate the environment (do this every time you open a new terminal)
# On macOS/Linux:
source venv/bin/activate
# On Windows:
.\\venv\\Scripts\\activate
```

**C. Create Project Files**

1.  Create a `requirements.txt` file in the `backend_api` folder with the following content:
    ```
    Flask
    gunicorn
    python-dotenv
    ```
2.  Create a `.env` file in the `backend_api` folder. This file helps manage local settings.
    ```
    PORT=5002
    ```

**D. Install Dependencies**

```bash
pip install -r requirements.txt
```

**E. Run the Production Server**
Use this command to start the backend:

```bash
gunicorn --workers 4 --bind 0.0.0.0:5002 app:app
```

Your backend is now running on port `5002` and ready for connections. Leave this terminal window open.

### 2\. Frontend Setup

Open a **new terminal window** and follow these steps.

**A. Navigate to the Frontend Directory**

```bash
cd bkk_transit_app/frontend_flutter/transit_app_ui
```

**B. Configure the API Address**
This is a crucial step. Open `lib/services/api_service.dart` and ensure the `baseUrl` variable points to the correct address where your backend is running.

  - If running on an **iOS Simulator**:
    ```dart
    final String baseUrl = "http://127.0.0.1:5002/api";
    ```
  - If running on an **Android Emulator**:
    ```dart
    final String baseUrl = "http://10.0.2.2:5002/api";
    ```
  - If running on a **physical phone** (and your computer and phone are on the same Wi-Fi):
    ```dart
    // Replace 192.168.1.100 with your computer's actual local IP address
    final String baseUrl = "http://192.168.1.100:5002/api";
    ```

**C. Run the Flutter App**

```bash
# Get the Flutter dependencies
flutter pub get

# Run the application
flutter run
```

The BKK Transit App will now launch on your device and be fully connected to your production-style backend server.

# BKK Transit Route Finder App (Thai Ver.)

### 1\. การค้นหาเส้นทางจากสถานี A ไปยัง B

แอปพลิเคชันนี้ถูกออกแบบมาเพื่อทำหน้าที่นี้โดยเฉพาะ โดยมีส่วนประกอบหลักคือ:

  * **หน้าจอหลัก (`home_screen.dart`):** มี Dropdown ให้ผู้ใช้เลือกสถานีต้นทาง (A) และสถานีปลายทาง (B)
  * **Backend API (`app.py`):** รับข้อมูลสถานีเพื่อนำไปคำนวณเส้นทางที่เหมาะสมที่สุด
 
### 2\. การแสดงผลการค้นหา

แอปพลิเคชันแสดงผลข้อมูลตามที่กำหนดไว้อย่างครบถ้วนในหน้า `route_display_screen.dart` ดังนี้:

  * **✅ สายรถไฟที่ใช้:** ในแต่ละขั้นตอนการเดินทาง จะแสดงชื่อสายรถไฟ (เช่น "BTS Sukhumvit Line") พร้อมสีประจำสาย
  * **✅ จำนวนสถานีทั้งหมด:** แสดงผลรวมจำนวนสถานีที่ต้องเดินทางในส่วนสรุปด้านบน
  * **✅ การเปลี่ยนสาย (Transfers):** แสดงจำนวนครั้งที่ต้องเปลี่ยนสายในส่วนสรุป และแสดงเป็นขั้นตอน "Transfer" ที่ชัดเจนในรายการเดินทาง
  * **✅ เวลารวมในการเดินทาง:** แสดงผลรวมเวลาที่ใช้ในการเดินทางทั้งหมดเป็นนาทีในส่วนสรุป

### 3\. สโคปของข้อมูลสถานีและสายรถไฟ

โปรเจกต์นี้ใช้ข้อมูลแบบ Mockup ที่กำหนดขึ้นเอง ซึ่งถูกจัดเก็บไว้ในไฟล์ `backend_api/database.json` ไฟล์นี้ประกอบด้วย:

  * `stations`: รายชื่อสถานีทั้งหมดพร้อม ID
  * `lines`: ข้อมูลสายรถไฟ, สถานีในแต่ละสาย, เวลาเดินทางระหว่างสถานี และข้อมูลเพิ่มเติมอื่นๆ
  * `transfers`: ข้อมูลจุดเชื่อมต่อระหว่างสายต่างๆ

การออกแบบนี้ทำให้สามารถทดสอบและพัฒนาแอปพลิเคชันได้อย่างสะดวก โดยไม่ต้องเชื่อมต่อกับข้อมูลจริง และเป็นไปตามแนวทางที่โจทย์กำหนดคือการเน้นที่วิธีคิดและโครงสร้างของแอปพลิเคชัน

### 4\. ตัวอย่าง Request และ Response ของ API

จากไฟล์ `app.py` เรามี API ที่ออกแบบไว้ 2 ตัวหลัก ดังนี้ครับ:

#### **GET /api/stations**

  * **วัตถุประสงค์:** ดึงรายชื่อสถานีทั้งหมดเพื่อใช้ใน Dropdown ของแอปพลิเคชัน
  * **Request:**
      * `GET http://127.0.0.1:5002/api/stations`
      * ไม่มี Request Body
  * **Response (ตัวอย่าง):**
    ```json
    [
        {
            "id": "N8",
            "name": "Mo Chit"
        },
        {
            "id": "E4",
            "name": "Asok"
        },
        ...
    ]
    ```

#### **POST /api/route**

  * **วัตถุประสงค์:** ค้นหาเส้นทางที่ดีที่สุดระหว่างสองสถานี
  * **Request:**
      * `POST http://127.0.0.1:5002/api/route`
      * **Body:**
        ```json
        {
          "start_station_id": "N8",
          "end_station_id": "S2",
          "preference": "fastest"
        }
        ```
  * **Response (ตัวอย่าง):**
    ```json
    {
      "total_time": 24,
      "total_stations": 8,
      "estimated_fare": 37,
      "steps": [
        {
          "type": "board",
          "line_name": "BTS Sukhumvit Line",
          "line_color": "#76B852",
          "operating_hours": "05:15 - 00:49",
          "start_station": "Mo Chit",
          "end_station": "Siam",
          "stops": 6
        },
        {
          "type": "board",
          "line_name": "BTS Silom Line",
          "line_color": "#00885A",
          "operating_hours": "05:30 - 00:42",
          "start_station": "Siam",
          "end_station": "Sala Daeng",
          "stops": 2
        }
      ]
    }
    ```

### 5\. ฟีเจอร์เพิ่มเติม (Bonus Features)

แอปพลิเคชันนี้ได้มีการพัฒนาฟีเจอร์เพิ่มเติมจากที่กำหนดไว้หลายอย่าง เพื่อเพิ่มความสามารถและประสบการณ์การใช้งานที่ดีขึ้น:

  * **ฟีเจอร์ที่ทำเพิ่มเติมแล้ว:**

      * **ค้นหาแบบหลายเงื่อนไข:** ผู้ใช้สามารถเลือกระหว่าง "เส้นทางที่เร็วที่สุด" (Fastest Route) และ "เปลี่ยนสายน้อยที่สุด" (Fewest Transfers)
      * **แสดงค่าโดยสารประมาณการ:** มีการคำนวณและแสดงค่าโดยสารเบื้องต้นสำหรับเส้นทางนั้นๆ
      * **แสดงเวลาทำการ:** ในรายละเอียดเส้นทางมีการแสดงเวลาเปิด-ปิดของรถไฟฟ้าแต่ละสาย
      * **ระบบบันทึกเส้นทางโปรด (Favorites):** ผู้ใช้สามารถบันทึกเส้นทางที่ใช้บ่อย และเรียกดูหรือลบได้จากหน้า Favorites
      * **แผนภาพเส้นทาง:** แสดงแผนภาพของเส้นทางแบบง่ายๆ เพื่อให้เห็นภาพรวมของการเดินทางและจุดเปลี่ยนสาย

  * **สิ่งที่คิดว่าควรมีเพิ่มในอนาคต:**

      * **การเชื่อมต่อกับแผนที่จริง:** นำเส้นทางที่คำนวณได้ไปวาดเป็นเส้นบนแผนที่จริงๆ เช่น Google Maps เพื่อให้เห็นภาพชัดเจนยิ่งขึ้น
      * **ข้อมูล Real-time:** เชื่อมต่อกับ API ที่ให้ข้อมูลขบวนรถแบบเรียลไทม์ เพื่อคำนวณเวลารอรถและเวลาถึงที่แม่นยำขึ้น
      * **รองรับหลายภาษา:** เพิ่มการแสดงผลภาษาอื่นๆ เช่น ภาษาอังกฤษ
      * **แจ้งเตือน (Push Notifications):** แจ้งเตือนเมื่อเกิดเหตุการณ์ผิดปกติในระบบรถไฟฟ้า เช่น ความล่าช้า หรือการปิดบริการ
      * **การออกแบบเพื่อการเข้าถึง (Accessibility):** ปรับปรุง UI/UX สำหรับผู้พิการ เช่น การรองรับ Screen Reader หรือโหมดสีคอนทราสต์สูง
