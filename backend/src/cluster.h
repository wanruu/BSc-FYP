#ifndef CLUSTER_H
#define CLUSTER_H

#include "data_struct.h"
#include "queue.h"
#include "dist.h"
#include <stdlib.h>

void get_neighbors(line_seg_t* line_segs, int line_segs_size, neighbor_t* neighbors);

void cluster(line_seg_t* line_segs, int line_segs_size, int* cluster_num);

#endif