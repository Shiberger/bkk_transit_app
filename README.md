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

  - **Backend API (The Brain):** A Python Flask server is responsible for all business logic. It reads the `database.json` file, builds a graph representation of the transit network, and runs the pathfinding algorithm based on the user's request. This keeps the frontend app lightweight.
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

First, create a `requirements.txt` file inside the `backend_api` folder to manage dependencies.

**File:** `backend_api/requirements.txt`

```
Flask
```

Now, run the following commands from the project's **root directory**:

```bash
# 1. Navigate into the backend directory
cd backend_api

# 2. Create a Python virtual environment
python3 -m venv venv

# 3. Activate the virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
.\\venv\\Scripts\\activate

# 4. Install the required packages
pip install -r requirements.txt

# 5. Run the backend server
# The server will run on port 5002 as configured in app.py
python app.py
```

Leave this terminal window open. Your backend is now running\!

### 2\. Frontend Setup

Open a **new terminal window** and follow these steps from the project's **root directory**:

```bash
# 1. Navigate into the Flutter app directory
cd frontend_flutter/transit_app_ui
```

**2. Configure the API Address:**
This is the most important step. Open `lib/services/api_service.dart` and edit the `baseUrl` variable to point to your computer's IP address.

  - If running on an **iOS Simulator**:
    ```dart
    final String baseUrl = "http://127.0.0.1:5002/api";
    ```
  - If running on an **Android Emulator**:
    ```dart
    final String baseUrl = "http://10.0.2.2:5002/api";
    ```
  - If running on a **physical phone**: Find your computer's local IP address (e.g., `192.168.1.100`) and make sure your phone is on the same Wi-Fi network.
    ```dart
    // Replace with your computer's actual IP address
    final String baseUrl = "http://192.168.1.100:5002/api";
    ```

**3. Run the Flutter App:**

```bash
# 3. Get the Flutter dependencies
flutter pub get

# 4. Run the application
flutter run
```

The BKK Transit App should now launch on your selected device and be fully connected to your local backend.
