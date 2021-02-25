#ifndef ROUTE_H
#define ROUTE_H

#include "data_struct.h"
#include "connect.h"
#include <stdio.h>
#include <string.h>

route_t* generate_routes (traj_t* trajs, int trajs_size, loc_t* locs, int locs_size, int* routes_size);

traj_t* split_trajs(traj_t* trajs, int* trajs_size, coor_t* points, int points_num);

coor_t* sub_points (traj_t traj, int start_index, int end_index);

coor_t find_closest_point(loc_t loc, traj_t* trajs, int trajs_size);

void find_routes (traj_t* trajs, int trajs_size, int* is_trajs_marked, loc_t* locs, int locs_size, coor_t* closest_points, route_t* routes, int* routes_size, route_t cur_route);

void append_route (route_t* routes, int* routes_size, route_t route);


#endif