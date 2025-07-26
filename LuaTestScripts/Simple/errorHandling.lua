-- Тест обработки ошибок с pcall
local function problematicFunction()
    error("Это тестовая ошибка!")
end

local status, err = pcall(problematicFunction)

if not status then
    print("Произошла ошибка:", err)
else
    print("Функция выполнилась успешно")
end