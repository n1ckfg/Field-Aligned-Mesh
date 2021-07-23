import random
print(288)
for i in range(12):
    for j in range(12):
        x = 100+80*i + 2*random.random()
        y = 100+80*j + 2*random.random()
        magnitude = 15*random.random()
        print(x, ",", y)
        if (i == 0 or i == 11 or j == 0 or j == 11):
            print(5 + x, ",", 5 + y)
        else:
            print(x + 1, ",", y + 1)
