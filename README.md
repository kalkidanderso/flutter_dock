# FlutterDock

FlutterDock is a macOS-style draggable dock implementation in Flutter. This project demonstrates how to create a customizable, animated dock with draggable and sortable icons.

## Features

- Draggable and sortable dock icons
- Smooth animations when reordering icons
- Customizable icon appearance
- Responsive design

## Getting Started

To run this project:

1. Ensure you have Flutter installed on your machine
2. Clone this repository: `git clone git@github.com:kalkidanderso/flutter_dock.git`
3. Navigate to the project directory: `cd flutter_dock`
4. Get dependencies: `flutter pub get`
5. Run the app: `flutter run -d chrome`

## Usage

The main `Dock` widget can be customized with different icons and styles. Example usage:

```dart
Dock<IconData>(
  items: const [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ],
  builder: (IconData icon, bool isDragging) {
    return DockItem(
      icon: icon,
      isDragging: isDragging,
    );
  },
)# flutter_dock
