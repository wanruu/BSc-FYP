CC = gcc
CFLAGS = -std=c99
LIB = -I/usr/local/include -lmongoc-1.0 -lbson-1.0 -lm

process: main.o data_struct.o queue.o part.o cluster.o represent.o connect.o route.o
	${CC} -o ../process main.o data_struct.o queue.o part.o cluster.o represent.o connect.o route.o ${LIB}

main.o: main.c
	${CC} ${CFLAGS} -c main.c 

data_struct.o: data_struct.c data_struct.h
	${CC} ${CFLAGS} -c data_struct.c

queue.o: queue.c queue.h
	${CC} ${CFLAGS} -c queue.c

part.o: part.c part.h data_struct.h
	${CC} ${CFLAGS} -c part.c

cluster.o: cluster.c cluster.h data_struct.h queue.h
	${CC} ${CFLAGS} -c cluster.c

represent.o: represent.c represent.h data_struct.h
	${CC} ${CFLAGS} -c represent.c

connect.o: connect.c connect.h data_struct.h queue.h
	${CC} ${CFLAGS} -c connect.c

route.o: route.c route.h data_struct.h
	${CC} ${CFLAGS} -c route.c

# clean
clean: 
	rm *.o