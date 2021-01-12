#ifndef REPRESENT_H
#define REPRESENT_H

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "data_struct.h"
#include "represent.h"

int cmp_func_point (const void* p1, const void* p2);
int cmp_func_line (const void* line1, const void* line2);

void generate_represent(line_seg_t* line_segs, int line_segs_size, coor_t* represent, int* represent_size);

point_t compute_aver_vector(point_t* vectors, int vectors_size);
void lines_x_value(double sweep_plane, point_t** lines, int lines_size, point_t* values, int* values_size);

void line_segs_to_points(line_seg_t* line_segs, int line_segs_size, point_t* points);
void points_to_vectors(point_t* points, int points_size, point_t* vectors, int* vectors_size);

point_t rotate(point_t point, double alpha, double beta);
point_t unrotate(point_t point, double alpha, double beta);
point_t rotate_by_z(point_t point, double angle);
point_t rotate_by_y(point_t point, double angle);



#endif