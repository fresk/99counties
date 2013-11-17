//
//  MapViewController.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 8/20/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>


@interface MapViewController : UIViewController <GMSMapViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>

@property(strong, atomic) NSString* selectedLocationID;

@property (strong, nonatomic) IBOutlet UIButton *go_back_button;

-(void)setResults: (NSArray*) results;

-(void) gotoLocationandNearby;

-(CLLocationCoordinate2D) get_current_location;

-(void)select_location: (NSDictionary*) location;

- (GMSMarker*) addLocation: (NSDictionary*) location;

- (void) gotoDetailsForMarker: (GMSMarker*) marker animated: (BOOL) animated;

-(NSArray*) get_visible_locations;

- (void) fitBounds;

-(void) hide_context_list;


@end
