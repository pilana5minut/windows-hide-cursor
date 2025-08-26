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
    
    ; Получаем время бездействия пользователя
    idleTime := A_TimeIdlePhysical
    
    ; Если пользователь активен (время бездействия меньше порога)
    if (idleTime < 100) {  ; Если прошло менее 100 мс с последнего действия
        ; Обновляем время последнего ввода
        lastInputTime := A_TickCount
        
        ; Проверяем, не двигается ли мышь
        static lastMouseX := 0, lastMouseY := 0
        MouseGetPos &mouseX, &mouseY
        
        ; Если положение мыши изменилось, считаем это движением мыши, а не вводом текста
        if (lastMouseX != mouseX || lastMouseY != mouseY) {
            lastMouseX := mouseX
            lastMouseY := mouseY
            
            ; Если курсор был скрыт, показываем его
            if (cursorHidden) {
                SystemCursor("On")
                cursorHidden := false
            }
            return
        }
        
        ; Если курсор еще не скрыт, скрываем его (это ввод с клавиатуры)
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

; Функция для управления системным курсором
SystemCursor(OnOff := "On") {
    static AndMask, XorMask
    static CursorHandles := Map()
    static SystemCursors := Map("APPSTARTING", 32650, "ARROW", 32512, "CROSS", 32515, "HAND", 32649, "HELP", 32651, "IBEAM", 32513, "NO", 32648, "SIZEALL", 32646, "SIZENESW", 32643, "SIZENS", 32645, "SIZENWSE", 32642, "SIZEWE", 32644, "UPARROW", 32516, "WAIT", 32514)
    
    if (OnOff = "Init") {
        ; Создаем полностью прозрачные маски для курсора
        AndMask := Buffer(32*4, 0)  ; Полностью прозрачная AND маска
        XorMask := Buffer(32*4, 0)  ; Полностью прозрачная XOR маска
        
        for CursorName, CursorID in SystemCursors {
            CursorHandle := DllCall("LoadCursor", "Ptr", 0, "Ptr", CursorID, "Ptr")
            CursorHandles[CursorName] := DllCall("CopyImage", "Ptr", CursorHandle, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
        }
    } else if (OnOff = "On") {
        for CursorName, CursorID in SystemCursors {
            DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", CursorHandles[CursorName], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr"), "UInt", CursorID)
        }
    } else {  ; Off
        for CursorName, CursorID in SystemCursors {
            ; Создаем полностью прозрачный курсор (1x1 пиксель)
            BlankCursor := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 1, "Int", 1, "Ptr", AndMask, "Ptr", XorMask, "Ptr")
            DllCall("SetSystemCursor", "Ptr", BlankCursor, "UInt", CursorID)
        }
    }
}

; Функция для очистки ресурсов при выходе
CleanupResources(ExitReason, ExitCode) {
    ; Восстанавливаем курсор
    SystemCursor("On")
}

; Регистрируем функцию очистки ресурсов при выходе
OnExit CleanupResources
