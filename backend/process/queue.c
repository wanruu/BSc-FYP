#include "queue.h"

queue_t* create_queue() {
    queue_t* queue = (queue_t*) malloc(sizeof(queue_t));
    if (!queue) {
        printf("no enough memory\n");
        return NULL;
    }
    queue->start = NULL;
    queue->end = NULL;
    return queue;
}

void enqueue(queue_t* queue, int num) {
    node_t* node = (node_t*) malloc(sizeof(node_t));
    if (!node) {
        printf("no enough memory\n");
        return;
    }

    node->data = num;
    node->next = NULL;
    if (queue->start == NULL) {
        queue->start = node;
    }
    if (queue->end == NULL) {
        queue->end = node;
    } else {
        queue->end->next = node;
        queue->end = node;
    }
}
 
int is_empty_queue(queue_t* queue){
    return (queue->start == NULL);
}
 
int dequeue(queue_t* queue) {
    if (is_empty_queue(queue)) {
        printf("Empty queue\n");
        return ERROR;
    }
    node_t* temp = queue->start;
    int num;

    
    if (queue->start == queue->end) { // if only one item in queue
        queue->start = NULL;
        queue->end = NULL;
    } else {
        queue->start = queue->start->next;
    }
    num = temp->data;
    free(temp);
    return num;
}

void print_queue(queue_t* queue) {
    if (is_empty_queue(queue)) {
        printf("Empty queue\n");
        return;
    }

    node_t* node = queue->start;
    while (node != NULL) {
        printf("%d " , node->data);
        node = node->next;
    }
    printf("\n");
}


// for int array
queue_arr_t* create_arr_queue() {
    queue_arr_t* queue = (queue_arr_t*) malloc(sizeof(queue_arr_t));
    if (!queue) {
        printf("no enough memory\n");
        return NULL;
    }
    queue->start = NULL;
    queue->end = NULL;
    return queue;
}

void enqueue_arr (queue_arr_t* queue, int* nums) {
    node_arr_t* node = (node_arr_t*) malloc(sizeof(node_arr_t));
    if (!node) {
        printf("no enough memory\n");
        return;
    }

    node->data = nums;
    node->next = NULL;
    if (queue->start == NULL) {
        queue->start = node;
    }
    if (queue->end == NULL) {
        queue->end = node;
    } else {
        queue->end->next = node;
        queue->end = node;
    }
}
 
int is_empty_queue_arr(queue_arr_t* queue){
    return (queue->start == NULL);
}
 
int* dequeue_arr(queue_arr_t* queue) {
    int* nums = (int*) malloc(sizeof(int) * 2);
    
    if (is_empty_queue_arr(queue)) {
        printf("Empty queue\n");
        nums[0] = ERROR;
        nums[1] = ERROR;
        return nums;
    }

    node_arr_t* temp = queue->start;


    if (queue->start == queue->end) { // if only one item in queue
        queue->start = NULL;
        queue->end = NULL;
    } else {
        queue->start = queue->start->next;
    }
    nums = temp->data;
    free(temp);
    return nums;
}
