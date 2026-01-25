# TENUNku

A Flutter mobile app connecting traditional Indonesian weavers (penenun) with buyers, preserving cultural heritage while supporting local artisans.

## Tech Stack
- **Flutter** - Cross-platform mobile framework
- **Supabase** - Backend (Auth, Database, Realtime, Storage)
- **GoRouter** - Navigation
- **Google Fonts** - Typography (Poppins)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Supabase Setup
1. Create a Supabase project
2. Run `schema.sql` in the SQL Editor
3. Update credentials in `lib/main.dart`

## Features

### ✅ Implemented

**Authentication**
- Login/Register with email
- OTP verification
- Role-based access (Pembeli/Penenun)

**Buyer (Pembeli)**
- Home page with product browsing
- Product detail modal with seller info
- Cart & checkout flow
- Favorites, Recently Viewed, Buy Again
- Submit product reviews
- Settings (Account, Address, Help Center, Notifications)

**Seller (Penenun)**
- Dashboard with profile
- Product management (Add/Edit/Delete)
- Order management (Accept/Reject/Ship)
- Real-time chat with buyers
- Profile editing

**Educational Content**
- Benang Membumi (weaving techniques)
- Untaian Tenunan (weaving stories)

---

## 🚧 TODO / Not Yet Implemented

### Buyer Features
- [ ] Photo/video upload in reviews
- [ ] Notification settings persistence
- [ ] Language preference saving
- [ ] Change password functionality
- [ ] Edit profile fields (username, phone, email)
- [ ] Change primary address
- [ ] Order tracking page
- [ ] Home page banner, categories, highlights (placeholders)

### Seller Features
- [ ] Real seller statistics (sold count, visits, reviews)
- [ ] Share profile functionality
- [ ] Shipping evidence image upload
- [ ] Notification settings persistence
- [ ] Product filtering logic
- [ ] Address editing

### Chat
- [ ] Image/file attachments
- [ ] Push notifications

### System
- [ ] Payment gateway integration
- [ ] Forgot password flow
- [ ] Onboarding skip/persistence
- [ ] Search history
- [ ] Similar products recommendation
- [ ] Multiple product images
- [ ] Push notifications (FCM)

---

## Project Structure

```
lib/
├── features/
│   ├── auth/           # Authentication
│   └── home/           # Main app features
│       ├── data/       # Models & repositories
│       └── presentation/
│           ├── pages/  # Screen widgets
│           └── widgets/# Reusable components
├── router.dart         # GoRouter configuration
└── main.dart           # App entry point
```

## Database Schema
See `schema.sql` for complete Supabase table definitions.
