# Tenunku

Tenunku is a mobile application for buying and selling traditional woven fabrics (Tenun), designed to support local artisans and preserve Indonesian culture. This application is built using Flutter.

## Features

*   **Authentication Flow:**
    *   **Landing Page:** Entry point for users to choose between Login and Register.
    *   **Role-Based Login/Register:** Separate flows for Buyers (Pembeli) and Sellers (Penjual).
    *   **OTP Verification:** Secure verification step during registration.
*   **Home Page:**
    *   **Welcome Dialog:** A popup promoting the preservation of culture.
    *   **Custom Navigation:** Unique bottom navigation bar with a premium design.
    *   **Modern UI:** Clean, grayscale aesthetic with focus on usability.

## Getting Started

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
*   An Android or iOS emulator, or a physical device connected.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/tenunku.git
    cd tenunku
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

*   `lib/main.dart`: Application entry point.
*   `lib/router.dart`: Navigation configuration (GoRouter).
*   `lib/theme.dart`: Application styling and theme configuration.
*   `lib/features/`: Feature-based directory structure (Auth, Home, etc.).

## Technologies Used

*   **Flutter:** cross-platform UI toolkit.
*   **GoRouter:** Declarative routing.
*   **Google Fonts:** Custom typography (Poppins).
*   **Provider:** (Planned) State management.
