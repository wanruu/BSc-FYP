#include "data_struct.h"

double dist_loc_coor (loc_t loc, coor_t point) {
    double diff_x = (loc.lat - point.lat) * LA_SCALE;
    double diff_y = (loc.lng - point.lng) * LG_SCALE;
    double diff_z = loc.alt - point.alt;
    return pow(diff_x*diff_x + diff_y*diff_y + diff_z*diff_z, 0.5);
}

double dist_coor_coor (coor_t point1, coor_t point2) {
    double diff_x = (point1.lat - point2.lat) * LA_SCALE;
    double diff_y = (point1.lng - point2.lng) * LG_SCALE;
    double diff_z = point1.alt - point2.alt;
    return pow(diff_x*diff_x + diff_y*diff_y + diff_z*diff_z, 0.5);
}

point_t plus (point_t p1, point_t p2) {
    point_t p;
    p.x = p1.x + p2.x;
    p.y = p1.y + p2.y;
    p.z = p1.z + p2.z;
    return p;
}

point_t minus (point_t p1, point_t p2) {
    point_t p;
    p.x = p1.x - p2.x;
    p.y = p1.y - p2.y;
    p.z = p1.z - p2.z;
    return p;
}

point_t divide (point_t p_in, double num) {
    point_t p_out;
    p_out.x = p_in.x / num;
    p_out.y = p_in.y / num;
    p_out.z = p_in.z / num;
    return p_out;
}

point_t multi (point_t p_in, double num) {
    point_t p_out;
    p_out.x = p_in.x * num;
    p_out.y = p_in.y * num;
    p_out.z = p_in.z * num;
    return p_out;
}

double dot_product (point_t p1, point_t p2) {
    return p1.x * p2.x + p1.y * p2.y + p1.z * p2.z;
}

double dist_point_point (point_t start, point_t end) {
    return pow(
        (start.x - end.x) * (start.x - end.x) +
        (start.y - end.y) * (start.y - end.y) +
        (start.z - end.z) * (start.z - end.z), 0.5);
}

double log2 (double n) {
    return log(n) / log(2);
}

double min (double a, double b) {
    if (a < b) {
        return a;
    } else {
        return b;
    }
}

// distance function: calculate distance between p1p2 and p3p4
// return {perpendicular, parallel, angle}
void compute_distance (coor_t locs[], double* dists) {
    // ensure p1p2 > p3p4
    double dist1 = (locs[0].alt - locs[1].alt) * (locs[0].alt - locs[1].alt) +
        (locs[0].lat - locs[1].lat) * LA_SCALE * (locs[0].lat - locs[1].lat) * LA_SCALE +
        (locs[0].lng - locs[1].lng) * LG_SCALE * (locs[0].lng - locs[1].lng) * LG_SCALE;
    double dist2 = (locs[2].alt - locs[3].alt) * (locs[2].alt - locs[3].alt) +
        (locs[2].lat - locs[3].lat) * LA_SCALE * (locs[2].lat - locs[3].lat) * LA_SCALE +
        (locs[2].lng - locs[3].lng) * LG_SCALE * (locs[2].lng - locs[3].lng) * LG_SCALE;
    
    // change coor_t to point_t
    point_t points[4];
    points[0].x = 0;
    points[0].y = 0;
    points[0].z = 0; // regard points[0] as origin
    int points_index = 1;

    if(dist1 < dist2) {
        int indexes[3] = {2, 1, 0};
        for (int i = 0; i < 3; i++) {
            int index = indexes[i];
            points[points_index].x = (locs[index].lat - locs[3].lat) * LA_SCALE;
            points[points_index].y = (locs[index].lng - locs[3].lng) * LG_SCALE;
            points[points_index].z = locs[index].alt - locs[3].alt;
            points_index ++;
        }
    } else {
        int indexes[3] = {1, 2, 3};
        for (int i = 0; i < 3; i++) {
            int index = indexes[i];
            points[points_index].x = (locs[index].lat - locs[0].lat) * LA_SCALE;
            points[points_index].y = (locs[index].lng - locs[0].lng) * LG_SCALE;
            points[points_index].z = locs[index].alt - locs[0].alt;
            points_index ++;
        }
    }
    
    // calculate something for later computing
    double length1 = dist_point_point (points[0], points[1]); // length of p1p2
    double length2 = dist_point_point (points[2], points[3]); // length of p3p4

    point_t proj_p3 = multi(points[1], (dot_product(points[2], points[1]) / length1 / length1)); // projection point of p3 onto p1p2
    point_t proj_p4 = multi(points[1], (dot_product(points[3], points[1]) / length1 / length1)); // projection point of p4 onto p1p2
    double theta = acos( dot_product(points[1], minus(points[3], points[2])) / length1 / length2);
    
    // perpendicular distance
    double l_perp1 = dist_point_point (proj_p3, points[2]);
    double l_perp2 = dist_point_point (proj_p4, points[3]);
    double perp = (l_perp1 * l_perp1 + l_perp2 * l_perp2) / (l_perp1 + l_perp2);
    // parallel distance
    double l_para1 = min(dist_point_point (proj_p3, points[0]), dist_point_point (proj_p3, points[1]));
    double l_para2 = min(dist_point_point (proj_p4, points[0]), dist_point_point (proj_p4, points[1]));
    double parallel = min(l_para1, l_para2);
    // angle distance: no direction
    double angle = length2 * sin(theta);

    dists[0] = perp;
    dists[1] = parallel;
    dists[2] = angle;
}

// weighted distance
double weighted_distance (coor_t locs[], double prep, double para, double angle) {
    double* dists = (double*) malloc(sizeof(double) * 3);
    compute_distance(locs, dists);
    return prep * dists[0] + para * dists[1] + angle * dists[2];
}
