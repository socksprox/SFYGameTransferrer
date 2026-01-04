# SFY Game Transferrer

A Flutter app for transferring CIA and TIK files to Nintendo 3DS consoles using the FBI app's network receive feature.

## Features

- **Modern UI with TDesign Flutter** - Clean, intuitive interface
- **File Picker** - Select multiple .cia and .tik files from your device
- **FBI Protocol Support** - Fully compatible with FBI's "Receive URLs over the network" feature
- **Real-time Transfer Log** - Monitor the transfer process
- **File Management** - Add, view, and remove files before transfer

## Screenshots

<table>
  <tr>
    <td><img src="docs/photos/consoles_tab.jpg" alt="Consoles Tab" width="300"/></td>
    <td><img src="docs/photos/files_tab.jpg" alt="Files Tab" width="300"/></td>
  </tr>
  <tr>
    <td align="center">Consoles Tab</td>
    <td align="center">Files Tab</td>
  </tr>
</table>

## Requirements

1. Nintendo 3DS with FBI installed
2. 3DS and your device on the same network
3. Flutter SDK installed (for development)

## Usage

1. Open FBI on your 3DS
2. Choose "Receive URLs over the network"
3. Note the IP address and port displayed on the 3DS screen
4. Launch this app on your device
5. Enter the 3DS IP address and port
6. Tap "Add Files" to select .cia or .tik files
7. Tap "Send to 3DS" to start the transfer
8. FBI will automatically download and install the files

## How It Works

The app implements the FBI network protocol:
1. Starts an HTTP server on your device
2. Connects to the 3DS via TCP socket on the specified IP:port
3. Sends file URLs to the 3DS using FBI's protocol (4-byte length + newline-separated URLs)
4. Serves files via HTTP when the 3DS requests them

## Building

```bash
flutter pub get
flutter run
```

## Credits

Based on the protocol implementation from [3DS FBI Link](https://github.com/varunmehta/3DS-FBI-Link) by Varun Mehta.
