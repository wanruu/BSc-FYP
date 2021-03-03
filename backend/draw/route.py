import matplotlib.pyplot as plt

fd = open("route.txt", "r")

x = []
y = []

while True:
    try:
        str = fd.next()
    except Exception as e:
        break
    if str == "\n":
        plt.plot(y, x)
        x = []
        y = []
    else:
        str = str.split( )
        x.append((float(str[0]) - 22.419915) * 111000.0)
        y.append((float(str[1]) - 114.20774) * 85390.0)

#plt.scatter([(114.207492 - 114.20774) * 85390.0], [(22.421363 - 22.419915) * 111000.0], marker='o', color='r')

#plt.scatter([(114.207843 - 114.20774) * 85390.0], [(22.420899 - 22.419915) * 111000.0], marker='o', color='g')


fd.close()


plt.axis('scaled')
plt.show()