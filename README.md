
# My Store -   This project serves as a template for building a mobile commerce platform for both Android and iOS.

## 📸 Screenshots

![pic1](https://github.com/user-attachments/assets/ecc9274f-d2f1-4e8a-b262-dfbdfb3f4b89)

![pic2](https://github.com/user-attachments/assets/526802db-fa30-4180-8bc4-2ad6c19e0e75)

## ✨ Features

My Store comes packed with a variety of features essential for a modern e-commerce application:

✅ CRUD Operations:
- CREATE: Add new products with all details
- READ: View all products in a list with search
- UPDATE: Edit existing product information
- DELETE: Remove products with confirmation

✅ SQLite Database:
- Proper relational database using sqflite
- Structured schema with all required fields
- Efficient queries and indexing
- Data persistence across app restarts

✅ Camera Integration:
- Native camera capture
- Gallery image selection
- Image storage in app directory
- Image display with error handling
- Permission handling for both platforms

✅ UI/UX Features:
    - Clean, modern Material Design 3
    - Search functionality
    - Statistics dashboard
    - Stock level indicators
    - Responsive layouts
    - Loading states
    - Error handling
    - Confirmation dialogs

✅ Product Features:
- Product name (required)
- Quantity tracking (required)
- Price management (required)
- Optional product images
- Timestamps (created/updated)
- Stock status indicators
- Total value calculations


## 🛠️ Tech Stack & Dependencies

This project is built using Flutter and relies on the following key packages:

dependencies:
flutter:
sdk: flutter
sqflite: ^2.3.0
path_provider: ^2.1.1
path: ^1.8.3
image_picker: ^1.0.4
permission_handler: ^11.0.1

dev_dependencies:
flutter_test:
sdk: flutter
flutter_lints: ^3.0.0

A full list of dependencies can be found in the `pubspec.yaml` file.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

Make sure you have Flutter installed on your local machine. For instructions, see the [official Flutter documentation](https://docs.flutter.dev/get-started/install).

### Installation

1.  **Clone the repository:**

### USAGE INSTRUCTIONS

1. Add Product:
    - Tap the floating action button
    - Fill in product details
    - Optionally add image via camera/gallery
    - Save to database

2. View Products:
    - See all products in list view
    - Use search to filter
    - View statistics at top
    - Tap product for details
3. Edit Product:
    - Tap edit icon on product card
    - OR tap product to view details, then tap edit
    - Modify any field
    - Save changes

4. Delete Product:
    - Tap delete icon on product card
    - Confirm deletion
    - Product and image removed from database

5. Search:
    - Use search bar at top
    - Filters products by name
    - Real-time results
    - Clear button to reset
