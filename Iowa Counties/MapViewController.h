//
//  MapViewController.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 8/20/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController : UIViewController <GMSMapViewDelegate>


- (IBAction)button_hide_pressed:(id)sender;
- (IBAction)button_show_pressed:(id)sender;

@end
