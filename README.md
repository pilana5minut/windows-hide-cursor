# Hiding the Cursor While Typing

This repository contains an AutoHotkey v2.0 script that automatically hides the mouse cursor when typing text (letters a-z, A-Z, digits 0-9) and restores it when the user moves the mouse.

## Purpose

The script is designed for users who want to avoid distractions from the mouse cursor while typing. The cursor hides when you start typing and reappears only when you move the mouse.

## Requirements

- **AutoHotkey v2.0+**: The script works only with AutoHotkey version 2.0 or higher. Download AutoHotkey from the official website: [https://www.autohotkey.com/](https://www.autohotkey.com/).

## Installation and Usage

1. Ensure AutoHotkey v2.0 is installed on your computer.
2. Download the `hide-cursor-when-typing.ahk` file from this repository.
3. Double-click the `hide-cursor-when-typing.ahk` file to run the script.
4. The script will start working automatically:
   - The cursor hides when pressing alphanumeric keys (a-z, A-Z, 0-9).
   - The cursor reappears when moving the mouse.
5. To stop the script, locate its icon in the system tray (near the clock), right-click, and select "Exit".
6. To run the script automatically on system startup, add it to your Windows startup folder or create a shortcut in the Startup directory (`shell:startup`).

## How It Works

- **Hiding the Cursor**: When you start typing (letters or digits), the script replaces the system cursor with an empty one.
- **Showing the Cursor**: The cursor reappears when the mouse is moved.
- **Resource Cleanup**: When the script is closed, the system cursor is automatically restored.

## Limitations

- The script responds only to alphanumeric keys (a-z, A-Z, 0-9). Other keys, such as space or punctuation, do not trigger cursor hiding.
- Works only on Windows, as AutoHotkey is a Windows-specific tool.

## Customization

To modify the script's behavior, such as adding support for other keys, edit the `hide-cursor-when-typing.ahk` file in a text editor. The main parameter to adjust:
- The array of keys in the `CheckKeyboardActivity` function: You can add other keys, such as `Space`, `,`, or `.`.

## License

This script is distributed under the MIT License. You are free to use, modify, and distribute it.

## Issues and Questions

If you encounter problems or have questions, create an [issue](https://github.com/pilana5minut/windows-hide-cursor/issues) in this repository.

## Resources

- [AutoHotkey v2 Documentation](https://www.autohotkey.com/docs/v2/)
