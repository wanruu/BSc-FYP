#ifndef PART_H
#define PART_H

#include "data_struct.h"

double MDLPar(coor_t* traj, int start_index, int end_index);
double MDLNotPar(coor_t* traj, int start_index, int end_index);
void partition_traj(coor_t* traj, int points_num, coor_t* cp, int* cp_num);

#endif