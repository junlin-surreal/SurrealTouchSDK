# SurrealInteractiveSwift SDK
SurrealInteractive Swift SDK for the Surreal Touch Controller.

## Installation Instructions
To install the SDK, open Xcode and navigate to the Package Manager by selecting File -> Add Package Dependency. Enter the Git URL in the search bar and proceed to add the package.

This SDK provides a high-level API, similar to OpenXR, enabling you to receive input and send output to the controller.

## Example Project
For a practical demonstration of how to use the SurrealInteractiveSwift SDK, please check out our [Example Project](https://github.com/surreal-interactive/Swift-SDK-example).


## Xcode Project Info.plist Configuration

To enable Bluetooth and hand gesture functionalities in your Xcode project, you need to add the following keys to your `Info.plist` file:

1. **NSBluetoothAlwaysUsageDescription**: This key is required to request permission to use Bluetooth services. Provide a description of why your app needs access to Bluetooth.

   ```xml
   <key>NSBluetoothAlwaysUsageDescription</key>
   <string>This app requires Bluetooth access to connect to the Surreal Touch Controller.</string>
   ```

2. **NSBluetoothPeripheralUsageDescription**: This key is necessary for accessing Bluetooth peripherals. Again, provide a description of the need for this access.

   ```xml
   <key>NSBluetoothPeripheralUsageDescription</key>
   <string>This app needs to communicate with Bluetooth devices for hand gesture recognition.</string>
   ```
3. **NSHandsTrackingUsageDescription**: This key is required to request permission to use hand tracking features. Provide a description of why your app needs access to hand tracking.

   ```xml
   <key>NSHandsTrackingUsageDescription</key>
   <string>This app requires hand tracking access to enable gesture-based controls with the Surreal Touch Controller.</string>
   ```

Make sure to include these entries in your `Info.plist` file to ensure proper functionality of the SDK with Bluetooth and hand gestures.



