#include "route.h"

#define MIN_DIST 20

route_t* generate_routes (traj_t* trajs, int trajs_size, loc_t* locs, int locs_size, int* routes_size) {
    
    route_t* routes = (route_t*) malloc(sizeof(route_t) * locs_size * locs_size);
    *routes_size = 0;
    
    // Step 1: preprocess. split trajs
    coor_t* closest_points = (coor_t*) malloc(sizeof(coor_t) * locs_size);
    for (int i = 0; i <locs_size; i++) {
        closest_points[i] = find_closest_point(locs[i], trajs, trajs_size);
    }
    
    int processed_trajs_size = trajs_size;
    traj_t* processed_trajs = split_trajs(trajs, &processed_trajs_size, closest_points, locs_size);

    // Step 2: add direct route between two locations to route
    for (int i = 0; i < processed_trajs_size; i++) { // for each traj in processed_trajs

        traj_t traj = processed_trajs[i];
        if (traj.points_num < 2) {
            continue;
        }

        int start_index = first_index_of (closest_points, locs_size, traj.points[0]);
        int end_index = first_index_of (closest_points, locs_size, traj.points[traj.points_num - 1]);

        if (start_index == -1 || end_index == -1 || start_index == end_index) {
            continue;
        }

        //construct a route
        routes[*routes_size].start_loc = locs[start_index];
        routes[*routes_size].end_loc = locs[end_index];

        routes[*routes_size].points = (coor_t*) malloc(sizeof(coor_t) * (traj.points_num + 2));
        routes[*routes_size].points_num = traj.points_num + 2;
        routes[*routes_size].points[0].lat = locs[start_index].lat;
        routes[*routes_size].points[0].lng = locs[start_index].lng;
        routes[*routes_size].points[0].alt = locs[start_index].alt;
        for (int j = 0; j < traj.points_num; j ++) {
            routes[*routes_size].points[j+1] = traj.points[j];
        }
        routes[*routes_size].points[traj.points_num + 1].lat = locs[end_index].lat;
        routes[*routes_size].points[traj.points_num + 1].lng = locs[end_index].lng;
        routes[*routes_size].points[traj.points_num + 1].alt = locs[end_index].alt;

        double dist = 0;
        for (int j = 0; j < traj.points_num - 1; j ++) {
            dist += dist_coor_coor(routes[*routes_size].points[j], routes[*routes_size].points[j+1]);
        }
        routes[*routes_size].dist = dist;

        *routes_size = *routes_size + 1;
    }

    // Step 3: remove checked traj in step 2
    
    
    return routes;
}


/*
 *  Aim: split trajs with given points
 *  In: trajs, trajs_size, points, point_num
 *  Out: new_trajs, trajs_size
 *  Test: OK.
 */
traj_t* split_trajs(traj_t* trajs, int* trajs_size, coor_t* points, int points_num) {
    
    traj_t* new_trajs = (traj_t*) malloc(sizeof(traj_t) * (*trajs_size) * (points_num + 1));
    int new_trajs_size = 0;

    for (int i = 0; i < *trajs_size; i ++) { // for each traj
        // mark at which index should be splited
        int* marks = (int*) malloc(sizeof(int) * (points_num + 2));
        marks[0] = 0;
        int marks_size = 1;
        
        for (int j = 1; j < trajs[i].points_num - 1; j ++) { // for each point
            if (contains(points, points_num, trajs[i].points[j])) { // need to split
                marks[marks_size] = j;
                marks_size ++;
            }
        }
        marks[marks_size] = trajs[i].points_num - 1;
        marks_size++;

        // start split
        for (int j = 0; j < marks_size - 1; j ++) {
            new_trajs[new_trajs_size].points = sub_points (trajs[i], marks[j], marks[j+1]);
            new_trajs[new_trajs_size].points_num = marks[j+1] - marks[j] + 1;
            new_trajs_size ++;
        }
    }
    *trajs_size = new_trajs_size;

    return new_trajs;
}

coor_t* sub_points (traj_t traj, int start_index, int end_index) {
    coor_t* points = (coor_t*) malloc(sizeof(coor_t) * (end_index - start_index + 1));
    for (int i = start_index; i <= end_index; i++ ) {
        points[i - start_index] = traj.points[i];
    }
    return points;
}

/*
 *  Aim: find closest point from loc in trajs.
 *  In: loc, trajs, trajs_size.
 *  Out: return (coor_t) closest_point.
 *  Test: TODO.
 */
coor_t find_closest_point(loc_t loc, traj_t* trajs, int trajs_size) {
    double min_dist = MIN_DIST;
    coor_t closest_point;
    closest_point.lat = -1;
    closest_point.lng = -1;
    closest_point.alt = -1;

    for (int i = 0; i < trajs_size; i ++) {
        for (int j = 0; j < trajs[i].points_num; j ++) {
            double dist = dist_loc_coor (loc, trajs[i].points[j]);
            if (dist < min_dist) {
                min_dist = dist;
                closest_point = trajs[i].points[j];
            }
        }
    }
    return closest_point;
}



