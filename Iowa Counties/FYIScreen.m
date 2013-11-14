//
//  FYIScreen.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/13/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "FYIScreen.h"
#import "AppContext.h"

@interface FYIScreen ()


@end

@implementation FYIScreen {

    AppContext* ctx;
    GMSCoordinateBounds* _iowa_bounds;
    CLLocationManager* _location_manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ctx = [AppContext instance];
    
    [self init_map];
    [self init_context_list];
    [self init_detail_view];
    
    
}



-(void)  init_map {
    self.map_view.delegate = self;
    self.map_view.buildingsEnabled = YES;
    self.map_view.indoorEnabled = YES;
    self.map_view.myLocationEnabled = YES;
    self.map_view.settings.tiltGestures = NO;
    self.map_view.settings.rotateGestures = NO;
    self.map_view.mapType = kGMSTypeNormal;
    //self.map_view.mapType = kGMSTypeTerrain;
    //self.map_view.mapType = kGMSTypeSatellite;
    //self.map_view.mapType = kGMSTypeHybrid;
    [self fit_bounds];
}


-(void) init_context_list {
    self.context_list = [[ContextList alloc] initWithNibName:@"ContextList" bundle:nil];

    self.context_tab.frame = CGRectMake(280,40,40,40);
    self.context_list.view.frame = CGRectOffset(self.view.frame, 320, 0);
    [self.view addSubview:self.context_list.view];
}


-(void) init_detail_view {
    self.detail_view = [[DetailView alloc] initWithNibName:@"DetailView" bundle:nil];
    self.detail_view.view.frame = self.view.frame;
    [self.view addSubview:self.detail_view.view];

    
}


- (IBAction)context_tab_tapped:(id)sender {
    NSLog(@"IMAGE TAPPED");
    [self show_context_list];
}




- (IBAction)show_context_list_btn:(id)sender {
    if (self.context_list.view.frame.origin.x > 310){
        [self show_context_list];
    }
    else {
        [self hide_context_list];
    }
    
}


-(void) show_context_list {
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab.frame = CGRectMake(40,40,40,40);
        self.context_list.view.frame = CGRectOffset(self.view.frame, 80, 0);
    }];
}


-(void) hide_context_list {
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab.frame = CGRectMake(280,40,40,40);
        self.context_list.view.frame = CGRectOffset(self.view.frame, 320, 0);
    }];
}




/*
- (BOOL) mapView: (GMSMapView *) mapView didTapMarker: (GMSMarker *)  marker {
    //[self gotoDetailsForMarker:marker animated: FALSE];
    return FALSE;
}
*/


-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D here =  newLocation.coordinate;
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget: here zoom:12];
    [self.map_view animateWithCameraUpdate:update];
    [manager stopUpdatingLocation];
    
}


- (void)fit_bounds {
    GMSCameraPosition* cam;
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 20, 20, 20);
    CLLocationCoordinate2D NE = CLLocationCoordinate2DMake(43.33, -90.5);
    CLLocationCoordinate2D SW = CLLocationCoordinate2DMake(40.20, -96.39);
    _iowa_bounds = [[GMSCoordinateBounds alloc] initWithCoordinate: NE
                                                        coordinate:  SW];
    cam= [self.map_view cameraForBounds:_iowa_bounds insets: padding];
    self.map_view.camera = cam;
}



- (GMSMarker*) add_location: (NSDictionary*) location {
    CLLocationCoordinate2D position = [self get_location_coordinates: location];
    GMSMarker *marker = [GMSMarker markerWithPosition: position];
    marker.icon = [ctx markerForCategory:[location objectForKey:@"category"]];
    marker.userData = location;
    marker.title = [location objectForKey:@"title"];
    [marker setAppearAnimation: kGMSMarkerAnimationPop];
    marker.map = self.map_view;
    return marker;
}


- (CLLocationCoordinate2D) get_location_coordinates:  (NSDictionary*) location{
    NSString* slat = [[location objectForKey:@"location"] objectForKey:@"coordinates"][0] ;
    NSString* slng = [[location objectForKey:@"location"] objectForKey:@"coordinates"][1];
    NSString* location_str = [NSString stringWithFormat:@"(%@, %@)", slng, slat];

    NSScanner* scan = [NSScanner scannerWithString:location_str];
    float lat;
    float lon;
    [scan scanString:@"(" intoString:NULL];
    [scan scanFloat: &lat];
    [scan scanString:@"," intoString:NULL];
    [scan scanFloat: &lon];
    [scan scanString:@")" intoString:NULL];
    return CLLocationCoordinate2DMake(lat, lon);
}





-(void) animateToNewCameraPosition: (GMSCameraPosition*) new_cam {
    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
    [self.map_view animateToCameraPosition: new_cam];
    [CATransaction setCompletionBlock:^{}];
    [CATransaction commit];
    
}





@end
