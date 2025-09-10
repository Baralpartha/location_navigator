# 📍 Location Navigator

[![Pub Version](https://img.shields.io/pub/v/location_navigator.svg)](https://pub.dev/packages/location_navigator)  
[![License](https://img.shields.io/github/license/Baralpartha/location_navigator)](https://github.com/Baralpartha/location_navigator/blob/main/LICENSE)

A Flutter package for discovering and navigating to **nearby places of interest** such as **mosques, hospitals, restaurants, hotels, and pharmacies**.  
It leverages **OpenStreetMap (Overpass API)** and **Geolocator** to provide accurate, real-time location results.

---

## ✨ Features

- 🔎 Retrieve the user’s **current location** with permission handling
- 🕌 Display nearby **mosques, hospitals, restaurants, hotels, pharmacies**, and more
- 📍 **Dropdown menu** for selecting amenity type
- 📝 Built-in **search box** to filter places by name
- 📏 Automatic sorting of places by **distance**
- 🗺️ Integrated **map view** with markers and navigation support
- 🎨 Clean **Material Design** with a teal theme

---

## ⚙️ How It Works

1. **Current Location Access**  
   Uses the [geolocator](https://pub.dev/packages/geolocator) package to handle permissions and fetch the user’s current latitude and longitude.

2. **Nearby Places Query**  
   Fetches data from [OpenStreetMap Overpass API](https://overpass-api.de/) through a `PlaceService`.  
   Places are filtered by amenity type (e.g., `hospital`, `mosque`, `hotel`).

3. **Distance Calculation**  
   Each place is sorted based on proximity to the user using:

   ```dart
   Geolocator.distanceBetween(
     userLatitude,
     userLongitude,
     placeLatitude,
     placeLongitude,
   );
🚀 Installation

Add this to your pubspec.yaml:
dependencies:
location_navigator: ^1.0.2
