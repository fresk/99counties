//
//  MapViewController.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 8/20/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ContextList.h"

@interface MapViewController : UIViewController <GMSMapViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>

@property(strong, atomic) NSString* selectedLocationID;

@property (strong, nonatomic) IBOutlet UIButton *context_tab;
@property (strong, atomic) ContextList* context_list;

- (IBAction)button_hide_pressed:(id)sender;
- (IBAction)button_show_pressed:(id)sender;
//- (void) gotoDetailsForLocationWithID: (NSString*) lid;
- (GMSMarker*) addLocation: (NSDictionary*) location;
- (void) gotoDetailsForMarker: (GMSMarker*) marker animated: (BOOL) animated;
- (void) fitBounds;
@end
