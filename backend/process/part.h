#ifndef PART_H
#define PART_H

#include <math.h>
#include <stdlib.h>
#include "data_struct.h"
#include "dist.h"

double log2(double n);
double MDLPar(coor_t* traj, int start_index, int end_index);
double MDLNotPar(coor_t* traj, int start_index, int end_index);
void partition_traj(coor_t* traj, int points_num, coor_t* cp, int* cp_num);

#endif