#include "data_struct.h"

double dist_loc_coor (loc_t loc, coor_t point) {
    double diff_x = (loc.lat - point.lat) * laScale;
    double diff_y = (loc.lng - point.lng) * lgScale;
    double diff_z = loc.alt - point.alt;
    return pow(diff_x*diff_x + diff_y*diff_y + diff_z*diff_z, 0.5);
}

double dist_coor_coor (coor_t point1, coor_t point2) {
    double diff_x = (point1.lat - point2.lat) * laScale;
    double diff_y = (point1.lng - point2.lng) * lgScale;
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