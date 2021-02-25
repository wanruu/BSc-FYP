#ifndef QUEUE_H
#define QUEUE_H

typedef struct Node {
    int data;
    struct Node* next;
} node_t;
 
typedef struct {
    node_t* start;
    node_t* end;
} queue_t;

typedef struct Node_ARR {
    int* data; 
    struct Node_ARR* next;
} node_arr_t;

typedef struct {
    node_arr_t* start;
    node_arr_t* end;
} queue_arr_t;

queue_t* create_queue();

int first_num(queue_t* queue);

void enqueue(queue_t* queue, int num);
 
int is_empty_queue(queue_t* queue);
 
int dequeue(queue_t* queue);

void print_queue(queue_t* queue);


queue_arr_t* create_arr_queue();

void enqueue_arr(queue_arr_t* queue, int* nums);

int is_empty_queue_arr(queue_arr_t* queue);
 
int* dequeue_arr(queue_arr_t* queue);

#endif