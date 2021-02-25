#include "represent.h"

double r = 1.2;
int MinLns = 3;

int cmp_func_point (const void* p1, const void* p2) {
    double divide = ((point_t*)p1)->x - ((point_t*)p2)->x;
    if (divide < 0) {
        return -1;
    }
    if (divide > 0) {
        return 1;
    }
    return 0;
}

int cmp_func_line (const void* line1, const void* line2) {
    double divide = ((point_t**)line1)[0]->x - ((point_t**)line2)[0]->x;
    if (divide < 0) {
        return -1;
    }
    if (divide > 0) {
        return 1;
    }
    return 0;
}

/*
 *  Aim: generate representative trajectory by line_segs.
 *  In: line_segs, line_segs_size.
 *  Out: represent, represent_size.
 *  Test: TODO.
 */

void generate_represent(line_seg_t* line_segs, int line_segs_size, coor_t* represent, int* represent_size) {

    *represent_size = 0;

    if (line_segs_size <= 0) {
        // printf("In function generate_represent, input line_segs has size 0. Hence no represent generated.\n");
        return;
    }

    // convert line_segs to points: [p1, p2, ..., p2n-1, p2n] where p1, p2 are start and end point of line_segs[0]
    point_t* points = (point_t*) malloc(sizeof(point_t) * 2 * line_segs_size);
    int points_size = 2 * line_segs_size;
    line_segs_to_points(line_segs, line_segs_size, points);

    // convert points to vectors: [v1, v2, ..., vn]
    point_t* vectors = (point_t*) malloc(sizeof(point_t) * points_size);
    int vectors_size = 0;
    points_to_vectors(points, points_size, vectors, &vectors_size);
    
    // compute average direction vector
    point_t aver_vector = compute_aver_vector(vectors, vectors_size);
    //free(vectors);


    // rotate axes so that X axis is parallel to aver_vector 
    double alpha = atan(aver_vector.y / aver_vector.x); // rotate by z
    double beta = atan(aver_vector.z / pow(aver_vector.x * aver_vector.x + aver_vector.y * aver_vector.y, 0.5)); // rotate by y
    
    point_t* rotated_points = (point_t*) malloc(sizeof(point_t) * points_size);
    for (int i = 0; i < points_size; i++) {
        rotated_points[i] = rotate(points[i], alpha, beta);
    }
    //free(points);

    
    // lines for sweeping
    point_t** rotated_lines = (point_t**) malloc(sizeof(point_t*) * points_size / 2);
    int rotated_lines_size = 0;

    for (int i = 0; i < points_size - 1; i = i + 2) {
        rotated_lines[rotated_lines_size] = (point_t*) malloc(sizeof(point_t) * 2);

        if(rotated_points[i].x > rotated_points[i+1].x) {
            rotated_lines[rotated_lines_size][0] = rotated_points[i+1];
            rotated_lines[rotated_lines_size][1] = rotated_points[i];
        } else {
            rotated_lines[rotated_lines_size][0] = rotated_points[i];
            rotated_lines[rotated_lines_size][1] = rotated_points[i+1];
        }
        rotated_lines_size ++;
    }

    // sort rotated_points by x value
    qsort (rotated_points, points_size, sizeof(point_t), cmp_func_point);

    qsort (rotated_lines, rotated_lines_size, sizeof(point_t*), cmp_func_line);

    // start sweeping
    double last_x_value = - r;

    // printf("========\n");
    for (int i = 0; i < points_size; i++) { //for point in rotated_points

        // printf("%f\n", rotated_points[i].x);

        point_t* values = (point_t*) malloc(sizeof(point_t) * points_size);
        int values_size = 0;
        lines_x_value(rotated_points[i].x, rotated_lines, rotated_lines_size, values, &values_size);


        if (values_size < MinLns) {
            continue;
        }

            
        double diff = rotated_points[i].x - last_x_value;
        last_x_value = rotated_points[i].x;
            
        if (diff >= r) {

            /*for (int j = 0; j < values_size; j++) {
                printf("%f\n", values[j].x);
            }
            printf("\n");*/

            // calculate average point_t of values
            double aver_y, aver_z = 0;
            for (int j = 0; j < values_size; j ++) {
                aver_y += values[j].y;
                aver_z += values[j].z;
            }
            aver_y /= (double)(values_size);
            aver_z /= (double)(values_size);
            point_t rotated_aver_point;

            rotated_aver_point.x = rotated_points[i].x;
            rotated_aver_point.y = aver_y;
            rotated_aver_point.z = aver_z;

            // undo rotation
            point_t aver_point = unrotate(rotated_aver_point, alpha, beta);

            represent[*represent_size].lat = aver_point.x / LA_SCALE + line_segs[0].start.lat;
            represent[*represent_size].lng = aver_point.y / LG_SCALE + line_segs[0].start.lng;
            represent[*represent_size].alt = aver_point.z + line_segs[0].start.alt;

            *represent_size = *represent_size + 1;
        }
        
    }
}


/*
 *  Aim: compute average direction vector
 *  In: vectors, vectors_size.
 *  Out: return aver_vector.
 *  Test: TODO. But seems OK.
 */
point_t compute_aver_vector(point_t* vectors, int vectors_size) {
    
    point_t aver_vector;
    aver_vector.x = 0;
    aver_vector.y = 0;
    aver_vector.z = 0;

    // find axis in which vector change most 
    double x = 0;
    double y = 0;

    for (int i = 0; i < vectors_size; i++) {
        x += fabs(vectors[i].x);
        y += fabs(vectors[i].y);
    }

    if(x > y) {
        for (int index = 0; index < vectors_size; index ++) {
            if(vectors[index].x * vectors[0].x < 0) {
                aver_vector = minus(aver_vector, vectors[index]);
            } else {
                aver_vector = plus(aver_vector, vectors[index]);
            }
        }
    } else {
        for (int index = 0; index < vectors_size; index ++) {
            if(vectors[index].y * vectors[0].y < 0) {
                aver_vector = minus(aver_vector, vectors[index]);
            } else {
                aver_vector = plus(aver_vector, vectors[index]);
            }
        }
    }
    aver_vector = divide(aver_vector, (double)(vectors_size));
    return aver_vector;
}


/*
 *  Aim: find the x value for each line crossed by sweep_plane.
 *  In: sweep_plane, lines, lines_size.
 *  Out: values, values_size.
 *  Test: TODO. But seems OK.
 */

void lines_x_value(double sweep_plane, point_t** lines, int lines_size, point_t* values, int* values_size) {

    *values_size = 0;

    for (int i = 0; i < lines_size; i++) { // for each line

        if (lines[i][0].x == sweep_plane) {
            values[*values_size].x = lines[i][0].x;
            values[*values_size].y = lines[i][0].y;
            values[*values_size].z = lines[i][0].z;
            *values_size = *values_size + 1;
            break;
        } else if (lines[i][1].x == sweep_plane) {
            values[*values_size].x = lines[i][1].x;
            values[*values_size].y = lines[i][1].y;
            values[*values_size].z = lines[i][1].z;
            *values_size = *values_size + 1;
            break;
        }
    }

    for (int i = 0; i < lines_size; i++) { // for each line

        if(lines[i][0].x < sweep_plane && lines[i][1].x > sweep_plane) {

            values[*values_size].x = sweep_plane;
            values[*values_size].y = (sweep_plane - lines[i][0].x) / (lines[i][1].x - lines[i][0].x) * (lines[i][1].y - lines[i][0].y) + lines[i][0].y;
            values[*values_size].z = (sweep_plane - lines[i][0].x) / (lines[i][1].x - lines[i][0].x) * (lines[i][1].z - lines[i][0].z) + lines[i][0].z;
            *values_size = *values_size + 1;
        }
    }
}


/*
 *  Aim: convert line_segs to points.
 *  In: line_segs, line_segs_size. line_segs_size must be larger than 0.
 *  Out: points. points_size = 2 * line_segs_size.
 *  Test: TODO. But seems OK.
 */
void line_segs_to_points(line_seg_t* line_segs, int line_segs_size, point_t* points) {
    
    // regard line_segs[0].start_point as origin point
    double lat = line_segs[0].start.lat;
    double lng = line_segs[0].start.lng;
    double alt = line_segs[0].start.alt;

    for (int i = 0; i < line_segs_size; i++) {

        points[2 * i].x = (line_segs[i].start.lat - lat) * LA_SCALE;
        points[2 * i].y = (line_segs[i].start.lng - lng) * LG_SCALE;
        points[2 * i].z = line_segs[i].start.alt - alt;

        points[2 * i + 1].x = (line_segs[i].end.lat - lat) * LA_SCALE;
        points[2 * i + 1].y = (line_segs[i].end.lng - lng) * LG_SCALE;
        points[2 * i + 1].z = line_segs[i].end.alt - alt;
    }

}

/*
 *  Aim: convert points to vectors.
 *  In: points, points_size.
 *  Out: vectors. vectors_size = points_size / 2.
 *  Test: TODO. But seems OK.
 */
void points_to_vectors(point_t* points, int points_size, point_t* vectors, int* vectors_size) {
    *vectors_size = 0;

    for (int i = 0; i < points_size - 1; i = i + 2) {
        vectors[*vectors_size] = minus(points[i + 1], points[i]);
        *vectors_size = *vectors_size + 1;
    }
}

// rotate & unrotate
point_t rotate(point_t point, double alpha, double beta) {
    point_t p1 = rotate_by_z(point, alpha);
    point_t p2 = rotate_by_y(p1, beta);
    return p2;
}
point_t unrotate(point_t point, double alpha, double beta) {
    point_t p1 = rotate_by_y(point, -beta);
    point_t p2 = rotate_by_z(p1, -alpha);
    return p2;
}
point_t rotate_by_z(point_t point, double angle) { // clockwise
    point_t new_point;
    new_point.x = point.x * cos(angle) + point.y * sin(angle);
    new_point.y = point.y * cos(angle) - point.x * sin(angle);
    new_point.z = point.z;
    return new_point;
}
point_t rotate_by_y(point_t point, double angle) { // anti-clockwise
    point_t new_point;
    new_point.x = point.x * cos(angle) + point.z * sin(angle);
    new_point.y = point.y;
    new_point.z = point.z * cos(angle) - point.x * sin(angle);
    return new_point;
}

