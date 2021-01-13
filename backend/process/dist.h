#include "data_struct.h"
#include <math.h>
#include <stdlib.h>

#define min(a,b)(a<b?a:b)

#ifndef DIST_H
#define DIST_H

void compute_distance (coor_t locs[], double* dists);
double weighted_distance (coor_t locs[]);

#endif