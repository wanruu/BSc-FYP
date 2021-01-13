#ifndef CONNECT_H
#define CONNECT_H

#include "data_struct.h"
#include "queue.h"
#include <math.h>
#include <stdlib.h>

typedef struct {
    int trajs_indexes[100]; // now no more than 11
    int points_indexes[100];
    int neighbors_num;
} neighbor_trajs_t; // a neighbor (x, y) = (trajs_indexes[i], points_indexes[i]) -> trajs[x][y]

traj_t* smooth(traj_t* trajs, int* trajs_size);

double coor_t_dist (coor_t p1, coor_t p2);

neighbor_trajs_t** find_neighbors(traj_t* trajs, int trajs_size);

int* connect_index(traj_t* trajs, int trajs_size, coor_t* omit_points, int omit_points_size);

int contains (coor_t* points, int points_size, coor_t point);

int first_index_of (coor_t* points, int points_size, coor_t point);

int equals (coor_t point1, coor_t point2);

#endif