//
//  AppContext.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <Foundation/Foundation.h>

#import "FilterResultsController.h"





@interface AppContext : NSObject <CLLocationManagerDelegate>



@property(atomic, strong) NSString* appName;

@property(atomic, strong) CLLocationManager* locationManager;
@property(atomic, strong) NSDictionary* selected_location;
@property(atomic, strong) NSDictionary* filtered_list;

@property(atomic, strong) NSDictionary* categories;
@property(atomic, strong) NSArray* cities;
@property(atomic, strong) NSDictionary* counties;
@property(atomic, strong) NSMutableDictionary* favorites;
@property(atomic, strong) NSString* favorites_fname;


@property(atomic, strong) NSDictionary* categoryNames;


+ (id)instance;

- (CLLocationCoordinate2D) currentLocation;
- (BOOL) knowsLocation;
- (BOOL) locationEnabled;
- (BOOL) saveFavorites;

- (NSArray*) getLocationsBySearch: (NSString*) search_term;
- (NSArray*) getLocationsByProximity: (CLLocationCoordinate2D) location;
- (NSArray*) getLocationsByCategory: (NSString*) category;
- (NSArray*) getLocationsByCity: (NSString*) city;
- (NSArray*) getLocationsByPopularity;
- (NSArray*) getRandomLocations: (int) limit;

- (UIImage*) markerForCategory: (NSArray*) category;
- (UIImage*) markerForCategoryID: (NSString*) category;


typedef void (^fetchComplete)(NSDictionary* data);
typedef void (^httpResponseHandler)(NSData* data, NSURLResponse* response, NSError* error);
- (void) fetchResource:(NSString*) path withParams: (NSDictionary*) params onComplete: (fetchComplete) blockComplete;
- (void) fetchResources:(NSString*) path withParams: (NSDictionary*) params setResultOn:(id)target;

@end
