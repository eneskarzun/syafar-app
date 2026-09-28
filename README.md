# Syafar Tour - Hotel Rate Aggregator & Quotation Engine

Aplikasi pencarian hotel Makkah/Madinah dan kalkulator estimasi harga per jamaah.

## 🌐 Live Deployment URL (WAJIB)
- **Frontend (Aplikasi Web):** https://syafar-web-production.vercel.app
- **Backend (Mock API):** https://syafar-backend-production.up.railway.app/api/hotels

*(Catatan: Backend menggunakan layanan gratis, harap maklum jika ada delay beberapa detik pada request pertama karena proses cold-start).*

## 🛠 Tech Stack
- **Frontend:** Flutter Web (Clean Architecture, BLoC State Management, GoRouter)
- **Backend:** Node.js, Hapi.js (Clean Architecture)

## 🚀 Fitur Bonus yang Diimplementasikan
- [x] Sorting harga termurah & termahal
- [x] Search nama hotel
- [x] Filter rentang harga
- [x] Simpan quotation (SharedPreferences)
- [x] Tampilan responsive (Mobile & Desktop)

## 💻 Cara Menjalankan Secara Lokal (Local Development)

### Backend (Node.js)
1. Masuk ke folder backend: `cd backend`
2. Install dependencies: `npm install`
3. Jalankan server: `npm run start:dev`
4. API akan berjalan di `http://localhost:3000/api/hotels`

### Frontend (Flutter)
1. Masuk ke folder frontend: `cd frontend`
2. Install dependencies: `flutter pub get`
3. Jalankan aplikasi web: `flutter run -d chrome`