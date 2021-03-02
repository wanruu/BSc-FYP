#ifndef CONNECT_H
#define CONNECT_H

#include "data_struct.h"
#include "queue.h"

// traj_t* connect_trajs(traj_t* trajs, int* trajs_size);
traj_t* connect_trajs(traj_t* trajs, int* trajs_size, int min_dist, int min_num);

// neighbor_trajs_t** find_neighbors(traj_t* trajs, int trajs_size);
neighbor_trajs_t** find_neighbors(traj_t* trajs, int trajs_size, int min_dist);

int* connect_index(traj_t* trajs, int trajs_size, coor_t* omit_points, int omit_points_size);

void find_overlapped_traj(traj_t traj1, traj_t traj2, int* start_index, int* end_index);

traj_t clean_palindrome(traj_t traj);

coor_t find_closest_point_for_point(coor_t* points, int points_num, coor_t point, coor_t omitted_point);

coor_t* remove_first_point(coor_t* points, int *points_num, coor_t point);

#endif