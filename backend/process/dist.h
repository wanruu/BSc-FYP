#ifndef DIST_H
#define DIST_H

#include "data_struct.h"
#include "dist.h"
#include <math.h>
#include <stdlib.h>

void compute_distance (coor_t locs[], double* dists);
double weighted_distance (coor_t locs[]);

#endif