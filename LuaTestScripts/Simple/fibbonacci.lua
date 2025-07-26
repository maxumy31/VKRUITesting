local a, b = 0, 1
for i = 0, 10 do
    print(i, a)
    a, b = b, a + b
end
