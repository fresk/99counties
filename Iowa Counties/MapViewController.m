//
//  MapViewController.m
//  99 Counties
//
//  Created by Thomas Hansen on 8/20/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>

#import "AppContext.h"


@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet GMSMapView *map_view;


@property (weak, nonatomic) IBOutlet UIScrollView *detail_view;
@property (weak, nonatomic) IBOutlet UILabel *detail_title;
@property (strong, nonatomic) IBOutlet UILabel *address_label;
@property (weak, nonatomic) IBOutlet UITextView *detail_text;
@property (strong, nonatomic) IBOutlet UILabel *phone_label;
@property (strong, nonatomic) IBOutlet UILabel *www_label;
@property (strong, nonatomic) IBOutlet UILabel *email_label;


@property (strong, nonatomic) IBOutlet UIView *background_layer;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSArray *imageUrls;

@end



@implementation MapViewController

{
    CGFloat _prior_zoom_level;
    GMSCameraPosition* _prior_camera_pos;
    CLLocationManager *locationManager;
    
    NSMutableData *_response_data;
    BOOL showingOnlyBackgroundImage;
}


- (IBAction)button_show_pressed:(id)sender {
    [self showDetailsOverlay];
}

- (IBAction)button_hide_pressed:(id)sender {
    [self hideDetailsOverlay];
}

- (IBAction)backgroundImageScrollViewTapped:(id)sender {
    NSLog(@"Image Tapped: %@", sender);
    [self toggleShowBackgroundImageOnly];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppContext* ctx = [AppContext instance];
    NSLog(@"app name: %@", ctx.appName);
    NSLog(@"app categories: %@", ctx.locationCategories);
    
    for(NSString *fontfamilyname in [UIFont familyNames])
    {
        NSLog(@"family:'%@'",fontfamilyname);
        for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
        {
            NSLog(@"\tfont:'%@'",fontName);
        }
        NSLog(@"-------------");
    }
    
    
    self.map_view.delegate = self;
    //self.map_view.mapType = kGMSTypeNormal;
    //self.map_view.mapType = kGMSTypeTerrain;
    //self.map_view.mapType = kGMSTypeSatellite;
    self.map_view.mapType = kGMSTypeHybrid;
    self.map_view.buildingsEnabled = YES;
    self.map_view.indoorEnabled = YES;
    self.map_view.myLocationEnabled = YES;
    
    self.map_view.settings.myLocationButton = YES;
    self.map_view.settings.compassButton = YES;
    
    self.detail_view.hidden = YES;
    showingOnlyBackgroundImage = FALSE;

    //[self loadBarns];
    [self fitBounds];
    [self api_request];
    [self initImagePager];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 50.0f; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [locationManager startUpdatingLocation];
    
}



-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    
    CLLocationCoordinate2D here =  newLocation.coordinate;
    NSLog(@" GOT POSITION  %f  %f ", here.latitude, here.longitude);
    
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget: here zoom:12];
    [self.map_view animateWithCameraUpdate:update];

}




- (void) api_request {
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://findyouriowa.com/api/locations/"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        _response_data = [NSMutableData data];

    }else {
        _response_data  = nil;
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    NSLog(@"received response %@", [response URL]);
    [_response_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    NSLog(@"received %d bytes of data",[data length]);
    [_response_data appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_response_data setLength:0];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a property elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[_response_data length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData: _response_data
                                                        options: 0
                                                          error: &myError];
    NSEnumerator *enumerator = [res objectEnumerator];
    NSDictionary* item;
    while (item = (NSDictionary*)[enumerator nextObject]) {
        //NSLog(@"adding: %@", item);
        [self addLocation:item];

    }
}



- (void) initImagePager {
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.currentPage = 0;
}



- (void) loadBackgroundImageList: (NSDictionary*) location {
    //for (UIView *view in [self.scrollView subviews]) {
    //    [view removeFromSuperview];
    //}
    
    NSLog(@"loading image list: %@", [location objectForKey:@"image_list"]);
    
    self.background_layer.alpha = 0.0;
    [UIView animateWithDuration: 1.0
                          delay: 1.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.background_layer.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         showingOnlyBackgroundImage = FALSE;
                     }];
    
    
    NSArray* _default = [NSArray arrayWithObjects:@"transparent.png", nil];
    self.imageUrls = [_default arrayByAddingObjectsFromArray:[location objectForKey:@"images"]];
    
    int numberOfPages = [self.imageUrls count];
    
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberOfPages,
               CGRectGetHeight(self.scrollView.frame));
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
    
    self.viewControllers = nil;
    self.viewControllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberOfPages; i++)
    {
		[self.viewControllers addObject:[NSNull null]];
    }
    if (numberOfPages > 0){
        [self loadScrollViewWithPage:0];
    }
    if (numberOfPages > 1){
        [self loadScrollViewWithPage:1];
    }
}



- (void)loadScrollViewWithPage:(NSUInteger)page
{
    
    NSLog(@"loading image page: %d", page);
    if (page >= [self.imageUrls count])
        return;
    
    if ([self.imageUrls count] == 0)
        return;
    
    // replace the placeholder if necessary
    UIViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[UIViewController alloc] init];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;

        
        
        CGRect img_frame = self.scrollView.frame;
        img_frame.origin.x = 0;
        img_frame.origin.y = 0;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:img_frame];
        NSString *image_src = [self.imageUrls objectAtIndex:page];
        [imageView setImageWithURL: [[NSURL alloc] initWithString:image_src] ];
        [imageView setContentMode: UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:TRUE];
        [controller.view addSubview:imageView];
    

        NSLog(@"image view with frame: %f, %f", frame.size.width, frame.size.height);
        
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        

  
    }
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    if (page > 1){
        [self loadScrollViewWithPage:page - 1];
    }
    
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}


- (CLLocationCoordinate2D) loadGeoCoordinate: (NSString*) location_str {
    float lat;
    float lon;
    NSLog(@"LOCATION STR %@", location_str);
    NSScanner* scan = [NSScanner scannerWithString:location_str];
    [scan scanString:@"(" intoString:NULL];
    [scan scanFloat: &lat];
    [scan scanString:@"," intoString:NULL];
    [scan scanFloat: &lon];
    [scan scanString:@")" intoString:NULL];
    NSLog(@"LAT: %f  LON: %f", lat, lon);
    return CLLocationCoordinate2DMake(lat, lon);
}


- (void) addLocation: (NSDictionary*) location {
    
    // Add a custom 'glow' marker around Sydney.
    NSString* lat = [[location objectForKey:@"location"] objectForKey:@"coordinates"][0] ;
    NSString* lng = [[location objectForKey:@"location"] objectForKey:@"coordinates"][1];
    NSString* geo_str = [NSString stringWithFormat:@"(%@, %@)", lat, lng];
    CLLocationCoordinate2D position = [self loadGeoCoordinate: geo_str];
    GMSMarker *marker = [GMSMarker markerWithPosition: position];
    marker.userData = location;
    marker.title = [location objectForKey:@"name"] ;
    marker.icon = [UIImage imageNamed: @"marker-barn"];
    [marker setAppearAnimation: kGMSMarkerAnimationPop];
    marker.map = self.map_view;
}




- (BOOL) mapView: (GMSMapView *) mapView didTapMarker: (GMSMarker *)  marker {
    NSDictionary* location = (NSDictionary*)marker.userData;
    [self.detail_title setText:[location objectForKey:@"name"]] ;
    [self.detail_text setText: [location objectForKey:@"description"]];
    [self loadBackgroundImageList: location];
    [self centerOnMarker: marker];
    [self showDetailsOverlay];
    return TRUE;
}


- (void) centerOnMarker:  (GMSMarker *)  marker{
    _prior_camera_pos = self.map_view.camera;
    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
    GMSCameraPosition *new_cam = [GMSCameraPosition cameraWithTarget:marker.position zoom:18 bearing:45 viewingAngle:45];
    [self.map_view animateToCameraPosition: new_cam];
    [CATransaction setCompletionBlock:^{}];
    [CATransaction commit];
}


- (void)fitBounds {
    GMSCoordinateBounds *bounds;
    CLLocationCoordinate2D NE = CLLocationCoordinate2DMake(43.30, -90.5);
    CLLocationCoordinate2D SW = CLLocationCoordinate2DMake(40.36, -96.31);
    bounds = [[GMSCoordinateBounds alloc] initWithCoordinate: NE
                                                  coordinate:  SW];
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget: self.map_view.myLocation.coordinate zoom:8];
    
    [self.map_view animateWithCameraUpdate:update];
}



- (void) toggleShowBackgroundImageOnly {

    if (!showingOnlyBackgroundImage){
        CGRect detail_rect_hidden = [[self detail_view] frame];
        CGRect pageFrame = [self.pageControl frame];
        
        pageFrame.origin.y = 530;
        detail_rect_hidden.origin.y = 600;
        
        UIEdgeInsets mapInsets = UIEdgeInsetsMake(70.0, 0.0, 0.0, 0.0);
        self.map_view.settings.myLocationButton = YES;
        self.map_view.settings.compassButton = YES;
        
        [UIView animateWithDuration:1.0
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [[self detail_view] setFrame:detail_rect_hidden];
                             self.map_view.padding = mapInsets;
                             self.pageControl.frame = pageFrame;
                             //self.background_layer.alpha = 0.0;
                             //self.map_view.mapType = kGMSTypeTerrain;
                         }
                         completion:^(BOOL finished){
                             showingOnlyBackgroundImage = TRUE;
                         }];
        
    }else {

        CGRect detail_rect_visible = [[self detail_view] frame];
        CGRect pageFrame = [self.pageControl frame];
        
        pageFrame.origin.y = 220;
        detail_rect_visible.origin.y = 0;
        
        
        
        
        UIEdgeInsets mapInsets = UIEdgeInsetsMake(70.0, 20.0, 330.0, 20.0);
        
        self.map_view.settings.myLocationButton = NO;
        self.map_view.settings.compassButton = NO;
        
        [UIView animateWithDuration:1.0
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.detail_view.frame = detail_rect_visible;
                             self.map_view.padding = mapInsets;
                             self.pageControl.frame = pageFrame;
                             //self.map_view.mapType = kGMSTypeSatellite;
                         }
                         completion:^(BOOL finished){
                             showingOnlyBackgroundImage = FALSE;
                         }];
    
    }
}



- (void) showDetailsOverlay {
    //showingOnlyBackgroundImage = FALSE;
    self.detail_view.hidden = FALSE;
    //make sure its in the correct hidden position before animating
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 600;
    [[self detail_view] setFrame:detail_rect_hidden];
    
    CGRect detail_rect_visible = [[self detail_view] frame];
    detail_rect_visible.origin.y = 0;
    
    [self.detail_view setContentSize: CGSizeMake(320, 900) ];
    
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(70.0, 20.0, 330.0, 20.0);

    self.map_view.settings.myLocationButton = NO;
    self.map_view.settings.compassButton = NO;

    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.detail_view.frame = detail_rect_visible;
                         self.map_view.padding = mapInsets;
                         //self.map_view.mapType = kGMSTypeSatellite;
                     }
                     completion:^(BOOL finished){

                             self.background_layer.hidden = FALSE;
                     }];
}


- (void) hideDetailsOverlay {
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 600;
    
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(70.0, 0.0, 0.0, 0.0);
    self.map_view.settings.myLocationButton = YES;
    self.map_view.settings.compassButton = YES;

    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [[self detail_view] setFrame:detail_rect_hidden];
                         self.map_view.padding = mapInsets;
                         self.background_layer.alpha = 0.0;
                         //self.map_view.mapType = kGMSTypeTerrain;
                     }
                     completion:^(BOOL finished){
                         self.background_layer.hidden = TRUE;
                         [CATransaction setValue:[NSNumber numberWithFloat: 2.0f] forKey:kCATransactionAnimationDuration];
                         [self.map_view animateToCameraPosition:_prior_camera_pos];
                         [CATransaction setCompletionBlock:^{}];
                         [CATransaction commit];
                     }];
    
}

@end