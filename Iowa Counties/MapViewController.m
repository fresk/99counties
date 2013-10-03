//
//  MapViewController.m
//  99 Counties
//
//  Created by Thomas Hansen on 8/20/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet GMSMapView *map_view;
@property (weak, nonatomic) IBOutlet UIView *detail_view;
@property (weak, nonatomic) IBOutlet UILabel *detail_title;
@property (weak, nonatomic) IBOutlet UITextView *detail_text;
@end

@implementation MapViewController  {
    CGFloat _prior_zoom_level;
    GMSCameraPosition* _prior_camera_pos;
}

- (IBAction)button_show_pressed:(id)sender {
    [self showDetailsOverlay];
}

- (IBAction)button_hide_pressed:(id)sender {
    [self hideDetailsOverlay];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.map_view.mapType = kGMSTypeNormal;
    self.map_view.mapType = kGMSTypeTerrain;
    self.map_view.mapType = kGMSTypeSatellite;
    self.map_view.mapType = kGMSTypeHybrid;
    
    
    self.map_view.delegate = self;
    self.map_view.settings.myLocationButton = YES;
    self.map_view.settings.compassButton = YES;

    [self loadBarns];
    [self fitBounds];
}




- (CLLocationCoordinate2D) loadGeoCoordinate: (NSDictionary*) geo {
    float lat = [[geo objectForKey:@"lat"] floatValue];
    float lon = [[geo objectForKey:@"lng"] floatValue];
    return CLLocationCoordinate2DMake(lat, lon);
}


- (void) loadBarns {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"barns" ofType:@"json"];
    NSString *json_string = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [json_string dataUsingEncoding:NSUTF8StringEncoding];
    //parse out the json data
    NSError* error;
    NSArray* barns = [NSJSONSerialization
                      JSONObjectWithData: data
                      options:0
                      error:&error];
    NSEnumerator *enumerator = [barns objectEnumerator];
    NSDictionary* item;
    while (item = (NSDictionary*)[enumerator nextObject]) {
        [self addMarkerForBarn:item];
    }
}


- (void) addMarkerForBarn: (NSDictionary*) barn {
    
    // Add a custom 'glow' marker around Sydney.
    CLLocationCoordinate2D position = [self loadGeoCoordinate: [barn objectForKey:@"geo"]];
    GMSMarker *marker = [GMSMarker markerWithPosition: position];
    marker.userData = barn;
    marker.title = [barn objectForKey:@"Property Name"] ;
    marker.icon = [UIImage imageNamed: @"marker-barn"];
    marker.map = self.map_view;
}


//- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker*)marker {
//}


- (BOOL) mapView: (GMSMapView *) mapView didTapMarker: (GMSMarker *)  marker {
    NSDictionary* barn = (NSDictionary*)marker.userData;
    [self.detail_title setText:[barn objectForKey:@"Property Name"]] ;
    [self.detail_text setText: @"Lorem Ipsum..."];
    [self centerOnMarker: marker];
    [self showDetailsOverlay];
    return TRUE;
}


- (void) centerOnMarker:  (GMSMarker *)  marker{
    _prior_camera_pos = self.map_view.camera;
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget:marker.position zoom:18];
    [self.map_view animateWithCameraUpdate: update];
    
    
}


- (void)fitBounds {
    GMSCoordinateBounds *bounds;
    CLLocationCoordinate2D NE = CLLocationCoordinate2DMake(43.30, -90.5);
    CLLocationCoordinate2D SW = CLLocationCoordinate2DMake(40.36, -96.31);
    bounds = [[GMSCoordinateBounds alloc] initWithCoordinate: NE
                                                  coordinate:  SW];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:50.0];
    
    [self.map_view animateWithCameraUpdate:update];
    
    

}

- (void) showDetailsOverlay {
    self.detail_view.hidden = FALSE;
    //make sure its in the correct hidden position before animating
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 600;
    [[self detail_view] setFrame:detail_rect_hidden];
    
    CGRect detail_rect_visible = [[self detail_view] frame];
    detail_rect_visible.origin.y = 181;
    
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(70.0, 0.0, 390.0, 0.0);

    self.map_view.settings.myLocationButton = NO;
    self.map_view.settings.compassButton = NO;

    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.detail_view.frame = detail_rect_visible;
                         self.map_view.padding = mapInsets;
                         //self.map_view.mapType = kGMSTypeSatellite;
                     }
                     completion:^(BOOL finished){
                         [self.map_view animateToViewingAngle:45];
                         [self.map_view animateToBearing:45];
                     }];
}


- (void) hideDetailsOverlay {
    
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 600;
    
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(70.0, 0.0, 0.0, 0.0);
    self.map_view.settings.myLocationButton = YES;
    self.map_view.settings.compassButton = YES;

    [UIView animateWithDuration:.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [[self detail_view] setFrame:detail_rect_hidden];
                         self.map_view.padding = mapInsets;
                         //self.map_view.mapType = kGMSTypeTerrain;
                     }
                     completion:^(BOOL finished){
                         [self.map_view animateToCameraPosition:_prior_camera_pos];
                     }];
    
    
}




@end