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
-(void) hide_context_list;

-(void)select_location: (NSDictionary*) location;

-(NSArray*) get_visible_locations;

- (GMSMarker*) addLocation: (NSDictionary*) location;
- (void) gotoDetailsForMarker: (GMSMarker*) marker animated: (BOOL) animated;
- (void) fitBounds;

@end
