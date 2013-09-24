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

@end

@implementation MapViewController {
    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:41.577
                                                            longitude:-93.231
                                                                 zoom:4];
    
    self.map_view.delegate = self;
    self.map_view.settings.myLocationButton = YES;
    self.map_view.settings.compassButton = YES;
    

    

   
    
    [self loadBarns];
    [self performSelector:@selector(fitBounds)
               withObject:nil
               afterDelay:1]; //will zoom in after 5 seconds
    
}



- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker*)marker {
    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"Details"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    
}



- (CLLocationCoordinate2D)  loadGeoCoordinate: (NSDictionary*) geo {
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
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.title = [barn objectForKey:@"Property Name"] ;
    //marker.icon = [UIImage imageNamed:@"glow-marker"];
    marker.position = [self loadGeoCoordinate: [barn objectForKey:@"geo"]];
    marker.map = mapView_;
}


- (void)fitBounds {
    GMSCoordinateBounds *bounds;
    CLLocationCoordinate2D NE = CLLocationCoordinate2DMake(43.30, -90.5);
    CLLocationCoordinate2D SW = CLLocationCoordinate2DMake(40.36, -96.31);
    bounds = [[GMSCoordinateBounds alloc] initWithCoordinate: NE
                                                  coordinate:  SW];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:50.0];
    [mapView_ animateWithCameraUpdate:update];
    
    
}

- (IBAction)button_show_pressed:(id)sender {
    
    
    // Hide the panel and change the button's text
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 181;
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [[self detail_view] setFrame:detail_rect_hidden];
                     }
                     completion: nil];
    
    
    
    
}




- (IBAction)button_hide_pressed:(id)sender {
    
    
    // Hide the panel and change the button's text
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 600;
    
    [UIView animateWithDuration:.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [[self detail_view] setFrame:detail_rect_hidden];
                     }
                     completion: nil];
    
    
    
    
}


@end