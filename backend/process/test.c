#include "data_struct.h"

typedef struct {
    int neighbors_indexes[1000];
    int neighbors_num;
} neighbor_t;

neighbor_t* neighbor(line_seg_t* line_segs, int line_segs_size) {
    /* for (int i = 0; i < line_segs_size; i++) {
        coor_t start = line_segs[i].start;
        coor_t end = line_segs[i].end;
        if (start.alt < 0 || end.alt < 0 ) {
            printf("start: (%f, %f, %f)\n", start.lat, start.lng, start.alt);
            printf("end: (%f, %f, %f)\n", end.lat, end.lng, end.alt);
        }
    }*/

    // initialize result
    neighbor_t *result = (neighbor_t*)malloc(sizeof(neighbor_t*) * (line_segs_size + 1));
    for (int i = 0; i < line_segs_size; i++) {
        result[i].neighbors_num = 0;
    }

    for (int i = 0; i < line_segs_size; i++) {
        printf("%d\n", result[i].neighbors_num);
        result[i].neighbors_indexes[result[i].neighbors_num] = 0;
        // result[i].neighbors_num = 1;
    }
    return result;


    for (int i = 0; i < line_segs_size; i++) {
        for (int j = i+1; j < line_segs_size; j++) {
            coor_t locs[4] = { line_segs[i].start, line_segs[i].end, line_segs[j].start, line_segs[j].end };
            double dist = weighted_distance(locs);
            if(dist <= e) {
                
                result[i].neighbors_indexes[result[i].neighbors_num] = j;
                result[i].neighbors_num = result[i].neighbors_num + 1;

                result[j].neighbors_indexes[result[j].neighbors_num] = i;
                result[j].neighbors_num = result[j].neighbors_num + 1;
            }
        }
    }
    return result;
}

int main() {
    line_seg_t* line_segs = (line_seg_t*)malloc(sizeof(line_seg_t) * 5);

    neighbor(line_segs, 5);
}



