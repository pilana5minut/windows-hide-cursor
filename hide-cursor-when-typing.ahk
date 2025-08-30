#Requires AutoHotkey v2.0
#SingleInstance Force

; Initialization of the system cursor
SystemCursor("Init")

; Variables for tracking status
cursorHidden := false
lastInputTime := A_TickCount

; Set a timer to check keyboard activity
SetTimer CheckKeyboardActivity, 100

; Function for checking keyboard activity
CheckKeyboardActivity() {
    global cursorHidden, lastInputTime

    ; Checking whether a key on the keyboard has been pressed (a-z, A-Z, 0-9)
    isKeyboardInput := false
    for key in ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] {
        if GetKeyState(key, "P") {
            isKeyboardInput := true
            break
        }
    }

    ; Checking mouse movement
    static lastMouseX := 0, lastMouseY := 0
    MouseGetPos &mouseX, &mouseY

    ; If the mouse moves, show the cursor
    if (lastMouseX != mouseX || lastMouseY != mouseY) {
        lastMouseX := mouseX
        lastMouseY := mouseY
        if (cursorHidden) {
            SystemCursor("On")
            cursorHidden := false
        }
        return
    }

    ; If there is input from the keyboard
    if (isKeyboardInput) {
        ; Updating the time of the last entry
        lastInputTime := A_TickCount

        ; If the cursor is not already hidden, hide it.
        if (!cursorHidden) {
            SystemCursor("Off")
            cursorHidden := true
        }
    }
}

; Function for controlling the system cursor (no changes)
SystemCursor(OnOff := "On") {
    static AndMask, XorMask
    static CursorHandles := Map()
    static EmptyCursors := Map()
    static SystemCursors := Map("APPSTARTING", 32650, "ARROW", 32512, "CROSS", 32515, "HAND", 32649, "HELP", 32651, "IBEAM", 32513, "NO", 32648, "SIZEALL", 32646, "SIZENESW", 32643, "SIZENS", 32645, "SIZENWSE", 32642, "SIZEWE", 32644, "UPARROW", 32516, "WAIT", 32514)

    if (OnOff = "Init") {
        ; Creating masks for an empty cursor
        AndMask := Buffer(32*4, 0xFF)  ; Completely white AND mask (all bits = 1)
        XorMask := Buffer(32*4, 0)     ; Completely black XOR mask (all bits = 0)

        ; Keep the original cursors
        for CursorName, CursorID in SystemCursors {
            CursorHandle := DllCall("LoadCursor", "Ptr", 0, "Ptr", CursorID, "Ptr")
            CursorHandles[CursorName] := DllCall("CopyImage", "Ptr", CursorHandle, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr")

            ; Create empty cursors in advance
            EmptyCursors[CursorName] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", AndMask, "Ptr", XorMask, "Ptr")
        }
    } else if (OnOff = "On") {
        ; Restoring the original cursors
        for CursorName, CursorID in SystemCursors {
            DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", CursorHandles[CursorName], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr"), "UInt", CursorID)
        }
    } else {  ; Off
        ; Set empty cursors
        for CursorName, CursorID in SystemCursors {
            DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", EmptyCursors[CursorName], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr"), "UInt", CursorID)
        }
    }
}

; Function for cleaning resources on exit (no changes)
CleanupResources(ExitReason, ExitCode) {
    ; Restoring the cursor
    SystemCursor("On")
}

; Registering a resource cleanup function on exit
OnExit CleanupResources
