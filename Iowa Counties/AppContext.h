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
@property(atomic, strong) NSDictionary* locationCategories;
@property(atomic, strong) NSDictionary* counties;
@property(atomic, strong) CLLocationManager* locationManager;

+ (id)instance;
- (UIImage*) markerForCategory: (NSArray*) category;
- (UIImage*) markerForCategoryID: (NSString*) category;
-(CLLocationCoordinate2D) getCurrentLocation;


- (void) fetchResources:(NSString*) path withParams: (NSDictionary*) params setResultOn:(id)target;

@end
