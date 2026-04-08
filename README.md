# DrawAnywhere

DrawAnywhere is a SwiftUI iOS app that helps you **capture or import a reference image** and **overlay it on top of the live camera preview** so you can align/trace compositions quickly.

The app is built around a simple stage flow:

- **Gallery/Camera (tab view)** → capture or pick an image
- **Image Review** → confirm or cancel
- **Edit** → overlay the image on the live camera feed and transform it (move/scale/rotate) + adjust opacity

---

## Features

### Capture → Review → Edit
- Open the **Camera** tab (live preview).
- Tap the capture button.
- The captured image transitions to **Image Review**.
- Confirm to enter **Edit**.

### Import → Review → Edit
- Open the **Gallery** tab.
- Pick an image from the Photos picker (or paste into the drop area).
- The app transitions to **Image Review**.
- Confirm to enter **Edit**.

### Overlay editing
In **Edit**, the overlay image is drawn above the camera preview with:
- **Opacity** driven by `ContentModel.opacity`
- **Scale / rotation / position** driven by `ContentModel.baseZoom`, `baseRotation`, `baseOffset`
- **Gestures**: pinch to zoom, rotate, and pan simultaneously (UIKit bridge)

Zoom is clamped to **0.5x → 8.0x**.

---

## Permissions

Usage descriptions are configured via Xcode build settings (generated into the app’s Info.plist at build time):

- **Camera**: `NSCameraUsageDescription` = "We need access to camera to take photos"
- **Photos**: `NSPhotoLibraryUsageDescription` = "We need access to library to use and save photos"

---

## Project structure (key files)

### App entry
- `DrawAnywhere/DrawAnywhereApp.swift`  
  App entry point. Presents `ContentView()` and sets up a SwiftData container.

### State + lifecycle orchestration
- `DrawAnywhere/Views/ContentView.swift`  
  Owns `CameraManager` + `ContentModel`, computes when the camera session should run, and reacts to state changes:
  - `scenePhase`
  - `model.screen` (`.gallery`, `.imageReview`, `.edit`)
  - `model.selectedTab` (`.camera`, `.gallery`)
  - `cameraManager.authorizationStatus`
  - `cameraManager.capturedImage`

### Routing between screens
- `DrawAnywhere/Views/TabViewContentView.swift`  
  `NavigationStack` + `switch model.screen`:
  - `.gallery` → `GalleryView`
  - `.imageReview(image)` → `ImageReviewView`
  - `.edit(image)` → `EditView`

### Camera
- `DrawAnywhere/Managers/CameraManager.swift`  
  AVFoundation session management + photo capture.

### Main UI components
- `DrawAnywhere/Views/GalleryView.swift`  
  `TabView` with:
  - **Camera tab**: `CameraPreview` + `CaptureButton`
  - **Gallery tab**: `PhotosPicker` + `DropImageView`
- `DrawAnywhere/Views/EditView.swift`  
  Live camera + overlay + gesture overlay
- `DrawAnywhere/Views/TransformGestureBridge.swift`  
  UIKit pinch/rotate/pan recognizers updating SwiftUI bindings
- `DrawAnywhere/Views/CameraPreview.swift`  
  `UIViewRepresentable` for `AVCaptureVideoPreviewLayer`
- `DrawAnywhere/extensions + enums/extensions.swift`  
  Shared “glass” styling helpers and toolbar helpers
- `DrawAnywhere/extensions + enums/enums.swift`  
  `RootTab`, `ScreenState`, etc.

---

## Running the app

1. Open `DrawAnywhere.xcodeproj` in Xcode.
2. Select a simulator or a physical device.
   - Camera preview works best on a **real device** (simulator camera support is limited).
3. Build & run.

---

## Known gaps / TODOs (from current code)

- **Denied camera permission UX**: there isn’t a dedicated “permission denied” screen yet; the session simply won’t run.
- **Haptics**: `HapticsManager` exists but capture doesn’t currently trigger it.
- **Edit accessory actions**: Rotate/Retake/Hide buttons exist but their actions are currently commented out.
- **Photo saving**: `PhotoPreviewView` includes saving to Photos, but the main flow uses `ImageReviewView` (and saving isn’t currently wired into that path).
