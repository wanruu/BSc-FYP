#include "route.h"

#define MIN_DIST 100

/*
 *  Aim: generate routes.
 *  In: trajs, trajs_size, locs, locs_size.
 *  Out: routes, routes_size.
 */

route_t* generate_routes (traj_t* trajs, int trajs_size, loc_t* locs, int locs_size, int* routes_size) {

    // Step 0: prepare output.
    route_t* routes = (route_t*) malloc(sizeof(route_t) * locs_size * locs_size);
    *routes_size = 0;
    
    // Step 1: preprocess. 
    
    // find the closest point for each loc.
    coor_t* closest_points = (coor_t*) malloc(sizeof(coor_t) * locs_size);
    for (int i = 0; i < locs_size; i ++) {
        closest_points[i] = find_closest_point(locs[i], trajs, trajs_size);
        // printf("%s, %f %f %f\n", locs[i].name, closest_points[i].lat, closest_points[i].lng, closest_points[i].alt);
    }
    // split trajs by closest points.
    int processed_trajs_size = trajs_size;
    traj_t* processed_trajs = split_trajs(trajs, &processed_trajs_size, closest_points, locs_size);

    // Step 2: try to connect trajs as much as possible
    int* is_trajs_marked = (int*) malloc (sizeof(int) * processed_trajs_size);
    for (int i = 0; i < processed_trajs_size; i ++) {
        is_trajs_marked[i] = 0;
    }
    
    // first, find direct route
    for (int i = 0; i < processed_trajs_size; i ++) {
        int start_index = first_index_of (closest_points, locs_size, processed_trajs[i].points[0]);
        int end_index = first_index_of (closest_points, locs_size, processed_trajs[i].points[processed_trajs[i].points_num-1]);
        if (start_index != -1 && end_index != -1) {
            // printf("%s == %s\n", locs[start_index].name, locs[end_index].name);
            routes[*routes_size].start_loc = locs[start_index];
            routes[*routes_size].end_loc = locs[end_index];
            routes[*routes_size].points = processed_trajs[i].points;
            routes[*routes_size].points_num = processed_trajs[i].points_num;
            // compute distance
            double dist = 0;
            for (int j = 0; j < processed_trajs[i].points_num - 1; j ++) {
                dist += dist_coor_coor (processed_trajs[i].points[j], processed_trajs[i].points[j+1]);
            }
            routes[*routes_size].dist = dist;

            *routes_size = *routes_size + 1;
            is_trajs_marked[i] = 1;
        }
    }

    // then, find others
    route_t cur_route = empty_route(1);
    find_routes (processed_trajs, processed_trajs_size, is_trajs_marked, locs, locs_size, closest_points, routes, routes_size, cur_route);

    // Step 3: if closest points of two locs are the same, generate a new route
    for (int i = 0; i < locs_size; i ++) {
        for (int j = i + 1; j < locs_size; j ++) {
            if (closest_points[i].lat != -1 && equals(closest_points[i], closest_points[j])) {
                // printf("%s | %s\n", locs[i].name, locs[j].name);
                routes[*routes_size].start_loc = locs[i];
                routes[*routes_size].end_loc = locs[j];

                // generate 3 points averagely
                coor_t* points = (coor_t*) malloc(sizeof(coor_t) * 3);
                points[0].lat = locs[i].lat;
                points[0].lng = locs[i].lng;
                points[0].alt = locs[i].alt;
                points[1].lat = (locs[i].lat + locs[j].lat) / 2;
                points[1].lng = (locs[i].lng + locs[j].lng) / 2;
                points[1].alt = (locs[i].alt + locs[j].alt) / 2;
                points[2].lat = locs[j].lat;
                points[2].lng = locs[j].lng;
                points[2].alt = locs[j].alt;
                routes[*routes_size].points = points;
                routes[*routes_size].points_num = 3;

                routes[*routes_size].dist = dist_coor_coor(points[0], points[1]) + dist_coor_coor(points[1], points[2]);
                *routes_size = *routes_size + 1;
            }
        }
    }

    return routes;
}

void find_routes (traj_t* trajs, int trajs_size, int* is_trajs_marked, 
    loc_t* locs, int locs_size, coor_t* closest_points, 
    route_t* routes, int* routes_size, route_t cur_route) {

    if (strlen(cur_route.start_loc.id) != 0 && strlen(cur_route.end_loc.id) != 0) { // cur_route ok

        int repeated = 0;
        for (int i = 0; i < *routes_size; i ++) {
            if (strcmp(routes[i].start_loc.id, cur_route.end_loc.id) == 0 && strcmp(routes[i].end_loc.id, cur_route.start_loc.id) == 0) {
                repeated = 1;
                break;
            }
        }
        if (!repeated && strcmp(cur_route.start_loc.id, cur_route.end_loc.id) != 0) {
            // compute distance
            double dist = 0;
            for (int i = 0; i < cur_route.points_num - 1; i ++) {
                dist += dist_coor_coor (cur_route.points[i], cur_route.points[i + 1]);
            }
            cur_route.dist = dist;

            append_route (routes, routes_size, cur_route);
        }

    } else if(strlen(cur_route.start_loc.id) == 0 && strlen(cur_route.end_loc.id) == 0) { // cur_route empty
        for (int i = 0; i < trajs_size; i ++) { 
            if (!is_trajs_marked[i]) { // for each unmarked traj

                // check if this traj has start or end loc
                int start_index = first_index_of (closest_points, locs_size, trajs[i].points[0]);
                int end_index = first_index_of (closest_points, locs_size, trajs[i].points[trajs[i].points_num - 1]);

                if (start_index != -1) {
                    cur_route.start_loc = locs[start_index];
                    memcpy(cur_route.points, trajs[i].points, sizeof(coor_t) * trajs[i].points_num);
                    cur_route.points_num = trajs[i].points_num;
                    is_trajs_marked[i] = 1;
                    find_routes(trajs, trajs_size, is_trajs_marked, locs, locs_size, closest_points, routes, routes_size, cur_route);
                    cur_route.start_loc = empty_loc();
                    cur_route.points_num = 0;
                    is_trajs_marked[i] = 0;
                } else if (end_index != -1) {
                    cur_route.start_loc = locs[end_index];
                    cur_route.points = (coor_t*) malloc(sizeof(coor_t) * trajs[i].points_num);
                    for (int j = trajs[i].points_num - 1; j >= 0; j --) {
                        cur_route.points[trajs[i].points_num - 1 - j] = trajs[i].points[j];
                    }
                    cur_route.points_num = trajs[i].points_num;
                    is_trajs_marked[i] = 1;
                    find_routes(trajs, trajs_size, is_trajs_marked, locs, locs_size, closest_points, routes, routes_size, cur_route);
                    cur_route.end_loc = empty_loc();
                    cur_route.points_num = 0;
                    is_trajs_marked[i] = 0;
                }
            }
        }
    } else if (strlen(cur_route.start_loc.id) != 0) { // only have start loc 
        for (int i = 0; i < trajs_size; i ++) { 
            if (!is_trajs_marked[i]) { // for each unmarked traj

                coor_t check_point = cur_route.points[cur_route.points_num - 1];
                coor_t start_point = trajs[i].points[0];
                coor_t end_point = trajs[i].points[trajs[i].points_num - 1];

                if (equals(check_point, start_point)) {
                    coor_t* new_points = (coor_t*) malloc(sizeof(coor_t) * (cur_route.points_num + trajs[i].points_num - 1));
                    memcpy(new_points, cur_route.points, sizeof(coor_t) * cur_route.points_num);
                    for (int j = cur_route.points_num; j < cur_route.points_num + trajs[i].points_num - 1; j ++) {
                        new_points[j] = trajs[i].points[j - cur_route.points_num + 1];
                    }
                    cur_route.points = new_points;
                    cur_route.points_num += trajs[i].points_num - 1;

                    int end_index = first_index_of (closest_points, locs_size, end_point);
                    if (end_index != -1) {
                        cur_route.end_loc = locs[end_index];
                    }

                    is_trajs_marked[i] = 1;

                    find_routes(trajs, trajs_size, is_trajs_marked, locs, locs_size, closest_points, routes, routes_size, cur_route);

                    cur_route.points_num -= trajs[i].points_num - 1;
                    cur_route.end_loc = empty_loc();
                    is_trajs_marked[i] = 0;

                } else if (equals(check_point, end_point)) {
                    coor_t* new_points = (coor_t*) malloc(sizeof(coor_t) * (cur_route.points_num + trajs[i].points_num - 1));
                    memcpy(new_points, cur_route.points, sizeof(coor_t) * cur_route.points_num);
                    for (int j = cur_route.points_num; j < cur_route.points_num + trajs[i].points_num - 1; j ++) {
                        new_points[j] = trajs[i].points[cur_route.points_num + trajs[i].points_num - 2 - j];
                    }
                    cur_route.points = new_points;
                    cur_route.points_num += trajs[i].points_num - 1;

                    int start_index = first_index_of (closest_points, locs_size, start_point);
                    if (start_index != -1) {
                        cur_route.end_loc = locs[start_index];
                    }

                    is_trajs_marked[i] = 1;

                    find_routes(trajs, trajs_size, is_trajs_marked, locs, locs_size, closest_points, routes, routes_size, cur_route);

                    cur_route.points_num -= trajs[i].points_num - 1;
                    cur_route.end_loc = empty_loc();
                    is_trajs_marked[i] = 0;

                }
            }
        }
    } else { // only
        printf("This shouldn't be printed!!\n");
    }


}


void append_route (route_t* routes, int* routes_size, route_t route) {

    routes[*routes_size].start_loc = route.start_loc;
    routes[*routes_size].end_loc = route.end_loc;

    routes[*routes_size].points = (coor_t*) malloc (sizeof(coor_t) * route.points_num);
    for (int i = 0; i < route.points_num; i ++) {
        routes[*routes_size].points[i] = route.points[i];
    }
    routes[*routes_size].points_num = route.points_num;

    routes[*routes_size].dist = route.dist;

    *routes_size = *routes_size + 1;
}

/*
 *  Aim: split trajs with given points
 *  In: trajs, trajs_size, points, point_num
 *  Out: new_trajs, trajs_size
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
        marks_size ++;

        // printf("%d\n", marks_size-2);
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
    for (int i = start_index; i <= end_index; i ++) {
        points[i - start_index] = traj.points[i];
    }
    return points;
}

/*
 *  Aim: find closest point from loc in trajs.
 *  In: loc, trajs, trajs_size.
 *  Out: return (coor_t) closest_point.
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



