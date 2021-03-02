#ifndef LA_SCALE
#define LA_SCALE 111000
#endif

#ifndef LG_SCALE
#define LG_SCALE 85390
#endif

#ifndef INF
#define INF 99999
#endif

#ifndef DATA_STRUCT_H
#define DATA_STRUCT_H

#include <math.h>
#include <stdlib.h>

typedef struct {
    char id[25];
    char name[100];
    double lat;
    double lng;
    double alt;
    int type;
} loc_t;

typedef struct {
    double lat;
    double lng;
    double alt;
} coor_t;

typedef struct {
    coor_t* points;
    int points_num;
} traj_t;

typedef struct {
    double x;
    double y;
    double z;
} point_t;

typedef struct {
    coor_t start;
    coor_t end;
    int cluster_id;
} line_seg_t;

typedef struct {
    loc_t start_loc;
    loc_t end_loc;
    coor_t* points;
    int points_num;
    double dist;
} route_t;

typedef struct {
    int neighbors_indexes[1000];
    int neighbors_num;
} neighbor_t;

typedef struct {
    line_seg_t* line_segs;
    int line_segs_size;
} line_segs_cluster_t;

typedef struct {
    int trajs_indexes[100]; // now no more than 11
    int points_indexes[100];
    int neighbors_num;
} neighbor_trajs_t; // a neighbor (x, y) = (trajs_indexes[i], points_indexes[i]) -> trajs[x][y]

int equals (coor_t point1, coor_t point2);
int contains (coor_t* points, int points_size, coor_t point);
int first_index_of (coor_t* points, int points_size, coor_t point);

double dist_loc_coor (loc_t loc, coor_t point);
double dist_coor_coor (coor_t point1, coor_t point2);
void compute_distance (coor_t locs[], double* dists);
double weighted_distance (coor_t locs[], double prep, double para, double angle);

point_t plus (point_t p1, point_t p2);
point_t minus (point_t p1, point_t p2);
point_t divide (point_t p_in, double num);
point_t multi (point_t p_in, double num);
double dot_product (point_t p1, point_t p2);
double dist_point_point (point_t start, point_t end);

double log2 (double n);
double min (double a, double b);

#endif