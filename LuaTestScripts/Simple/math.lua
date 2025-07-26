-- Тест точности математических вычислений
local a = 0.1
local b = 0.2
local sum = a + b

print(string.format("Сумма %.1f + %.1f = %.17f", a, b, sum))
print("Сравнение с 0.3:", sum == 0.3)
print("Разница с 0.3:", math.abs(sum - 0.3))