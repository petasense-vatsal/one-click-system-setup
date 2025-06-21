# Custom Desktop Entries

This directory contains optimized desktop entries for various applications, particularly Electron-based apps with Wayland optimizations.

## Electron App Optimizations

### Cursor (`cursor.desktop`)
- **Wayland flags**: `--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations --ozone-platform-hint=auto`
- **Benefits**: Native Wayland support, proper window decorations, WebRTC screen sharing
- **Categories**: Development, IDE, TextEditor
- **MIME Types**: text/plain, inode/directory

### Cursor Override (`cursor-cursor.desktop`)
- **Purpose**: Overrides the default cursor-cursor.desktop installed by the Cursor package
- **NoDisplay**: Set to true to prevent duplicate entries in application launchers
- **Auto-installed**: Automatically copied when Cursor is selected in the application installer

### Google Chrome (`google-chrome.desktop`)
- **Wayland flags**: `--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations --ozone-platform-hint=auto`
- **Benefits**: Native Wayland support, proper window decorations, WebRTC screen sharing
- **Categories**: Network, WebBrowser
- **MIME Types**: Full web browser MIME type support including PDF and various web formats
- **Actions**: New window and incognito window with Wayland flags

### Obsidian (`obsidian.desktop`)
- **Environment**: `OBSIDIAN_USE_WAYLAND=1`
- **Wayland flags**: `--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --ozone-platform-hint=auto`
- **Benefits**: Full Wayland native support, better performance
- **Categories**: Utility, TextEditor, Productivity
- **MIME Types**: text/markdown, inode/directory

### Slack (`slack.desktop`)
- **Wayland flags**: `--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland`
- **Benefits**: Native Wayland rendering, proper window management
- **Categories**: Network, InstantMessaging
- **MIME Types**: x-scheme-handler/slack

## Monitor Configuration Entries

### Monitor Layout Shortcuts
- **`monitor-primary.desktop`**: Switch to primary monitor only
- **`monitor-secondary.desktop`**: Switch to secondary monitor only  
- **`monitor-extended.desktop`**: Extended desktop across multiple monitors

These entries use the `switch_layout.sh` script to quickly change monitor configurations.

## Installation

These desktop entries are automatically installed by the applications setup script when you select the corresponding applications. The script will:

1. Use these optimized entries for supported apps (cursor, obsidian, slack)
2. Install monitor configuration shortcuts automatically
3. Fall back to basic entries for apps without custom configurations

## Benefits

- **Better Wayland support**: Proper rendering and window management
- **Screen sharing**: WebRTC works correctly in Wayland
- **Performance**: Native Wayland apps perform better than XWayland
- **User experience**: Proper window decorations and behavior 