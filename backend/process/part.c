#include "part.h"

#define laScale 111000.0
#define lgScale 85390.0

double log2(double n) {
    return log(n) / log(2);
}

double MDLPar(coor_t* traj, int start_index, int end_index) {
    // only two cp in this trajectory
    // distance between two charateristic points
    double angle_sum = 0;
    double perp_sum = 0;

    double diffX = (traj[start_index].lat - traj[end_index].lat) * laScale;
    double diffY = (traj[start_index].lng - traj[end_index].lng) * lgScale;
    double diffZ = traj[start_index].alt - traj[end_index].alt;

    double* dists = (double*)malloc(sizeof(double) * 4);
    for (int index = start_index; index < end_index; index++) {
        coor_t locs[4] = {traj[start_index], traj[end_index], traj[index], traj[index+1]};
        compute_distance(locs, dists);
        perp_sum += dists[0];
        angle_sum += dists[2];
    }

    double LH = log2(pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5));
    double LH_D = log2(angle_sum) + log2(perp_sum);
    return LH + 0.08 * LH_D;
}

double MDLNotPar(coor_t* traj, int start_index, int end_index) {
    double LH = 0;
    // LH_D = 0 under this situation
    for (int index = start_index; index < end_index; index++) {
        double diffX = (traj[index].lat - traj[index+1].lat) * laScale;
        double diffY = (traj[index].lng - traj[index+1].lng) * lgScale;
        double diffZ = traj[index].alt - traj[index+1].alt;
        LH += pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5);
    }
    return log2(LH);
}

/*
 *  Aim: patition a traj into cp.
 *  In: traj, points_num.
 *  Out: cp, cp_num.
 *  Test: done & OK. By verifying patition part in main.c.
 */
void partition_traj(coor_t* traj, int points_num, coor_t* cp, int* cp_num) {
    // add starting point to cp
    cp[0] = traj[0];
    *cp_num = *cp_num + 1;
    
    int start_index = 0;
    int length = 1;

    while (start_index + length <= points_num - 1) {
        int cur_index = start_index + length;
        // cost if regard current point as charateristic point
        double costPar = MDLPar(traj, start_index, cur_index);

        // cost if not regard current point as charateristic point
        double costNotPar = MDLNotPar(traj, start_index, cur_index);

        if (costPar > costNotPar) {
            // add previous point to cp
            cp[*cp_num] = traj[cur_index - 1];
            *cp_num = *cp_num + 1;
            start_index = cur_index - 1;
            length = 1;
        } else {
            length += 1;
        }
    }
    // add ending point to cp
    cp[*cp_num] = traj[points_num - 1];
    *cp_num = *cp_num + 1;
}