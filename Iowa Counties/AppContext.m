//
//  AppContext.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "AppContext.h"
#import "Utils.h"
#import "sqlite_locations_db.h"

static AppContext *ctx_instance = nil;
static dispatch_once_t onceToken;

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

@implementation AppContext {
    BOOL _knowsLocation;
    BOOL _locationServiceDenied;
    CLLocationCoordinate2D _currentLocation;
}

+ (id)instance {
    dispatch_once(&onceToken, ^{
        ctx_instance = [self alloc];
        ctx_instance = [ctx_instance init];
        [ctx_instance initializeContext];
    });
    return ctx_instance;
}

- (void)initializeContext {
    self.appName = @"Find Your Iowa";
    [self initFavorites];
    [self initLocation];
    [self initCategories];
    [self initCities];
}



-(void) initLocation{
    _knowsLocation = FALSE;
    _locationServiceDenied = FALSE;
    _currentLocation.latitude = 0.0;
    _currentLocation.longitude = 0.0;
    [self updateUserLocation];
}

-(void) initFavorites {
    NSString *docs_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.favorites_fname = [docs_path stringByAppendingPathComponent:@"favorites.plist"];
    
    self.favorites = [NSMutableDictionary dictionaryWithContentsOfFile:self.favorites_fname];
    if (self.favorites == nil){
        //first start
        NSLog(@"creating blank favorites list");
        self.favorites = [[NSMutableDictionary alloc] init];
        [self saveFavorites];
    }
}

-(void) initCategories {
    self.categoryNames = [Utils loadJsonFile:@"data/categories"];
    [self fetchResource:@"/categories/" withParams: nil onComplete:^(NSDictionary *data) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        NSDictionary* cat;
        for (cat in [data objectForKey:@"result"] ){
            NSString* category_id = [cat objectForKey:@"id"];
            NSString* category_name = [[self.categoryNames objectForKey:category_id] objectForKey:@"name"];;
            if(category_name == nil){
                category_name = category_id;
            }
            [dict setObject: @{@"id": category_id,
                               @"num_entries": [cat objectForKey:@"num_entries"],
                               @"name": category_name}
                     forKey:category_id];
        }
        self.categories = [NSDictionary dictionaryWithDictionary:dict];
    }];
}

-(void) initCities {
    [self fetchResource:@"/cities/" withParams: nil onComplete:^(NSDictionary *data) {
        self.cities = [data objectForKey:@"result"];
    }];
}



- (BOOL) saveFavorites {
    return[self.favorites writeToFile:self.favorites_fname atomically:TRUE];
}





-(CLLocationCoordinate2D) currentLocation {
    if (_locationServiceDenied || _knowsLocation == FALSE){
        [self updateUserLocation];
    }
    return _currentLocation;
}

- (BOOL) knowsLocation{
    return _knowsLocation;
};

- (void) updateUserLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 10;
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"CONTEXT UPDATE: location");
    _knowsLocation = TRUE;
    _currentLocation =  newLocation.coordinate;    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    
    NSString *errorString;
    
    NSLog(@"Your Location: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            _locationServiceDenied = TRUE;
            errorString = @"Access to Location Services denied by user";
            return;
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Currently unable to determine your location!";
            //Do something else...
            break;
        default:
            errorString = @"An unknown error occurred while trying to determine your location";
            break;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your Location:" message:errorString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}







- (UIImage*) markerForCategory: (NSArray*) category {
    NSString* fname = [NSString stringWithFormat:@"marker-%@.png", category[0]];
    UIImage* img =  [UIImage imageNamed: fname];
    //NSLog(@"LOAD IMAGE:  %@ (%f, %f)", fname, img.size.width, img.size.height);
    return img;
}

- (UIImage*) markerForCategoryID: (NSString*) category {
    NSString* fname = [NSString stringWithFormat:@"marker-%@.png", category];
    UIImage* img =  [UIImage imageNamed: fname];
    //NSLog(@"LOAD IMAGE:  %@ (%f, %f)", fname, img.size.width, img.size.height);
    return img;
}










- (NSArray*) getLocationsByProximity: (CLLocationCoordinate2D) location {
    sqlite3* db = open_locations_db();
    sqlite3_stmt* sql_stmt;
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    NSString *sql_query = [NSString stringWithFormat:
                           @"SELECT id, lat, lng, name, city, images, categories, popularity, last_update FROM locations ORDER BY distance(lat, lng, %f, %f) LIMIT 15",
                           location.latitude ,location.longitude ];
    
    if (sqlite3_prepare_v2(db, [sql_query UTF8String], -1, &sql_stmt, NULL) != SQLITE_OK){
        NSLog(@"Database returned error %d: %s", sqlite3_errcode(db), sqlite3_errmsg(db));
        sqlite3_close(db);
        return results;
    }
    
    while(sqlite3_step(sql_stmt) == SQLITE_ROW){
        NSDictionary* location = locationFromSqlRow(sql_stmt);
        [results addObject:location];
    }
    
    sqlite3_finalize(sql_stmt);
    sqlite3_close(db);
    return results;
}


- (NSArray*) getLocationsByCategory: (NSString*) category {
    
    sqlite3* db = open_locations_db();
    sqlite3_stmt* sql_stmt;
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    NSString *sql_query = [NSString stringWithFormat:
                           @"SELECT locations.id, locations.lat, locations.lng, locations.name, locations.city, locations.images, locations.categories, locations.popularity, locations.last_update from (location_categories left join locations on locations.id = location_categories.location_id)  WHERE category_id == \"%@\"" , category ];
    
    if (sqlite3_prepare_v2(db, [sql_query UTF8String], -1, &sql_stmt, NULL) != SQLITE_OK){
        NSLog(@"Database returned error %d: %s", sqlite3_errcode(db), sqlite3_errmsg(db));
        sqlite3_close(db);
        return results;
    }
    
    while(sqlite3_step(sql_stmt) == SQLITE_ROW){
        NSDictionary* location = locationFromSqlRow(sql_stmt);
        [results addObject:location];
    }
    sqlite3_finalize(sql_stmt);
    sqlite3_close(db);
    return results;
}


- (NSArray*) getLocationsByCity: (NSString*) city {
    sqlite3* db = open_locations_db();
    sqlite3_stmt* sql_stmt;
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    NSString *sql_query = [NSString stringWithFormat:
                           @"SELECT id, lat, lng, name, city, images, categories, popularity, last_update FROM locations WHERE locations.city == \"%@\"", city ];
    if (sqlite3_prepare_v2(db, [sql_query UTF8String], -1, &sql_stmt, NULL) != SQLITE_OK){
        NSLog(@"Database returned error %d: %s", sqlite3_errcode(db), sqlite3_errmsg(db));
        sqlite3_close(db);
        return results;
    }
    while(sqlite3_step(sql_stmt) == SQLITE_ROW){
        NSDictionary* location = locationFromSqlRow(sql_stmt);
        [results addObject:location];
    }
    sqlite3_finalize(sql_stmt);
    sqlite3_close(db);
    return results;
}


- (NSArray*) getLocationsByPopularity{
    sqlite3* db = open_locations_db();
    sqlite3_stmt* sql_stmt;
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    NSString *sql_query = @"SELECT id, lat, lng, name, city, images, categories, popularity, last_update FROM locations ORDER BY popularity DESC;";
    if (sqlite3_prepare_v2(db, [sql_query UTF8String], -1, &sql_stmt, NULL) != SQLITE_OK){
        NSLog(@"Database returned error %d: %s", sqlite3_errcode(db), sqlite3_errmsg(db));
        sqlite3_close(db);
        return results;
    }
    while(sqlite3_step(sql_stmt) == SQLITE_ROW){
        NSDictionary* location = locationFromSqlRow(sql_stmt);
        [results addObject:location];
    }
    sqlite3_finalize(sql_stmt);
    sqlite3_close(db);
    return results;
}





- (NSArray*) getRandomLocations: (int)limit{
    sqlite3* db = open_locations_db();
    sqlite3_stmt* sql_stmt;
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    NSString *sql_query = [NSString stringWithFormat:
        @"SELECT id, lat, lng, name, city, images, categories, popularity, last_update FROM locations ORDER BY RANDOM() LIMIT %d;", limit];
    if (sqlite3_prepare_v2(db, [sql_query UTF8String], -1, &sql_stmt, NULL) != SQLITE_OK){
        NSLog(@"Database returned error %d: %s", sqlite3_errcode(db), sqlite3_errmsg(db));
        sqlite3_close(db);
        return results;
    }
    while(sqlite3_step(sql_stmt) == SQLITE_ROW){
        NSDictionary* location = locationFromSqlRow(sql_stmt);
        [results addObject:location];
    }
    sqlite3_finalize(sql_stmt);
    sqlite3_close(db);
    return results;
}










- (void) fetchResources:(NSString*) path withParams: (NSDictionary*) params setResultOn:(id)target
{
    [self fetchResource:path withParams:params onComplete:^(NSDictionary* data){
        [target setResults: [data objectForKey:@"result"]];
    }];
}


- (void) fetchResource:(NSString*) path withParams: (NSDictionary*) params onComplete: (fetchComplete) blockComplete;
{
    NSString* endpoint;
    if ([path hasPrefix:@"http:"]) {
        endpoint = path;
    }else if ([path hasPrefix:@"/"]){
        endpoint = [NSString stringWithFormat:@"http://findyouriowa.com/api/%@", [path substringFromIndex:1]];
    } else {
        endpoint = [NSString stringWithFormat:@"http://findyouriowa.com/api/%@", path];
    }
    
    NSLog(@"requesting: %@", endpoint);
    httpResponseHandler responseHandler = ^(NSData *data, NSURLResponse *response, NSError *error){
        //NSLog(@"GOT RESPONSE: %d", data count);
        NSError *err;
        if (err != nil)
            NSLog(@"URLRequest callback error {{loadLocationsWhere: Matches: intoTable:}}: %@", err);
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (err != nil){
            NSString* json_str = [NSString stringWithUTF8String:data.bytes];
            NSLog(@"\n\nData: %@\n\n Json parsing error: %@", json_str, err);
        }
        blockComplete(result);
    };
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSURL* requestURL = [NSURL URLWithPath:endpoint andParams:params];
    NSURLRequest *request = [NSURLRequest requestWithURL: requestURL];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler: responseHandler ];
    [task resume];
}


/*

- (void) fetchDirectionsFrom: (NSString*) origin To: (NSString*) destination {
    [self fetchResource:@"http://maps.googleapis.com/maps/api/directions/json"
             withParams: @{
                           @"sensor":@"false",
                           @"origin": origin,
                           @"destination": destination
                           }
             onComplete:^(NSDictionary *data) {
                 
             }
     ];
    
}
*/



@end
