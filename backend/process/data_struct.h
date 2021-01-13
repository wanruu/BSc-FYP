#include <math.h>

#define laScale 111000.0
#define lgScale 85390.0
#define INF 99999.0

#ifndef DATA_STRUCT
#define DATA_STRUCT

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

double dist_loc_coor (loc_t loc, coor_t point);

double dist_coor_coor (coor_t point1, coor_t point2);

typedef struct {
    coor_t* points;
    int points_num;
} traj_t;

typedef struct {
    double x;
    double y;
    double z;
} point_t;

point_t plus (point_t p1, point_t p2);
point_t minus (point_t p1, point_t p2);
point_t divide (point_t p_in, double num);
point_t multi (point_t p_in, double num);
double dot_product (point_t p1, point_t p2);
double dist (point_t start, point_t end);


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



#endif