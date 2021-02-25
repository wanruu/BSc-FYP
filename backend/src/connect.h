#ifndef CONNECT_H
#define CONNECT_H

#include "data_struct.h"
#include "queue.h"

traj_t* smooth(traj_t* trajs, int* trajs_size);

neighbor_trajs_t** find_neighbors(traj_t* trajs, int trajs_size);

int* connect_index(traj_t* trajs, int trajs_size, coor_t* omit_points, int omit_points_size);

int contains (coor_t* points, int points_size, coor_t point);

int first_index_of (coor_t* points, int points_size, coor_t point);

int equals (coor_t point1, coor_t point2);

#endif