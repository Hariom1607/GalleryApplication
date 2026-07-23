# Gallery Application

A Gallery Application built using **UIKit** and **MVVM Architecture**. The app allows users to authenticate with Google, browse online images with pagination, and view previously loaded images while offline.

---

## Features

- 🔐 Google Sign-In Authentication
- 🖼️ Gallery using the Picsum API
- 📄 Infinite Pagination
- 💾 Offline Support using Core Data
- 👤 Profile Screen
- 🚪 Logout Functionality
- ⚡ Image Loading & Caching with Kingfisher

---

## Architecture

- MVVM (Model-View-ViewModel)
- URLSession for Networking
- Core Data for Local Persistence

---

## Technologies

- Swift 5
- UIKit
- Core Data
- Firebase Authentication
- Google Sign-In
- Kingfisher
- Swift Package Manager (SPM)

---

## Screens

- Login
- Gallery
- Profile

---

## Offline Support

- Gallery metadata is stored using Core Data.
- Images are cached locally and can be viewed without an internet connection after they have been loaded once.

---

## Requirements

- Xcode 16+
- iOS 18+

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/<your-username>/GalleryApplication.git
```

2. Open the project:

```bash
open GalleryApplication.xcodeproj
```

3. Resolve Swift Package dependencies:

```
File → Packages → Resolve Package Versions
```

4. Run the project.

---

## API Used

Picsum Photos

https://picsum.photos/v2/list

---

## Author

**Hariom Sharma**
