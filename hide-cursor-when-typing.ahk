#Requires AutoHotkey v2.0
#SingleInstance Force

; Инициализация системного курсора
SystemCursor("Init")

; Переменные для отслеживания состояния
cursorHidden := false
idleThreshold := 1000  ; Время в миллисекундах, после которого курсор будет показан снова
lastInputTime := A_TickCount

; Устанавливаем таймер для проверки активности клавиатуры
SetTimer CheckKeyboardActivity, 100

; Функция для проверки активности клавиатуры
CheckKeyboardActivity() {
    global cursorHidden, lastInputTime, idleThreshold

    ; Проверяем, была ли нажата клавиша клавиатуры (a-z, A-Z, 0-9)
    isKeyboardInput := false
    for key in ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] {
        if GetKeyState(key, "P") {
            isKeyboardInput := true
            break
        }
    }

    ; Проверяем движение мыши
    static lastMouseX := 0, lastMouseY := 0
    MouseGetPos &mouseX, &mouseY

    ; Если мышь движется, показываем курсор
    if (lastMouseX != mouseX || lastMouseY != mouseY) {
        lastMouseX := mouseX
        lastMouseY := mouseY
        if (cursorHidden) {
            SystemCursor("On")
            cursorHidden := false
        }
        return
    }

    ; Если есть ввод с клавиатуры
    if (isKeyboardInput) {
        ; Обновляем время последнего ввода
        lastInputTime := A_TickCount

        ; Если курсор еще не скрыт, скрываем его
        if (!cursorHidden) {
            SystemCursor("Off")
            cursorHidden := true
        }
    }
    ; Если пользователь неактивен и прошло достаточно времени с последнего ввода
    else if (cursorHidden && (A_TickCount - lastInputTime > idleThreshold)) {
        ; Показываем курсор
        SystemCursor("On")
        cursorHidden := false
    }
}

; Функция для управления системным курсором (без изменений)
SystemCursor(OnOff := "On") {
    static AndMask, XorMask
    static CursorHandles := Map()
    static EmptyCursors := Map()
    static SystemCursors := Map("APPSTARTING", 32650, "ARROW", 32512, "CROSS", 32515, "HAND", 32649, "HELP", 32651, "IBEAM", 32513, "NO", 32648, "SIZEALL", 32646, "SIZENESW", 32643, "SIZENS", 32645, "SIZENWSE", 32642, "SIZEWE", 32644, "UPARROW", 32516, "WAIT", 32514)

    if (OnOff = "Init") {
        ; Создаем маски для пустого курсора
        AndMask := Buffer(32*4, 0xFF)  ; Полностью белая AND маска (все биты = 1)
        XorMask := Buffer(32*4, 0)     ; Полностью черная XOR маска (все биты = 0)

        ; Сохраняем оригинальные курсоры
        for CursorName, CursorID in SystemCursors {
            CursorHandle := DllCall("LoadCursor", "Ptr", 0, "Ptr", CursorID, "Ptr")
            CursorHandles[CursorName] := DllCall("CopyImage", "Ptr", CursorHandle, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr")

            ; Создаем пустые курсоры заранее
            EmptyCursors[CursorName] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", AndMask, "Ptr", XorMask, "Ptr")
        }
    } else if (OnOff = "On") {
        ; Восстанавливаем оригинальные курсоры
        for CursorName, CursorID in SystemCursors {
            DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", CursorHandles[CursorName], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr"), "UInt", CursorID)
        }
    } else {  ; Off
        ; Устанавливаем пустые курсоры
        for CursorName, CursorID in SystemCursors {
            DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", EmptyCursors[CursorName], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr"), "UInt", CursorID)
        }
    }
}

; Функция для очистки ресурсов при выходе (без изменений)
CleanupResources(ExitReason, ExitCode) {
    ; Восстанавливаем курсор
    SystemCursor("On")
}

; Регистрируем функцию очистки ресурсов при выходе
OnExit CleanupResources
