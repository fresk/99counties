//
//  AppContext.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "AppContext.h"
#import "Utils.h"


static AppContext *ctx_instance = nil;
static dispatch_once_t onceToken;

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

@implementation AppContext {
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

    
    
    NSString *docs_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.favorites_fname = [docs_path stringByAppendingPathComponent:@"favorites.plist"];
    
    
    self.favorites = [NSMutableDictionary dictionaryWithContentsOfFile:self.favorites_fname];
    if (self.favorites == nil){
        //first start
        NSLog(@"creating blank favorites list");
        self.favorites = [[NSMutableDictionary alloc] init];
        //[self saveFavorites];
    }
    
    _currentLocation.latitude = 0.0;
    _currentLocation.longitude = 0.0;
    [self updateUserLocation];
    
    [self initCategories];
    [self initCities];

    //self.locationCategories = [Utils loadJsonFile:@"data/categories"];
    self.counties = [Utils loadJsonFile:@"data/counties"];
    
}



- (BOOL) saveFavorites {
    return[self.favorites writeToFile:self.favorites_fname atomically:TRUE];
}




-(void) initCategories
{
    NSDictionary* categoryNames = [Utils loadJsonFile:@"data/categories"];
    [self fetchResource:@"/categories/" withParams: nil onComplete:^(NSDictionary *data) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        NSDictionary* cat;
        for (cat in [data objectForKey:@"result"] ){
            NSString* category_id = [cat objectForKey:@"id"];
            NSString* category_name = [categoryNames objectForKey:category_id];
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


-(void) initCities
{
    [self fetchResource:@"/cities/" withParams: nil onComplete:^(NSDictionary *data) {
        self.cities = [data objectForKey:@"result"];
    }];
}




-(CLLocationCoordinate2D) getCurrentLocation
{
    return _currentLocation;
}

- (void) updateUserLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    _currentLocation =  newLocation.coordinate;
    [self.locationManager stopUpdatingLocation];
    
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


- (void) fetchResources:(NSString*) path withParams: (NSDictionary*) params setResultOn:(id)target
{
    [self fetchResource:path withParams:params onComplete:^(NSDictionary* data){
        [target setResults: [data objectForKey:@"result"]];
    }];
}





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





@end
