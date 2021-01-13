#ifndef ROUTE_H
#define ROUTE_H

#include "data_struct.h"
#include "connect.h"
#include <math.h>
#include<stdio.h>

typedef struct {
    loc_t start_loc;
    loc_t end_loc;

    coor_t* points;
    int points_num;

    double dist;
} route_t;

route_t* generate_routes (traj_t* trajs, int trajs_size, loc_t* locs, int locs_size, int* routes_size);

traj_t* split_trajs(traj_t* trajs, int* trajs_size, coor_t* points, int points_num);

coor_t* sub_points (traj_t traj, int start_index, int end_index);

coor_t find_closest_point(loc_t loc, traj_t* trajs, int trajs_size);

#endif