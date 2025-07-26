-- Тест операций с таблицами
local tableTest = {}

-- Заполнение таблицы
for i = 1, 1000 do
    tableTest[i] = math.random(1, 100)
end

-- Поиск максимального значения
local max = 0
for _, value in ipairs(tableTest) do
    if value > max then
        max = value
    end
end

print("Максимальное значение в таблице:", max)