process: main.o queue.o dist.o part.o cluster.o data_struct.o represent.o connect.o route.o
	gcc -o process main.o dist.o part.o cluster.o queue.o data_struct.o represent.o connect.o route.o -I/usr/local/include -lmongoc-1.0 -lbson-1.0 -lm

main.o: main.c
	gcc -std=c99 -c main.c 

data_struct.o: data_struct.c data_struct.h
	gcc -std=c99 -c data_struct.c

queue.o: queue.c queue.h
	gcc -std=c99 -c queue.c

dist.o: dist.c dist.h data_struct.h
	gcc -std=c99 -c dist.c

part.o: part.c part.h data_struct.h dist.h
	gcc -std=c99 -c part.c

cluster.o: cluster.c cluster.h data_struct.h queue.h
	gcc -std=c99 -c cluster.c

represent.o: represent.c represent.h data_struct.h
	gcc -std=c99 -c represent.c

connect.o: connect.c connect.h data_struct.h queue.h
	gcc -std=c99 -c connect.c

route.o: route.c route.h data_struct.h
	gcc -std=c99 -c route.c

# clean
clean: 
	rm *.o