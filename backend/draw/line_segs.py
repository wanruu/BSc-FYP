import matplotlib.pyplot as plt
import random

fd = open("line_segs.txt", "r")

number_of_colors = 50
colors = ["#"+''.join([random.choice('0123456789ABCDEF') for j in range(6)]) for i in range(number_of_colors)]

id = -1
x = []
y = []

while True:
    try:
        str = fd.next()
    except Exception as e:
        break
    if str == "\n":
        if id > 0 and abs(x[0] - x[1]) < 100:
            plt.plot(y, x, color = colors[int(id % number_of_colors)])
        x = []
        y = []
    else:
        str = str.split( )
        if len(str) == 2:
            x.append((float(str[0]) - 22.419915) * 111000.0)
            y.append((float(str[1]) - 114.20774) * 85390.0)
        else:
            id = float(str[0])
        
fd.close()


plt.axis('scaled')
plt.show()