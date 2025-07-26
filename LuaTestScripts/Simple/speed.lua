
local startTime = os.clock()
local iterations = 1000000
local sum = 0

for i = 1, iterations do
    sum = sum + i
end

local endTime = os.clock()
print(string.format("Сумма %d чисел: %d", iterations, sum))
print(string.format("Время выполнения: %.4f секунд", endTime - startTime))