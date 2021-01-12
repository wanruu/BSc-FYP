process: main.o queue.o dist.o part.o cluster.o data_struct.o represent.o connect.o
	gcc -o process main.o dist.o part.o cluster.o queue.o data_struct.o represent.o connect.o -I/usr/local/include -lmongoc-1.0 -lbson-1.0

main.o: main.c
	gcc -c main.c 

data_struct.o: data_struct.c data_struct.h
	gcc -c data_struct.c

queue.o: queue.c queue.h
	gcc -c queue.c

dist.o: dist.c dist.h data_struct.h
	gcc -c dist.c

part.o: part.c part.h data_struct.h dist.h
	gcc -c part.c

cluster.o: cluster.c cluster.h data_struct.h queue.h
	gcc -c cluster.c

represent.o: represent.c represent.h data_struct.h
	gcc -c represent.c

connect.o: connect.c connect.h data_struct.h queue.h
	gcc -c connect.c

# clean
clean: 
	rm *.o