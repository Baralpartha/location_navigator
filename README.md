# 📍 Location Navigator

A Flutter package to **find and navigate nearby places** (e.g. Mosques, Hospitals, Hotels, Restaurants, Pharmacies) using **OpenStreetMap (Overpass API)** and **Geolocator**.
[![Pub Version](https://img.shields.io/pub/v/location_navigator.svg)](https://github.com/Baralpartha/location_navigator)
[![License](https://img.shields.io/github/license/Baralpartha/location_navigator)](https://github.com/Baralpartha/location_navigator/blob/main/LICENSE)

---

## ✨ Features
- 🔎 Get user's **current location** with permission handling
- 🕌 Show nearby **Mosques, Hospitals, Restaurants, Hotels, Pharmacies** etc.
- 📍 Dropdown to select place type (amenity)
- 📝 Search box to filter nearby places by name
- 📏 Places automatically sorted by **distance**
- 🗺️ Built-in **Map view** with markers and navigation
- 🎨 Simple **Material Design with teal theme**

---

## ⚙️ How It Works

1. **Get Current Location**  
   Uses [geolocator](https://pub.dev/packages/geolocator) to request permission and fetch the user's latitude & longitude.

2. **Fetch Nearby Places**  
   Calls [OpenStreetMap (Overpass API)](https://overpass-api.de/) via a `PlaceService` to search for nearby places based on **amenity type** (e.g., hospital, mosque, hotel).

3. **Distance Calculation**  
   Each place's distance from the user is calculated using:
   ```dart
   Geolocator.distanceBetween(...)

    Sorting & Filtering

        Select a category (Hospital, Mosque, Hotel etc.) via dropdown

        Or search any nearby place by name

        Results sorted by nearest distance

    Display Results

        A ListView shows the places with name, type, and distance

        On tap → opens a Map screen (powered by flutter_map

        ) where the user’s location and selected place are displayed

📦 Installation

Add the dependency in your pubspec.yaml:

dependencies:
location_navigator: ^1.0.1

Then run:

flutter pub get

