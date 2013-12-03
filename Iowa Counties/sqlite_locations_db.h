//
//  sqlite_locations_db.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 12/3/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#ifndef Iowa_Counties_sqlite_locations_db_h
#define Iowa_Counties_sqlite_locations_db_h


/*
 id varchar PRIMARY KEY NOT NULL,
 lat float,
 lng float,
 name varchar,
 city varchar,
 images varchar,
 categories varchar,
 popularity float,
 last_update integer
 */


#import <sqlite3.h>

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    // check that we have four arguments (lat1, lon1, lat2, lon2)
    assert(argc == 4);
    // check that all four arguments are non-null
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    // get the four argument values
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    // convert lat1 and lat2 into radians now, to avoid doing it twice below
    double lat1rad = DEG2RAD(lat1);
    double lat2rad = DEG2RAD(lat2);
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1);
}



NSDictionary* locationFromSqlRow(sqlite3_stmt* stmt){
    
    NSDictionary* dict = @{
                           @"id": [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 0)],
                           @"lat": [NSNumber numberWithDouble:sqlite3_column_double(stmt, 1)],
                           @"lng": [NSNumber numberWithDouble:sqlite3_column_double(stmt, 2)],
                           @"name": [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)],
                           @"city": [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 4)],
                           @"images": [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 5)] componentsSeparatedByString:@","],
                           @"category": [[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 6)] componentsSeparatedByString:@","],
                           @"popularity": [NSNumber numberWithDouble:sqlite3_column_double(stmt, 7)]
                           };
    NSLog(@"DICT: %@", dict);
    return dict;
}


sqlite3* open_locations_db(){
    sqlite3* _db;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"db"];
    if (sqlite3_open([filePath UTF8String], &_db) == SQLITE_OK){
        NSLog(@"open sqlite:  OK.");
        
    }
    else
        NSLog(@"Failed to open sqlite3 DB.");
    
    if (sqlite3_create_function(_db, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL) == SQLITE_OK){
        
    }else{
        NSLog(@"Database returned error %d: %s", sqlite3_errcode(_db), sqlite3_errmsg(_db));
    }
    return _db;
};





#endif
