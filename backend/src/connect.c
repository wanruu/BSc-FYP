#include "connect.h"

#define MinDist 26.0

/*
 *  Aim: main func. smooth and connect trajs by clustering.
 *  In: trajs, trajs_size.
 *  Out: trajs, trajs_size.
 *  Test:
 */

traj_t* smooth(traj_t* trajs, int* trajs_size) {
    
    // Step 1: Find neighbors of each point
    neighbor_trajs_t** neighbor_list = find_neighbors(trajs, *trajs_size);
    
    // Step 2: Cluster
    // cluster[i][j]. 0: unclustered, -1: noise, others: clusterId of trajs[i][j]
    int** cluster = (int**) malloc(sizeof(int*) * *trajs_size);
    for (int i = 0; i < *trajs_size; i++) {
        cluster[i] = (int*) malloc(sizeof(int) * trajs[i].points_num);
    }

    int cluster_id = 1;
    
    for (int i = 0; i < *trajs_size; i ++) { // for each traj
        for (int j = 0; j < trajs[i].points_num; j ++) { // for each point in traj
            
            if (cluster[i][j] != 0) { // if classfied
                continue;
            }
            
            // let neighbors = neighborList[i][j] // [(Int, Int)]
            neighbor_trajs_t neighbors = neighbor_list[i][j];

            if (neighbors.neighbors_num >= 2) { // it's core point
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

                    if (first_neighbors.neighbors_num >= 2) { // it's core point
                        
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
            if (id < 1) {
                continue;
            }
            aver_points[id-1].lat += trajs[i].points[j].lat;
            aver_points[id-1].lng += trajs[i].points[j].lng;
            aver_points[id-1].alt += trajs[i].points[j].alt;
            nums[id-1] += 1;
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
            if (id < 1) {
                continue;
            }
            trajs[i].points[j] = aver_points[id-1];
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

    
    // if traj1 can be replaced by traj2 (eg, traj2 contains traj1), remove traj1.
    trajs_after = (traj_t*) malloc(sizeof(traj_t) * (*trajs_size)); 
    trajs_size_after = 0; 

    for (int i = 0; i < *trajs_size; i ++) {
        int share_flag = 0; // if trajs[i] should be removed
        for (int j = 0; j < *trajs_size; j ++) {
            if (i == j) {
                continue;
            }
            if (trajs[i].points_num > trajs[j].points_num) {
                continue;
            }
            if (contains (trajs[j].points, trajs[j].points_num, trajs[i].points[0]) &&
                contains (trajs[j].points, trajs[j].points_num, trajs[i].points[trajs[i].points_num - 1])) {
                share_flag = 1;
                break;
            }
        }
        if (share_flag == 0) {
            trajs_after[trajs_size_after] = trajs[i];
            trajs_size_after++;
        }
    }
    trajs = trajs_after;
    *trajs_size = trajs_size_after;


    // recalculate nums: point number of each cluster
    for (int i = 0; i < cluster_id - 1; i++) {
        nums[i] = 0;
    }
    for (int i = 0; i < *trajs_size; i++) {
        for (int j = 0; j < trajs[i].points_num; j++) { // for each point
            int index = first_index_of(aver_points, cluster_id - 1, trajs[i].points[j]);
            if (index != -1) {
                nums[index] += 1;
            }

        }
    }
    
    // Step 5: Connect two traj with same endpoint.
    // This step can decrease num of representative trajs a lot, e.g, from 101 to 17
    coor_t* omit_points = (coor_t*) malloc(sizeof(coor_t) * 300); // crossroad
    int omit_points_size = 0;

    for (int i = 0; i < cluster_id - 1; i++) {
        if (nums[i] > 2) {
            omit_points[omit_points_size] = aver_points[i];
            omit_points_size++;
        }
    }


    int* indexes = connect_index(trajs, *trajs_size, omit_points, omit_points_size);

    while (indexes[0] != -1 && indexes[1] != -1) {

        traj_t traj1 = trajs[indexes[0]];
        traj_t traj2 = trajs[indexes[1]];

        traj_t new_traj;
        new_traj.points = (coor_t*) malloc(sizeof(coor_t) * (traj1.points_num + traj2.points_num));
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

        // move trajs[indexes[0]], trajs[indexes[1]] out of trajs
        traj_t* new_trajs = (traj_t*) malloc(sizeof(traj_t) * (*trajs_size - 1));
        int new_trajs_size = 0;

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
 *  Test: TODO.
 */

neighbor_trajs_t** find_neighbors(traj_t* trajs, int trajs_size) {

    // initialize return result
    neighbor_trajs_t** neighbors = (neighbor_trajs_t**) malloc(sizeof(neighbor_trajs_t*) * trajs_size);
    for (int i = 0; i < trajs_size; i++) {
        neighbors[i] = (neighbor_trajs_t*) malloc(sizeof(neighbor_trajs_t) * trajs[i].points_num);
        for (int j = 0; j < trajs[i].points_num; j ++) {
            neighbors[i][j].neighbors_num = 0;
        }
    }

    // find neighbors
    for (int i = 0; i < trajs_size; i++) { // for each traj
        
        coor_t start = trajs[i].points[0]; // starting point of traj
        coor_t end = trajs[i].points[trajs[i].points_num - 1]; // ending point of traj
        
        for (int j = i + 1; j < trajs_size; j++) { // for next traj

            for (int k = 0; k < trajs[j].points_num; k++) { // for each point in next traj
                
                coor_t point = trajs[j].points[k];

                if (dist_coor_coor (start, point) <= MinDist) {
                    int index = neighbors[i][0].neighbors_num;
                    neighbors[i][0].trajs_indexes[index] = j;
                    neighbors[i][0].points_indexes[index] = k;
                    neighbors[i][0].neighbors_num = index + 1;

                    index = neighbors[j][k].neighbors_num;
                    neighbors[j][k].trajs_indexes[index] = i;
                    neighbors[j][k].points_indexes[index] = 0;
                }
                if (dist_coor_coor (end, point) <= MinDist) {
                    int index = neighbors[i][trajs[i].points_num-1].neighbors_num;
                    neighbors[i][trajs[i].points_num-1].trajs_indexes[index] = j;
                    neighbors[i][trajs[i].points_num-1].points_indexes[index] = k;
                    neighbors[i][trajs[i].points_num-1].neighbors_num = index + 1;

                    index = neighbors[j][k].neighbors_num;
                    neighbors[j][k].trajs_indexes[index] = i;
                    neighbors[j][k].points_indexes[index] = trajs[i].points_num - 1;
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
 *  Test: TODO. But seems OK.
 */

int* connect_index(traj_t* trajs, int trajs_size, coor_t* omit_points, int omit_points_size) {
    int* indexes = (int*) malloc(sizeof(int) * 2);
    indexes[0] = -1;
    indexes[1] = -1;

    for (int i = 0; i < trajs_size; i++) { // for each traj
        for (int j = i + 1; j < trajs_size; j++) { // for next traj

            if (!contains (omit_points, omit_points_size, trajs[i].points[0])) {
                if (equals(trajs[i].points[0], trajs[j].points[0]) || equals(trajs[i].points[0], trajs[j].points[trajs[j].points_num - 1] )) {
                    indexes[0] = i;
                    indexes[1] = j;
                    return indexes;
                }
            }

            if (!contains (omit_points, omit_points_size, trajs[i].points[trajs[i].points_num - 1])) {
                if (equals(trajs[i].points[trajs[i].points_num-1], trajs[j].points[0]) || equals(trajs[i].points[trajs[i].points_num-1], trajs[j].points[trajs[j].points_num-1])) {
                    indexes[0] = i;
                    indexes[1] = j;
                    return indexes;
                }
            }
        }
    }

    return indexes;
}

int contains (coor_t* points, int points_size, coor_t point) {
    for (int i = 0; i < points_size; i++) {
        if (points[i].lat == point.lat && points[i].lng == point.lng && points[i].alt == point.alt) {
            return 1;
        }
    }
    return 0;
}

int first_index_of (coor_t* points, int points_size, coor_t point) {
    for (int i = 0; i < points_size; i++) {
        if (points[i].lat == point.lat && points[i].lng == point.lng && points[i].alt == point.alt) {
            return i;
        }
    }
    return -1;
}

int equals (coor_t point1, coor_t point2) {
    // return dist_coor_coor (point1, point2) < 5;
    return point1.lat == point2.lat && point1.lng == point2.lng && point1.alt == point2.alt;
}



