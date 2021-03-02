#include "cluster.h"

#define e 16 // 16
#define MinLns 10

/*
 *  Aim: calculate e-neighborhood for every line segment.
 *  In: line_segs, line_segs_size.
 *  Out: neighbors.
 */

void get_neighbors(line_seg_t* line_segs, int line_segs_size, neighbor_t* neighbors) {
    for (int i = 0; i < line_segs_size; i++) {
        // printf("%f\n", dist_coor_coor (line_segs[i].start, line_segs[i].end));
        neighbors[i].neighbors_num = 0;
    }


    for (int i = 0; i < line_segs_size; i++) {
        for (int j = i + 1; j < line_segs_size; j++) {
            coor_t locs[4] = { line_segs[i].start, line_segs[i].end, line_segs[j].start, line_segs[j].end };
            double dist = weighted_distance(locs, 1, 1, 1);

            if(dist <= e) {
                int num = neighbors[i].neighbors_num;
                neighbors[i].neighbors_indexes[num] = j;
                neighbors[i].neighbors_num = num + 1;

                num = neighbors[j].neighbors_num;
                neighbors[j].neighbors_indexes[num] = i;
                neighbors[j].neighbors_num = num + 1;
            }
        }
    }
}

/*
 *  Aim: assign cluster_id to each line_segs.
 *  In: line_segs, line_segs_size.
 *  Out: line_segs, cluster_num;
 */

void cluster(line_seg_t* line_segs, int line_segs_size, int* cluster_num) {

    int cluster_id = 1; // 0: unclassfied, -1: noise, others: cluster_id
    
    // compute neighbor array
    neighbor_t* neighbor_list = (neighbor_t*) malloc(sizeof(neighbor_t) * (line_segs_size + 1));
    get_neighbors(line_segs, line_segs_size, neighbor_list);

    // initialize cluster_id for each line seg
    for (int i = 0; i < line_segs_size; i ++) {
        line_segs[i].cluster_id = 0;
    }

    for (int index = 0; index < line_segs_size; index ++) { // for each line seg
        
        if(line_segs[index].cluster_id != 0) { // if classfied
            continue;
        }
        
        neighbor_t neighbors = neighbor_list[index]; // neighbors of line_segs[index]
        
        if (neighbors.neighbors_num + 1 >= MinLns) { // if line_segs[index] is core line segment
            
            // assgin cluster_id to self and each neighbor
            line_segs[index].cluster_id = cluster_id;
            for (int i = 0; i < neighbors.neighbors_num; i++) {
                line_segs[neighbors.neighbors_indexes[i]].cluster_id = cluster_id;
            }

            // expand cluster
            queue_t* queue = create_queue();
            for (int i = 0; i < neighbors.neighbors_num; i++) {
                enqueue(queue, neighbors.neighbors_indexes[i]);
            }
            while(!is_empty_queue(queue)) {
                
                int first = dequeue(queue); // first line seg index in queue
                neighbor_t first_neighbors = neighbor_list[first]; // get neighbor of first, first not included

                if(first_neighbors.neighbors_num >= MinLns) { // if first is a core line seg

                    for (int i = 0; i < first_neighbors.neighbors_num; i++) { // for each neighbor of first
                        int neighbor_index = first_neighbors.neighbors_indexes[i];

                        if (line_segs[neighbor_index].cluster_id == 0 || line_segs[neighbor_index].cluster_id == -1) {
                            line_segs[neighbor_index].cluster_id = cluster_id;
                        }
                        if (line_segs[neighbor_index].cluster_id == 0) {
                            enqueue(queue, first_neighbors.neighbors_indexes[i]);
                        }
                        
                    }
                }
            }
            free(queue);
            cluster_id += 1;

        } else { // mark as noise
            line_segs[index].cluster_id = -1;
        }
        
    }

    // check trajectory cardinality
    int* cardinality = (int*) malloc(sizeof(int) * (cluster_id + 1));
    for (int i = 0; i < cluster_id; i++) {
        cardinality[i] = 0;
    }

    for (int i = 0; i < line_segs_size; i++) {
        if (line_segs[i].cluster_id != -1) {
            cardinality[line_segs[i].cluster_id] += 1;
        }
    }
    for (int i = 0; i < line_segs_size; i++) {
        if (line_segs[i].cluster_id != -1 && cardinality[line_segs[i].cluster_id] < MinLns) {
            line_segs[i].cluster_id = -1;
        }
    }
    *cluster_num = cluster_id - 1;
}

