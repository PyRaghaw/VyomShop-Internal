# Vyom Mobile - Backend & Database Integration Guide

Welcome! This guide explains how to connect the **Vyom Flutter Mobile App** (`vyom_mobile`) to the **Vyom Backend & PostgreSQL Database** (`VyomShop-Internal/backend`).

---

## 1. Quick Start (Connecting Mobile App to Local Backend)

The app is built to connect directly to the Next.js API in `VyomShop-Internal/backend` (port `3000`), which runs on top of Prisma + PostgreSQL.

### Step 1: Start the Backend & Database
Inside `VyomShop-Internal/backend`:
```bash
# 1. Start PostgreSQL (via docker-compose in root if using docker)
docker compose up -d

# 2. Run migrations
bun x prisma migrate dev

# 3. Start Next.js dev server (runs on http://localhost:3000)
bun run dev
```

### Step 2: Run the Flutter App

#### Option A: Running on macOS Desktop / Chrome
```bash
cd vyom_mobile
flutter run -d macos
```
The app defaults to `http://localhost:3000/api`.

#### Option B: Running on a Connected Physical Android Phone (USB)
When running on a real Android phone over USB, port-forward port 3000 using ADB so the phone's `localhost:3000` routes directly to your Mac/PC:
```bash
adb reverse tcp:3000 tcp:3000
flutter run
```

#### Option C: Running on Android Emulator
The Android emulator uses `10.0.2.2` to refer to the host machine:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:3000/api
```

#### Option D: Custom / Staging / Production URL
Pass the backend URL at build or runtime:
```bash
flutter run --dart-define=API_URL=https://api.yourdomain.com/api
```
Or set it dynamically in code via:
```dart
import 'package:vyom_mobile/core/constants/api_endpoints.dart';

// In main.dart or app init:
ApiEndpoints.setBaseUrl('https://api.yourdomain.com/api', isNextJs: true);
```

---

## 2. API Endpoints Reference

All endpoints are configured in [`lib/core/constants/api_endpoints.dart`](lib/core/constants/api_endpoints.dart).

### Customer Endpoints

| Feature | Method | Path | Description |
|---|---|---|---|
| **Nearby Shops** | `GET` | `/api/customer/shops/nearby?area=&category=&q=&maxDistance=` | Returns nearby verified boutique shops |
| **Shop Details** | `GET` | `/api/customer/shops/:id` | Returns shop info and shop products |
| **Product Search** | `GET` | `/api/customer/products/search?q=&category=&gender=&brand=&minPrice=&maxPrice=` | Multi-filter product search |
| **Product Details** | `GET` | `/api/customer/products/:id` | Product info, stock, sizes, colors |
| **Analytics Log** | `POST` | `/api/customer/analytics` | Logs view, direction click, call click |

### Seller Endpoints

| Feature | Method | Path | Description |
|---|---|---|---|
| **Seller Shop** | `GET` | `/api/seller/shop` | Returns seller's registered shop & status |
| **Register Shop** | `POST` | `/api/seller/shop` | Register a new boutique storefront |
| **Seller Products** | `GET` | `/api/seller/products` | Lists products owned by the seller |
| **Create Product** | `POST` | `/api/seller/products` | Add a new product to shop |
| **Seller Wallet** | `GET` | `/api/seller/wallet` | Credits balance & transaction history |
| **Listing Packages** | `GET` | `/api/seller/packages` | Available packages (Starter, Growth, Pro, Business) |
| **Seller Analytics** | `GET` | `/api/seller/analytics` | Views, direction clicks, calls received |

### Auth Endpoints

| Feature | Method | Path | Description |
|---|---|---|---|
| **Verify Firebase Token** | `POST` | `/api/auth/verifyToken` | Exchange Firebase ID token for session |
| **Select Role** | `POST` | `/api/auth/selectRole` | Assign `CUSTOMER` or `SELLER` role |

---

## 3. Data Models & JSON Schemas

### Shop JSON Schema (`ShopModel`)
```json
{
  "id": "shop_cuid_123",
  "name": "Sole Zone",
  "category": "Footwear",
  "tag": "LOCAL STORE",
  "rating": 4.5,
  "reviewsCount": 248,
  "distanceKm": 0.6,
  "address": "Block CF, Sector 1, Salt Lake, Kolkata",
  "neighborhood": "Salt Lake",
  "city": "Kolkata",
  "latitude": 22.5867,
  "longitude": 88.4178,
  "isOpen": true,
  "openTime": "10:00 AM",
  "closingTime": "10:00 PM",
  "phone": "+91 98301 22345",
  "imageUrl": "https://example.com/shop.jpg",
  "description": "Premier sneaker boutique stocking rare kicks and streetwear."
}
```

### Product JSON Schema (`ProductModel`)
```json
{
  "id": "prod_cuid_456",
  "shopId": "shop_cuid_123",
  "shopName": "Sole Zone",
  "name": "Everyday Canvas Shoes",
  "category": "Footwear",
  "price": 599.0,
  "mrp": 799.0,
  "rating": 4.8,
  "distanceKm": 1.2,
  "imageUrl": "https://example.com/shoe.jpg",
  "description": "Comfortable canvas low-tops with vulcanized rubber sole.",
  "sizes": ["UK 7", "UK 8", "UK 9", "UK 10"],
  "colors": ["Tan Brown", "Black", "White"],
  "inStock": true,
  "matchPercentage": 97
}
```

---

## 4. Mock Data Mode (For Offline UI Testing)

By default, **mock data is disabled** (`enableMockData = false`) so that all data comes directly from your database.

If you ever need to test UI offline without running a backend:
1. Open [`lib/core/data/mock_data.dart`](lib/core/data/mock_data.dart)
2. Set:
   ```dart
   static bool enableMockData = true;
   ```
3. Run the app. It will populate rich mock data for all screens.

---

## 5. Architectural Notes for Backend Team
- **Prisma Schema Compatibility**: The models in the Flutter app correspond 1:1 with `prisma/schema.prisma` in `VyomShop-Internal/backend`.
- **Image URLs**: The mobile app natively handles remote HTTP/HTTPS image URLs via `CachedNetworkImage` and local assets gracefully with error fallbacks.
- **Empty States**: If your database has 0 products or shops, the mobile app renders sleek Neo-Brutalist empty state placeholders with reload buttons.
