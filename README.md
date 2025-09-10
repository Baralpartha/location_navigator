# 📍 Location Navigator

A Flutter package to **find and navigate nearby places** (e.g. Mosques, Hospitals, Hotels, Restaurants, Pharmacies) using **OpenStreetMap data** and **Geolocator**.

---

## ✨ Features
- 🔎 Get user's **current location** with permission handling.
- 🕌 Show nearby **Mosques, Hospitals, Restaurants, Hotels, Pharmacies** etc.
- 📍 Dropdown to select place type (amenity).
- 📝 Search box to filter nearby places by name.
- 📏 Places sorted automatically by **distance**.
- 🗺️ Built-in **Map view** with markers and navigation.
- 🎨 Simple **Material Design with teal theme**.

---

## ⚙️ How It Works

1. **Get Current Location**  
   The package uses [geolocator](https://pub.dev/packages/geolocator) to request location permission and fetch the user's latitude & longitude.

2. **Fetch Nearby Places**  
   It calls [OpenStreetMap (Overpass API)](https://overpass-api.de/) through a service (`PlaceService`) to search for nearby places based on **amenity type** (e.g. hospital, mosque, hotel).

3. **Distance Calculation**  
   Each place's distance from the user is calculated using `Geolocator.distanceBetween(...)`.

4. **Sorting & Filtering**
    - If the user selects a category (Hospital, Mosque etc.), results are filtered by that.
    - If the user types in the search box, results are filtered by name.
    - Finally, places are sorted by **nearest distance**.

5. **Display Results**
    - A **ListView** shows the places with name, type, and distance.
    - Tapping an item opens a **Map screen** (powered by [flutter_map](https://pub.dev/packages/flutter_map)) where the selected place and user location are displayed.

---

## 📦 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  location_navigator: ^1.0.0
Then run:
flutter pub get
🚀 Usage
Basic Example
