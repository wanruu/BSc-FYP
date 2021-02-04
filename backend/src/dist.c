#include "dist.h"

// distance function: calculate distance between p1p2 and p3p4
// return {perpendicular, parallel, angle}
void compute_distance (coor_t locs[], double* dists) {
    // ensure p1p2 > p3p4
    double dist1 = (locs[0].alt - locs[1].alt) * (locs[0].alt - locs[1].alt) +
        (locs[0].lat - locs[1].lat) * laScale * (locs[0].lat - locs[1].lat) * laScale +
        (locs[0].lng - locs[1].lng) * lgScale * (locs[0].lng - locs[1].lng) * lgScale;
    double dist2 = (locs[2].alt - locs[3].alt) * (locs[2].alt - locs[3].alt) +
        (locs[2].lat - locs[3].lat) * laScale * (locs[2].lat - locs[3].lat) * laScale +
        (locs[2].lng - locs[3].lng) * lgScale * (locs[2].lng - locs[3].lng) * lgScale;
    
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
            points[points_index].x = (locs[index].lat - locs[3].lat) * laScale;
            points[points_index].y = (locs[index].lng - locs[3].lng) * lgScale;
            points[points_index].z = locs[index].alt - locs[3].alt;
            points_index ++;
        }
    } else {
        int indexes[3] = {1, 2, 3};
        for (int i = 0; i < 3; i++) {
            int index = indexes[i];
            points[points_index].x = (locs[index].lat - locs[0].lat) * laScale;
            points[points_index].y = (locs[index].lng - locs[0].lng) * lgScale;
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
double weighted_distance (coor_t locs[]) {
    double* dists = (double*) malloc(sizeof(double) * 3);
    compute_distance(locs, dists);
    // TODO: change the weight
    return 0.9 * dists[0] + dists[1] + dists[2];
}