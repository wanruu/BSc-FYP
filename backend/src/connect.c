#include "connect.h"
#include <string.h>

// #define MIN_DIST 18
// #define MIN_NUM 2

/*
 *  Aim: main func. smooth and connect trajs by clustering.
 *  In: trajs, trajs_size.
 *  Out: trajs, trajs_size.
 */

traj_t* connect_trajs(traj_t* trajs, int* trajs_size, int min_dist, int min_num) {
    
    // Step 1: Find neighbors of each point
    neighbor_trajs_t** neighbor_list = find_neighbors(trajs, *trajs_size, min_dist);
    
    // Step 2: Cluster
    // cluster[i][j]. 0: unclustered, -1: noise, others: clusterId of trajs[i][j]
    int** cluster = (int**) malloc(sizeof(int*) * *trajs_size);
    for (int i = 0; i < *trajs_size; i++) {
        cluster[i] = (int*) malloc(sizeof(int) * trajs[i].points_num);
        for (int j = 0; j < trajs[i].points_num; j ++) {
            cluster[i][j] = 0;
        }
    }

    int cluster_id = 1;
    
    for (int i = 0; i < *trajs_size; i ++) { // for each traj
        for (int j = 0; j < trajs[i].points_num; j ++) { // for each point in traj
            
            if (cluster[i][j] != 0) { continue; } // if classfied

            neighbor_trajs_t neighbors = neighbor_list[i][j];

            if (neighbors.neighbors_num >= min_num) { // it's core point
                // assgin cluster_id to self and each neighbor
                cluster[i][j] = cluster_id;
                for (int k = 0; k < neighbors.neighbors_num; k++) {
                    int x = neighbors.trajs_indexes[k];
                    int y = neighbors.points_indexes[k];
                    cluster[x][y] = cluster_id;
                }

                // expand cluster to its neighbors' neighbors
                queue_arr_t* queue = create_arr_queue();
                for (int k = 0 ; k < neighbors.neighbors_num; k++) {
                    int* data = (int*) malloc(sizeof(int) * 2);
                    data[0] = neighbors.trajs_indexes[k];
                    data[1] = neighbors.points_indexes[k];
                    enqueue_arr (queue, data);
                }
                
                while (!is_empty_queue_arr(queue)) {
                    int* data = dequeue_arr (queue);
                    int first_i = data[0];
                    int first_j = data[1];

                    neighbor_trajs_t first_neighbors = neighbor_list[first_i][first_j];

                    if (first_neighbors.neighbors_num >= min_num) { // it's core point
                        
                        for (int k = 0; k < first_neighbors.neighbors_num; k++) {
                            int n_i = first_neighbors.trajs_indexes[k];
                            int n_j = first_neighbors.points_indexes[k];
                            if (cluster[n_i][n_j] == 0 || cluster[n_i][n_j] == -1) {
                                cluster[n_i][n_j] = cluster_id;
                            }
                            if (cluster[n_i][n_j] == 0) {
                                int* new_data = (int*) malloc(sizeof(int) * 2);
                                new_data[0] = n_i;
                                new_data[1] = n_j;
                                enqueue_arr(queue, new_data);
                            }
                        }
                    }
                }
                cluster_id += 1;
            } else {
                cluster[i][j] = -1;
            }
        }
    }
    
    // Step 3: Calculate average point for each cluster
    coor_t* aver_points = (coor_t*) malloc(sizeof(coor_t) * (cluster_id - 1));
    for (int i = 0; i < cluster_id - 1; i++) {
        aver_points[i].lat = 0;
        aver_points[i].lng = 0;
        aver_points[i].alt = 0;
    }

    int* nums = (int*) malloc(sizeof(int) * (cluster_id - 1)); // num of points in each cluster
    for (int i = 0; i < cluster_id - 1; i++) {
        nums[i] = 0;
    }
    for (int i = 0; i < *trajs_size; i++) {
        for(int j = 0; j < trajs[i].points_num; j++) { // for each point
            int id = cluster[i][j];
            if (id >= 1) {
                aver_points[id-1].lat += trajs[i].points[j].lat;
                aver_points[id-1].lng += trajs[i].points[j].lng;
                aver_points[id-1].alt += trajs[i].points[j].alt;
                nums[id-1] += 1;
            }
        }
    }
    for (int i = 0; i < cluster_id - 1; i++) {
        aver_points[i].lat /= (double)(nums[i]);
        aver_points[i].lng /= (double)(nums[i]);
        aver_points[i].alt /= (double)(nums[i]);
    }


    // Step 4: Replace each point with it's cluster's average point
    for (int i = 0; i < *trajs_size; i++) { // for each traj
        for (int j = 0; j < trajs[i].points_num; j++) { // for each point
            int id = cluster[i][j];
            if (id >= 1) {
                trajs[i].points[j] = aver_points[id-1];
            }
        }
    }

    // also remove repeated point in one traj
    for (int i = 0; i < *trajs_size; i++) { // for each traj: trajs[i]

        coor_t* points_after = (coor_t*) malloc(sizeof(coor_t) * trajs[i].points_num);
        int points_num_after = 0;

        // add first point
        points_after[0] = trajs[i].points[0];
        points_num_after++;
        coor_t last_point = trajs[i].points[0];

        for (int index = 1; index < trajs[i].points_num; index++) {
            if (!equals(trajs[i].points[index], last_point)) {
                points_after[points_num_after] = trajs[i].points[index];
                points_num_after++;
                last_point = trajs[i].points[index];
            } 
        }

        trajs[i].points = points_after;
        trajs[i].points_num = points_num_after;
    }

    // clean palindrome
    for (int i = 0; i < *trajs_size; i ++) {
        trajs[i] = clean_palindrome(trajs[i]);
    }


    // if traj1 and traj2 are overlapped, remove overlapped part of traj1
    int start_index;
    int end_index;
    for (int i = 0; i < *trajs_size; i ++) { // for each traj
        for (int j = i + 1; j < *trajs_size; j ++) { // for next traj
            find_overlapped_traj(trajs[i], trajs[j], &start_index, &end_index);
            // remove overlapped points of traj1
            if (start_index == 0) {
                coor_t* new_points = (coor_t*) malloc(sizeof(coor_t) * trajs[i].points_num);
                int new_points_num = 0;
                for (int k = end_index; k < trajs[i].points_num; k ++) {
                    new_points[new_points_num] = trajs[i].points[k];
                    new_points_num += 1; 
                }
                trajs[i].points = new_points;
                trajs[i].points_num = new_points_num;
            } else if (end_index == trajs[i].points_num - 1) {
                trajs[i].points_num -= end_index - start_index;
            }
        }
    }

    // remove traj whose size < 2
    traj_t* trajs_after = (traj_t*) malloc(sizeof(traj_t) * (*trajs_size)); 
    int trajs_size_after = 0; 

    for (int index = 0; index < *trajs_size; index++) {
        if (trajs[index].points_num >= 2) {
            trajs_after[trajs_size_after] = trajs[index];
            trajs_size_after++;
        }
    }
    trajs = trajs_after;
    *trajs_size = trajs_size_after;

    // test: result same as omit_points
    /*int total_points_num = 0;
    for (int i = 0; i < *trajs_size; i ++) {
        total_points_num += trajs[i].points_num;
    }
    coor_t* unique_points = (coor_t*) malloc(sizeof(coor_t) * total_points_num);
    int* unique_points_count = (int*) malloc(sizeof(int) * total_points_num);
    int unique_points_num = 0;
    
    for (int i = 0; i < *trajs_size; i ++) {
        for (int j = 0; j < trajs[i].points_num; j ++) {
            int index = first_index_of(unique_points, unique_points_num, trajs[i].points[j]);
            int weight = 2;
            if (j == 0 || j == trajs[i].points_num - 1) {
                weight = 1;
            }
            if (index == -1) {
                unique_points[unique_points_num] = trajs[i].points[j];
                unique_points_count[unique_points_num] = weight;
                unique_points_num += 1;
            } else {
                unique_points_count[index] += weight;
            }
        }
    }

    int count = 0;
    for (int i = 0; i < unique_points_num; i ++) {
        if (unique_points_count[i] >= 3) {
            count += 1;
        }
    }
    printf("unique == %d\n", count);*/
    

    // Step 5: Find omit_points -> crossroads.
    // recalculate nums: point number of each cluster
    for (int i = 0; i < cluster_id - 1; i++) {
        nums[i] = 0;
    }
    for (int i = 0; i < *trajs_size; i++) {
        for (int j = 0; j < trajs[i].points_num; j++) { // for each point
            int index = first_index_of(aver_points, cluster_id - 1, trajs[i].points[j]);
            if (index != -1) {
                if (j == 0 || j == trajs[i].points_num - 1) {
                    nums[index] += 1;
                } else {
                    nums[index] += 2;
                }
            }
        }
    }
    // find omit
    coor_t* omit_points = (coor_t*) malloc(sizeof(coor_t) * 100);
    int omit_points_size = 0;
    for (int i = 0; i < cluster_id - 1; i++) {
        if (nums[i] > 2) {
            omit_points[omit_points_size] = aver_points[i];
            omit_points_size++;
        }
    }

    // test: for drawing omit_points using python
    /*printf("plt.scatter([");
    for (int i = 0; i < omit_points_size; i ++) {
        printf("%f, ", (omit_points[i].lng - 114.20774) * 85390);
    }
    printf("], [");
    for (int i = 0; i < omit_points_size; i ++) {
        printf("%f, ", (omit_points[i].lat - 22.419915) * 111000);
    }
    printf("], marker='o', color='r')\n");*/


    // Step 6: Spilt trajs who has a omit_point in it.
    traj_t* splited_trajs = (traj_t*) malloc(sizeof(traj_t) * (*trajs_size) * 3);
    int splited_trajs_size = 0;

    for (int i = 0; i < *trajs_size; i ++) { // for each traj
        // find split indexes
        int* indexes = (int*) malloc(sizeof(int) * (omit_points_size + 2));
        indexes[0] = 0;
        int indexes_size = 1;

        for (int j = 1; j < trajs[i].points_num - 1; j ++) { // for each mid point    
            if (contains(omit_points, omit_points_size, trajs[i].points[j])) {
                indexes[indexes_size] = j;
                indexes_size += 1;
            }
        }

        indexes[indexes_size] = trajs[i].points_num - 1;
        indexes_size += 1;

        // start spliting
        int last_split_index = 0;
        for (int j = 0; j < indexes_size; j ++) { // for each split index
            int this_split_index = indexes[j];
            if (last_split_index >= this_split_index) { continue; }
            
            traj_t new_traj;
            new_traj.points = (coor_t*) malloc(sizeof(coor_t) * trajs[i].points_num);
            new_traj.points_num = 0;
            for (int k = last_split_index; k <= this_split_index; k ++) {
                new_traj.points[new_traj.points_num] = trajs[i].points[k];
                new_traj.points_num += 1;
            }
            last_split_index = this_split_index;

            splited_trajs[splited_trajs_size] = new_traj;
            splited_trajs_size += 1;
        }
    }
    trajs = splited_trajs;
    *trajs_size = splited_trajs_size;

    // Step 7 (optional): extend traj to connect as much as possible, crossroad not considered

    // find unique point
    coor_t* endpoints = (coor_t*) malloc(sizeof(coor_t) * *trajs_size * 2);
    int* endpoints_count = (int*) malloc(sizeof(int) * *trajs_size * 2);
    int endpoints_num = 0;
    
    for (int i = 0; i < *trajs_size; i ++) {
        int index;

        coor_t start_point = trajs[i].points[0];
        index = first_index_of(endpoints, endpoints_num, start_point);
        if (index == -1) {
            endpoints[endpoints_num] = start_point;
            endpoints_count[endpoints_num] = 1;
            endpoints_num += 1;
        } else {
            endpoints_count[index] += 1;
        }

        coor_t end_point = trajs[i].points[trajs[i].points_num - 1];
        index = first_index_of(endpoints, endpoints_num, end_point);
        if (index == -1) {
            endpoints[endpoints_num] = end_point;
            endpoints_count[endpoints_num] = 1;
            endpoints_num += 1;
        } else {
            endpoints_count[index] += 1;
        }
    }

    coor_t* unique_endpoints = (coor_t*) malloc(sizeof(coor_t) * endpoints_num);
    int unique_endpoints_num = 0;

    for (int i = 0; i < endpoints_num; i ++) {
        if (endpoints_count[i] == 1) {
            unique_endpoints[unique_endpoints_num] = endpoints[i];
            unique_endpoints_num += 1;
        }
    }

    // extend
    for (int i = 0; i < *trajs_size; i ++) {
        coor_t closest_point;
        coor_t start_point = trajs[i].points[0];
        coor_t end_point = trajs[i].points[trajs[i].points_num - 1];


        // consider ending point
        if (contains(unique_endpoints, unique_endpoints_num, end_point)) {
            closest_point = find_closest_point_for_point(unique_endpoints, unique_endpoints_num, end_point, start_point);
            if (closest_point.lat != -1) {
                coor_t* points = (coor_t*) malloc(sizeof(coor_t) * (trajs[i].points_num + 1));
                memcpy(points, trajs[i].points, sizeof(coor_t) * trajs[i].points_num);
                points[trajs[i].points_num] = closest_point;
                trajs[i].points = points;
                trajs[i].points_num += 1;
                unique_endpoints = remove_first_point(unique_endpoints, &unique_endpoints_num, closest_point);
                unique_endpoints = remove_first_point(unique_endpoints, &unique_endpoints_num, end_point);
            }
        }

        // consider starting point
        if (contains(unique_endpoints, unique_endpoints_num, start_point)) {
            closest_point = find_closest_point_for_point(unique_endpoints, unique_endpoints_num, start_point, end_point);
            if (closest_point.lat != -1) {
                coor_t* points = (coor_t*) malloc(sizeof(coor_t) * (trajs[i].points_num + 1));
                int points_num = 1;
                points[0] = closest_point;
                
                for (int j = 0; j < trajs[i].points_num; j ++) {
                    points[points_num] = trajs[i].points[j];
                    points_num += 1;
                }
                trajs[i].points = points;
                trajs[i].points_num = points_num;
                unique_endpoints = remove_first_point(unique_endpoints, &unique_endpoints_num, closest_point);
                unique_endpoints = remove_first_point(unique_endpoints, &unique_endpoints_num, start_point);
            }
        }
    }


    // Step 8: Connect two traj with same endpoint.
    int* indexes = connect_index(trajs, *trajs_size, omit_points, omit_points_size);
    while (indexes[0] != -1 && indexes[1] != -1) {

        // traj to be connected
        traj_t traj1 = trajs[indexes[0]];
        traj_t traj2 = trajs[indexes[1]];

        traj_t new_traj;
        new_traj.points = (coor_t*) malloc(sizeof(coor_t) * (traj1.points_num + traj2.points_num - 1));
        new_traj.points_num = 0;

        if (equals(traj1.points[0], traj2.points[0])) {
            for (int i = traj1.points_num - 1; i > 0; i --) {
                new_traj.points[new_traj.points_num] = traj1.points[i];
                new_traj.points_num += 1;
            }
            for (int i = 0; i < traj2.points_num; i ++) {
                new_traj.points[new_traj.points_num] = traj2.points[i];
                new_traj.points_num += 1;
            }
        } else if (equals(traj1.points[0], traj2.points[traj2.points_num - 1])) {
            for (int i = 0; i < traj2.points_num - 1; i ++) {
                new_traj.points[new_traj.points_num] = traj2.points[i];
                new_traj.points_num += 1;
            }
            for (int i = 0; i < traj1.points_num; i ++) {
                new_traj.points[new_traj.points_num] = traj1.points[i];
                new_traj.points_num += 1;
            }
        } else if (equals(traj1.points[traj1.points_num - 1], traj2.points[0])) {
            for (int i = 0; i < traj1.points_num - 1; i ++) {
                new_traj.points[new_traj.points_num] = traj1.points[i];
                new_traj.points_num += 1;
            }
            for (int i = 0; i < traj2.points_num; i ++) {
                new_traj.points[new_traj.points_num] = traj2.points[i];
                new_traj.points_num += 1;
            }
        } else if (equals(traj1.points[traj1.points_num - 1], traj2.points[traj2.points_num - 1])) {
            for (int i = 0; i < traj2.points_num; i ++) {
                new_traj.points[new_traj.points_num] = traj2.points[i];
                new_traj.points_num += 1;
            }

            for (int i = traj1.points_num - 2; i >= 0; i --) {
                new_traj.points[new_traj.points_num] = traj1.points[i];
                new_traj.points_num += 1;
            }
        }

        // define new trajs
        traj_t* new_trajs = (traj_t*) malloc(sizeof(traj_t) * (*trajs_size - 1));
        int new_trajs_size = 0;

        // move trajs[indexes[0]], trajs[indexes[1]] out of trajs
        for (int i = 0; i < *trajs_size; i ++) {
            if (i != indexes[0] && i != indexes[1]) {
                new_trajs[new_trajs_size] = trajs[i];
                new_trajs_size ++;
            }
        }
        // add new_traj into trajs    
        new_trajs[new_trajs_size] = new_traj;
        new_trajs_size ++;
        
        trajs = new_trajs;
        *trajs_size = new_trajs_size;

        // update indexes
        indexes = connect_index(trajs, *trajs_size, omit_points, omit_points_size);
    }

    return trajs;
}


/*
 *  Aim: find neighbor metrix for each point in trajs.
 *  In: trajs, trajs_size.
 *  Out: return (neighbor_trajs_t**) neighbors.
 */
neighbor_trajs_t** find_neighbors(traj_t* trajs, int trajs_size, int min_dist) {

    // initialize return result
    neighbor_trajs_t** neighbors = (neighbor_trajs_t**) malloc(sizeof(neighbor_trajs_t*) * trajs_size);
    for (int i = 0; i < trajs_size; i++) {
        neighbors[i] = (neighbor_trajs_t*) malloc(sizeof(neighbor_trajs_t) * trajs[i].points_num);
        for (int j = 0; j < trajs[i].points_num; j ++) {
            neighbors[i][j].neighbors_num = 0;
        }
    }

    // find neighbors
    for (int i = 0; i < trajs_size; i ++) { // for each traj
        for (int j = 0; j < trajs[i].points_num; j ++) { // for each point

            for (int a = i + 1; a < trajs_size; a ++) { // for next traj
                for (int b = 0; b < trajs[a].points_num; b ++) { // for each point
                    if (dist_coor_coor(trajs[i].points[j], trajs[a].points[b]) <= min_dist) {
                        int index;

                        index = neighbors[i][j].neighbors_num;
                        neighbors[i][j].trajs_indexes[index] = a;
                        neighbors[i][j].points_indexes[index] = b;
                        neighbors[i][j].neighbors_num = index + 1;

                        index = neighbors[a][b].neighbors_num;
                        neighbors[a][b].trajs_indexes[index] = i;
                        neighbors[a][b].points_indexes[index] = j;
                        neighbors[a][b].neighbors_num = index + 1;
                    }
                }
            }
        }
    }
    return neighbors;
}

/*
 *  Aim: find (index1, index2) that trajs[index1] can be connected with trajs[index2].
 *  In: trajs, trajs_size, omit_points, omit_points_size.
 *  Out: return {index1, index2}
 */

int* connect_index(traj_t* trajs, int trajs_size, coor_t* omit_points, int omit_points_size) {
    int* indexes = (int*) malloc(sizeof(int) * 2);
    indexes[0] = -1;
    indexes[1] = -1;

    for (int i = 0; i < trajs_size; i++) { // for each traj
        coor_t start = trajs[i].points[0];
        coor_t end = trajs[i].points[trajs[i].points_num - 1];

        if (!contains(omit_points, omit_points_size, start)) { // if start point shouldn't be omitted
            for (int j = 0; j < trajs_size; j++) { // for next traj
                if (i == j) { continue; }
                if (equals(start, trajs[j].points[0]) || equals(start, trajs[j].points[trajs[j].points_num - 1])) {
                    indexes[0] = i;
                    indexes[1] = j;
                    return indexes;
                }
            }
        }

        if (!contains(omit_points, omit_points_size, end)) { // if end point shouldn't be omitted
            for (int j = 0; j < trajs_size; j++) { // for next traj
                if (i == j) { continue; }
                if (equals(end, trajs[j].points[0]) || equals(end, trajs[j].points[trajs[j].points_num - 1])) {
                    indexes[0] = i;
                    indexes[1] = j;
                    return indexes;
                }
            }
        }
    }
    return indexes;
}

/*
 * Aim: Find overlapped points of two traj.
 * In: traj1, traj2
 * Out: start/end index of overlapped points in traj1
 */
void find_overlapped_traj(traj_t traj1, traj_t traj2, int* start_index, int* end_index) {
    if (traj1.points_num <= traj2.points_num) {
        if (contains(traj2.points, traj2.points_num, traj1.points[0]) &&
            contains(traj2.points, traj2.points_num, traj1.points[traj1.points_num - 1])) {
            *start_index = 0;
            *end_index = traj1.points_num - 1;
            return;
        }
    }
    if (contains(traj2.points, traj2.points_num, traj1.points[traj1.points_num - 1])) {
        *end_index = traj1.points_num - 1;

        int first_index = first_index_of(traj1.points, traj1.points_num, traj2.points[0]);
        if (first_index != -1 && first_index < *end_index) {
            *start_index = first_index;
            return;
        }
        int last_index = first_index_of(traj1.points, traj1.points_num, traj2.points[traj2.points_num - 1]);
        if (last_index != -1 && last_index < *end_index) {
            *start_index = last_index;
            return;
        }
    }
    if (contains(traj2.points, traj2.points_num, traj1.points[0])) {
        *start_index = 0;

        int first_index = first_index_of(traj1.points, traj1.points_num, traj2.points[0]);
        if (first_index != -1 && *start_index < first_index) {
            *end_index = first_index;
            return;
        }
        int last_index = first_index_of(traj1.points, traj1.points_num, traj2.points[traj2.points_num - 1]);
        if (last_index != -1 && *start_index < last_index) {
            *end_index = last_index;
            return;
        }
    }
    *start_index = -1;
    *end_index = -1;
}

traj_t clean_palindrome(traj_t traj) {
    for (int i = 1; i < traj.points_num - 1; i ++) {
        int left_index = i - 1;
        int right_index = i + 1;
        while (left_index >= 0 && right_index <= traj.points_num - 1) {
            if (equals(traj.points[left_index], traj.points[right_index])) {
                left_index -= 1;
                right_index += 1;
            } else {
                break;
            }
        }
        if (left_index < 0) {
            traj_t new_traj;
            new_traj.points = (coor_t*) malloc(sizeof(coor_t) * traj.points_num);
            new_traj.points_num = 0;
            for (int j = i; j < traj.points_num; j ++) {
                new_traj.points[new_traj.points_num] = traj.points[j];
                new_traj.points_num += 1;
            }
            return new_traj;
        }

        if (right_index > traj.points_num - 1) {
            traj_t new_traj;
            new_traj.points = (coor_t*) malloc(sizeof(coor_t) * traj.points_num);
            new_traj.points_num = 0;
            for (int j = 0; j <= i; j ++) {
                new_traj.points[new_traj.points_num] = traj.points[j];
                new_traj.points_num += 1;
            }
            return new_traj;
        }
    }
    return traj;
}

coor_t find_closest_point_for_point(coor_t* points, int points_num, coor_t point, coor_t omitted_point) {
    double min_dist = 20;
    coor_t closest_point;
    closest_point.lat = -1;
    closest_point.lng = -1;
    closest_point.alt = -1;

    for (int j = 0; j < points_num; j ++) {
        if (equals(points[j], point) || equals(points[j], omitted_point)) {
            continue;
        }
        double dist = dist_coor_coor (point, points[j]);
        if (dist < min_dist) {
            min_dist = dist;
            closest_point = points[j];
        }
    }

    return closest_point;
}

coor_t* remove_first_point(coor_t* points, int *points_num, coor_t point) {
    int removed = 0;
    coor_t* new_points = (coor_t*) malloc(sizeof(coor_t) * *points_num);
    for (int i = 0; i < *points_num; i ++) {
        if (removed) {
            new_points[i - 1] = points[i];
        } else if (equals(points[i], point)) {
            removed = 1;
        } else {
            new_points[i] = points[i];
        }
    }
    *points_num = *points_num - 1;
    return new_points;
}


