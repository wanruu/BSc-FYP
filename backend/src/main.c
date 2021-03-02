#include <mongoc/mongoc.h>
#include <bson/bson.h>
#include "part.h"
#include "cluster.h"
#include "represent.h"
#include "connect.h"
#include "route.h"

int LOC_NUM = 200; // now about 46
int TRAJ_NUM = 300; // now 132
int LINE_SEG_NUM = 10000; // now 5071

char* int_to_str (int x) {
    int length = snprintf(NULL, 0, "%d", x);
    char* str = (char*) malloc(sizeof(char) * (length + 1));
    str[length] = '\0';
    for (int i = length - 1; i >= 0; i --) {
        str[i] = '0' + (x % 10);
        x /= 10;
    }
    return str;
}

void get_locs (mongoc_collection_t *collection, loc_t *locs, int *locs_size) {
    const bson_t *doc;
    bson_t *query = bson_new();
    mongoc_cursor_t *cursor = mongoc_collection_find_with_opts (collection, query, NULL, NULL);
    
    while (mongoc_cursor_next(cursor, &doc)) {
        // For a location
        bson_iter_t iter;
        const char *key;
        const bson_value_t *value;

        if (bson_iter_init(&iter, doc)) {
            while (bson_iter_next(&iter)) {
                key = bson_iter_key(&iter);
                value = bson_iter_value(&iter);
                if (strcmp(key, "name_en") == 0) {
                    strcpy(locs[*locs_size].name, value->value.v_utf8.str);
                } else if (strcmp(key, "latitude") == 0) {
                    locs[*locs_size].lat = value->value.v_double;
                } else if (strcmp(key, "longitude") == 0) {
                    locs[*locs_size].lng = value->value.v_double;
                } else if (strcmp(key, "altitude") == 0) {
                    locs[*locs_size].alt = value->value.v_double;
                } else if (strcmp(key, "type") == 0) {
                    locs[*locs_size].type = value->value.v_int64;
                } else if (strcmp(key, "_id") == 0) {
                    bson_oid_t oid = value->value.v_oid;
                    bson_oid_to_string(&oid, locs[*locs_size].id);
                }
            }
        }
        *locs_size = *locs_size + 1;
    }
    // printf("%d\n", *locs_size);
}

void get_trajs (mongoc_collection_t *collection, traj_t *trajs, int *trajs_size) {
    const bson_t *doc;
    mongoc_cursor_t *cursor = mongoc_collection_find_with_opts (collection, bson_new(), NULL, NULL);
    while (mongoc_cursor_next(cursor, &doc)) {
        bson_iter_t iter1;
        bson_iter_t iter2;
        bson_iter_t iter3;
        const bson_value_t *value;
        const char *key;

        // start to iterate
        if (bson_iter_init(&iter1, doc)) {

            // if has next trajectory
            while (bson_iter_next(&iter1)) {
                
                // if the key is "points"
                if (strcmp (bson_iter_key(&iter1), "points") == 0) {
                    bson_iter_recurse(&iter1, &iter2);

                    // if has next point
                    int points_num = 0;
                    while (bson_iter_next(&iter2)) {
                        bson_iter_recurse(&iter2, &iter3);
                        
                        // for {latitude, longitude, altitude} of a point
                        while (bson_iter_next(&iter3)) {
                            key = bson_iter_key(&iter3);
                            value = bson_iter_value(&iter3);
                            if (strcmp(key, "latitude") == 0) {
                                trajs[*trajs_size].points[points_num].lat = value->value.v_double;
                            } else if (strcmp(key, "longitude") == 0) {
                                trajs[*trajs_size].points[points_num].lng = value->value.v_double;
                            } else if (strcmp(key, "altitude") == 0) {
                                trajs[*trajs_size].points[points_num].alt = value->value.v_double;
                            }
                        }
                        points_num ++;
                        
                    }
                    trajs[*trajs_size].points_num = points_num;
                    *trajs_size = *trajs_size + 1;
                }
            }
        }
    }
    // printf("%d\n", *trajs_size);
}

void print_raw_trajs (traj_t *trajs, int trajs_size) {
    FILE *fp = fopen("./draw/raw_trajs.txt", "w");
    for (int i = 0; i < trajs_size; i++) {
        for (int j = 0; j < trajs[i].points_num; j ++) {
            fprintf(fp, "%f %f\n", trajs[i].points[j].lat, trajs[i].points[j].lng);
        }
        fprintf(fp, "\n");
    }
}

void print_line_segs (line_seg_t *line_segs, int line_segs_size) {
    FILE *fp = fopen("./draw/line_segs.txt", "w");
    for (int i = 0; i < line_segs_size; i++) {
        fprintf(fp, "%d\n", line_segs[i].cluster_id);
        fprintf(fp, "%f %f\n", line_segs[i].start.lat, line_segs[i].start.lng);
        fprintf(fp, "%f %f\n", line_segs[i].end.lat, line_segs[i].end.lng);
        fprintf(fp, "\n");
    }
}

void print_rep_trajs (traj_t *rep_trajs, int rep_trajs_size) {
    FILE *fp = fopen("./draw/rep.txt", "w");
    for (int i = 0; i < rep_trajs_size; i++) {
        for (int j = 0; j < rep_trajs[i].points_num; j ++) {
            fprintf(fp, "%f %f\n", rep_trajs[i].points[j].lat, rep_trajs[i].points[j].lng);
        }
        fprintf(fp, "\n");
    }
}

void print_routes (route_t *routes, int routes_size) {
    FILE *fp = fopen("./draw/route.txt", "w");
    for (int i = 0; i < routes_size; i++) {
        for (int j = 0; j < routes[i].points_num; j++) {
            fprintf(fp, "%f %f\n", routes[i].points[j].lat, routes[i].points[j].lng);
        }
        fprintf(fp, "\n");
    }
}

int main (int argc, char *argv[]) {

    // Step 1: Connect to mongoDB.
    mongoc_client_t *client;
    mongoc_database_t *database;
    mongoc_collection_t *collection;
    bson_error_t error;
    mongoc_init(); // Initialize libmongoc
    client = mongoc_client_new("mongodb://localhost:27017"); // Create a new client instance
    if (!client) {
        return EXIT_FAILURE;
    }
    database = mongoc_client_get_database(client, "CUMap");


    // Step 2: Get locations & trajectories data from db.
    collection = mongoc_client_get_collection(client, "CUMap", "locations");
    loc_t *locs = (loc_t*) malloc(sizeof(loc_t) * LOC_NUM);
    int locs_size = 0;
    get_locs(collection, locs, &locs_size);

    mongoc_collection_destroy(collection);
    collection = mongoc_client_get_collection(client, "CUMap", "trajectories");
    traj_t *trajs = (traj_t*) malloc(sizeof(traj_t) * TRAJ_NUM);
    for (int i = 0; i < TRAJ_NUM; i++) {
        trajs[i].points = (coor_t*) malloc(sizeof(coor_t) * TRAJ_NUM);
    }
    int trajs_size = 0;
    get_trajs(collection, trajs, &trajs_size);

    // test
    // print_raw_trajs(trajs, trajs_size);


    // Step 3: Partition trajs into line_segs.
    line_seg_t* line_segs = (line_seg_t*) malloc(sizeof(line_seg_t) * LINE_SEG_NUM);
    int line_segs_size = 0;
    for (int traj_index = 0; traj_index < trajs_size; traj_index++) {
        if (trajs[traj_index].points_num < 2) {
            continue;
        }
        coor_t* cp = (coor_t*) malloc(sizeof(coor_t) * (trajs[traj_index].points_num + 1));
        int cp_num = 0;
        partition_traj(trajs[traj_index].points, trajs[traj_index].points_num, cp, &cp_num);
        for (int cp_index = 0; cp_index < cp_num - 1; cp_index ++) {
            line_segs[line_segs_size].start = cp[cp_index];
            line_segs[line_segs_size].end = cp[cp_index+1];
            line_segs[line_segs_size].cluster_id = 0;
            line_segs_size++;
        }
    }

    
    // Step 4: Cluster line_segs by assigning cluster_id to them.
    int cluster_num = 0;
    cluster(line_segs, line_segs_size, &cluster_num);

    // test
    print_line_segs (line_segs, line_segs_size);


    // Step 5: Generate rep_trajs from line_segs.
    int rep_trajs_size = 0;
    traj_t* rep_trajs = (traj_t*) malloc(sizeof(traj_t) * TRAJ_NUM);

    // assign line_segs to each line_segs_clusters
    line_segs_cluster_t* clusters = (line_segs_cluster_t*) malloc(sizeof(line_segs_cluster_t) * cluster_num);
    for (int i = 0; i < cluster_num; i++) {
        clusters[i].line_segs = (line_seg_t*) malloc(sizeof(line_seg_t) * line_segs_size);
        clusters[i].line_segs_size = 0;
    }

    for (int i = 0; i < line_segs_size; i++) {
        if (line_segs[i].cluster_id != -1 && line_segs[i].cluster_id != 0) {
            int index = clusters[line_segs[i].cluster_id - 1].line_segs_size;
            clusters[line_segs[i].cluster_id - 1].line_segs[index] = line_segs[i];
            clusters[line_segs[i].cluster_id - 1].line_segs_size = index + 1;
        }
    }

    // for each line_segs_clusters, generate rep_traj for it
    for (int i = 0; i < cluster_num; i++) {
        coor_t* represent = (coor_t*) malloc(sizeof(coor_t) * clusters[i].line_segs_size * 2);
        int represent_size = 0;
        generate_represent(clusters[i].line_segs, clusters[i].line_segs_size, represent, &represent_size);
        
        if (represent_size >= 2) {
            rep_trajs[rep_trajs_size].points = represent;
            rep_trajs[rep_trajs_size].points_num = represent_size;
            rep_trajs_size += 1;
        }
    }
    // test
    // print_rep_trajs (rep_trajs, rep_trajs_size);

    // Step 6: Connect & smooth rep_trajs.
    rep_trajs = connect_trajs(rep_trajs, &rep_trajs_size, 18, 3);
    
    // test
    print_rep_trajs (rep_trajs, rep_trajs_size);



    // Step 7: Generate routes from rep_trajs.
    int routes_size = 0;
    route_t* routes = generate_routes (rep_trajs, rep_trajs_size, locs, locs_size, &routes_size);
    
    // test
    print_routes (routes, routes_size);


    // Step 8: Drop routes table. -> delete route whose type is 0
    mongoc_collection_destroy(collection);
    collection = mongoc_client_get_collection(client, "CUMap", "routes");
    bson_t *doc = bson_new();
    bson_append_int64(doc, "type", 4, 0);
    if (!mongoc_collection_remove(collection, MONGOC_REMOVE_NONE, doc, NULL, &error)) {
        fprintf(stderr, "Delete failed: %s\n", error.message);
    }


    // Step 9: Upload routes to mongo.
    for (int i = 0; i < routes_size; i ++) {
        bson_t* route = bson_new();
        // startLoc & endLoc
        bson_oid_t start_id, end_id;
        bson_oid_init_from_string (&start_id, routes[i].start_loc.id);
        bson_oid_init_from_string (&end_id, routes[i].end_loc.id);
        bson_append_oid (route, "startLoc", 8, &start_id);
        bson_append_oid (route, "endLoc", 6, &end_id);
        
        // points
        bson_t* points = bson_new();
        bson_append_array_begin (route, "points", 6, points);
        for (int j = 0; j < routes[i].points_num; j++) {
            bson_t* point = bson_new();
            char* index = int_to_str(j);
            bson_append_document_begin (points, index, strlen(index), point);
            
            bson_append_double (point, "latitude", 8, routes[i].points[j].lat);
            bson_append_double (point, "longitude", 9, routes[i].points[j].lng);
            bson_append_double (point, "altitude", 8, routes[i].points[j].alt);
            bson_append_document_end (points, point);
        }
        bson_append_array_end (route, points);

        // dist
        bson_append_double (route, "dist", 4, routes[i].dist);

        // type
        bson_append_int64 (route, "type", 4, 0);
        
        if (!mongoc_collection_insert (collection, MONGOC_INSERT_NONE, route, NULL, &error)) {
            fprintf (stderr, "%s\n", error.message);
        }
    }
    
    
    // Step 10: Release
    mongoc_database_destroy(database);
    mongoc_collection_destroy(collection);
    mongoc_client_destroy(client);
    mongoc_cleanup();
    
    printf("{\"n\": %d, \"ok\": 1}", routes_size);
    return 0;
}


