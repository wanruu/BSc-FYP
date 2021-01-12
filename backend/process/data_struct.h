#ifndef DATA_STRUCT
#define DATA_STRUCT

#include <math.h>

typedef struct {
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
    int neighbors_indexes[1000];
    int neighbors_num;
} neighbor_t;

typedef struct {
    line_seg_t* line_segs;
    int line_segs_size;
} line_segs_cluster_t;

point_t plus (point_t p1, point_t p2);
point_t minus (point_t p1, point_t p2);
point_t divide (point_t p_in, double num);
point_t multi (point_t p_in, double num);
double dot_product (point_t p1, point_t p2);
double dist (point_t start, point_t end);

#endif