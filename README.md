# 📍 Location Navigator

[![Pub Version](https://img.shields.io/pub/v/location_navigator.svg)](https://pub.dev/packages/location_navigator)  
[![License](https://img.shields.io/github/license/Baralpartha/location_navigator)](https://github.com/Baralpartha/location_navigator/blob/main/LICENSE)

A Flutter package to **find and navigate nearby places** (e.g. Mosques, Hospitals, Hotels, Restaurants, Pharmacies) using **OpenStreetMap (Overpass API)** and **Geolocator**.

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
   Geolocator.distanceBetween(
       userLatitude,
       userLongitude,
       placeLatitude,
       placeLongitude,
   );
