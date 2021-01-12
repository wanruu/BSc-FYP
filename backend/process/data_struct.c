#include "data_struct.h"

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

double dist (point_t start, point_t end) {
    return pow(
        (start.x - end.x) * (start.x - end.x) +
        (start.y - end.y) * (start.y - end.y) +
        (start.z - end.z) * (start.z - end.z), 0.5);
}