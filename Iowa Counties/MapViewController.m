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
@property (nonatomic, strong) NSMutableArray *backgroundImageViews;
@property (strong, nonatomic) NSArray *imageUrls;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *detailViewTapRecognizer;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *backgroundViewPinchRecognizer;




@end



@implementation MapViewController

{
    AppContext* ctx;
    CLLocationManager *locationManager;
    
    CGFloat _prior_zoom_level;
    GMSCameraPosition* _prior_camera_pos;

    GMSCoordinateBounds * _valid_bounds;
    CLLocationCoordinate2D _last_valid_center;
    
    NSMutableData *_response_data;
    NSDictionary* markersByLocationID;
    
    BOOL showingOnlyBackgroundImage;
    
    UIImage* _placehodler_image;
    
}


- (IBAction)button_show_pressed:(id)sender {
    [self showDetailsOverlay];
}

- (IBAction)button_hide_pressed:(id)sender {
    [self hideDetailsOverlay];
}

- (IBAction)backgroundImageScrollViewTapped:(id)sender {
    //NSLog(@"Image Tapped: %@", sender);
    [self toggleShowBackgroundImageOnly];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    ctx = [AppContext instance];
    //NSLog(@"app name: %@", ctx.appName);
    //NSLog(@"app categories: %@", ctx.locationCategories);
    /*
    for(NSString *fontfamilyname in [UIFont familyNames])
    {
        NSLog(@"family:'%@'",fontfamilyname);
        for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
        {
            NSLog(@"\tfont:'%@'",fontName);
        }
        NSLog(@"-------------");
    }
    */
    
    NSLog(@"MAP VIEW LOADED");
    
    self.map_view.delegate = self;
    //self.map_view.mapType = kGMSTypeNormal;
    //self.map_view.mapType = kGMSTypeTerrain;
    //self.map_view.mapType = kGMSTypeSatellite;
    self.map_view.mapType = kGMSTypeHybrid;
    self.map_view.buildingsEnabled = YES;
    self.map_view.indoorEnabled = YES;
    self.map_view.myLocationEnabled = YES;
    self.map_view.settings.tiltGestures = NO;
    self.map_view.settings.rotateGestures = NO;
    
    self.detail_view.delegate = self;
    
    self.map_view.settings.myLocationButton = NO;
    self.map_view.settings.compassButton = NO;
    
    self.detail_view.hidden = YES;
    showingOnlyBackgroundImage = FALSE;
    
    CLLocationCoordinate2D NE = CLLocationCoordinate2DMake(43.33, -90.5);
    CLLocationCoordinate2D SW = CLLocationCoordinate2DMake(40.20, -96.39);
    _valid_bounds = [[GMSCoordinateBounds alloc] initWithCoordinate: NE
                                                  coordinate:  SW];

    

    
    
    [self fitBounds];
    [self initImagePager];
    
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.detail_view && [keyPath isEqualToString:@"frame"]) {
       
        // do your stuff, or better schedule to run later using performSelector:withObject:afterDuration:
        CGFloat h = 240 + self.detail_view.frame.origin.y;
        CGRect bgimageframe = self.scrollView.frame;
        bgimageframe.size.height = h;
        self.scrollView.frame = bgimageframe;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,h);
        
        for (UIView *view in [self.scrollView subviews]) {
            CGRect f = view.frame;
            f.size = self.scrollView.frame.size;
            view.frame =  f;
        }
        
    }
}




- (void) viewWillAppear:(BOOL)animated
{
    [self.detail_view addObserver:self forKeyPath:@"frame" options:0 context:nil];
}


- (void) viewWillDisappear:(BOOL)animated
{
    self.selectedLocationID = nil;
    [self.detail_view removeObserver:self forKeyPath:@"frame"];

}


- (void) viewDidAppear:(BOOL)animated
{
    if (self.selectedLocationID == nil){
        [ctx fetchResources:@"/locations/" withParams:nil setResultOn: self];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 50.0f; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
        [locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D here =  newLocation.coordinate;
    NSLog(@" GOT POSITION  %f  %f ", here.latitude, here.longitude);
    
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget: here zoom:12];
    [self.map_view animateWithCameraUpdate:update];
    [manager stopUpdatingLocation];

}







-(void)setResults: (NSArray*) results
{
    NSDictionary* item;
    for (item in results){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"ADDING MARKER: %@", item);
            [self addLocation: item];
        });
    }
    

}


- (void)addDirections:(NSDictionary *)json {
    
    NSDictionary *routes = [json objectForKey:@"routes"][0];
    
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overview_route = [route objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = self.map_view;
}




- (void) initImagePager {
    // a page is the width of the scroll view
    
    _placehodler_image = [UIImage imageNamed:@"loading.png"];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.pageControl.currentPage = 0;
}


- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
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


- (void) loadBackgroundImageList: (NSDictionary*) location {
    for (UIView *view in [self.scrollView subviews]) {
        [view removeFromSuperview];
    }

    //NSLog(@"loading image list: %@", [location objectForKey:@"image_list"]);
    
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
    
    CGSize frame_size = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(frame_size.width*numberOfPages, frame_size.height);
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
    [self gotoPage:FALSE];
    
    self.backgroundImageViews = nil;
    self.backgroundImageViews = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberOfPages; i++){
    	[self.backgroundImageViews addObject:[NSNull null]];
    }
    

    
    if (numberOfPages > 1)
        [self loadScrollViewWithPage:1];
    
    
    //append background image at the end
    CGRect img_frame = self.scrollView.frame;
    img_frame.origin.x = frame_size.width * (numberOfPages);
    img_frame.origin.y = 0;
    UIImageView* bgView = [[UIImageView alloc] initWithFrame:img_frame];
    [bgView setImage:[UIImage imageNamed: @"Default.png"] ];
    [bgView setContentMode: UIViewContentModeScaleAspectFill];
    [bgView setClipsToBounds:TRUE];
    [self.scrollView addSubview:bgView];
}


- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= [self.imageUrls count]){
        return;
    }
    
    NSString *image_src = [self.imageUrls objectAtIndex:page];
    //NSLog(@"loading image page: %d (%@)", page, image_src);
    
    // replace the placeholder if necessary
    UIImageView *bgView = [self.backgroundImageViews objectAtIndex:page];
    if ((NSNull *)bgView == [NSNull null]){
        
        CGRect img_frame = self.scrollView.frame;
        img_frame.origin.x = img_frame.size.width * page;
        img_frame.origin.y = 0;
        bgView = [[UIImageView alloc] initWithFrame:img_frame];
        if ([image_src hasPrefix:@"http"])
            [bgView setImageWithURL: [[NSURL alloc] initWithString:image_src] placeholderImage:_placehodler_image];
        else
            [bgView setImage:[UIImage imageNamed:image_src] ];
        [bgView setContentMode: UIViewContentModeScaleAspectFill];
        [bgView setClipsToBounds:TRUE];
    }
    
    // add the controller's view to the scroll view
    if (bgView.superview == nil){
        [self.scrollView addSubview:bgView];
    }
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    


}


// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.detail_view){
        return;
    }
    
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



//DETAIL VIEW SCROLLVIEW
- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.detail_view){
        if (showingOnlyBackgroundImage) {
            [self toggleShowBackgroundImageOnly];
        }
        else if (self.detail_view.contentOffset.y < -50){
            [self toggleShowBackgroundImageOnly];
        }
    }
}


- (IBAction)detailViewTapped:(id)sender {
    if (showingOnlyBackgroundImage){
        [self toggleShowBackgroundImageOnly];
    }
}


- (IBAction)swipeUpOnbackgroundView:(id)sender {
    if(showingOnlyBackgroundImage){
        [self toggleShowBackgroundImageOnly];
    }
}

- (IBAction)pinchOnBackgroundView:(UIPinchGestureRecognizer*)recognizer {
    if(recognizer.state != UIGestureRecognizerStateEnded){
        return;
    }
    
    if ((recognizer.scale > 1.0) && (showingOnlyBackgroundImage == FALSE)){ //zoom in from detail to images
        [self toggleShowBackgroundImageOnly];
    }
    if ((recognizer.scale) < 1.0 && (showingOnlyBackgroundImage == TRUE)){ //zoom out of from images to detail
        //[self toggleShowBackgroundImageOnly];
        [self hideDetailsOverlay];
    }
    if ((recognizer.scale < 1.0) && (showingOnlyBackgroundImage == FALSE)){ //zoom out of from detail to map
         [self hideDetailsOverlay];
    }
    
}


- (BOOL) mapView: (GMSMapView *) mapView didTapMarker: (GMSMarker *)  marker {
    [self gotoDetailsForMarker:marker animated: TRUE];
    return TRUE;
}


- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    
    
    CGFloat zoom = position.zoom;
    CLLocationCoordinate2D t = position.target;
    BOOL is_center_on_screen = [_valid_bounds containsCoordinate:t];
    

    if (is_center_on_screen && position.zoom >= 5.3){
        _last_valid_center = self.map_view.camera.target;
        return;
    }
    
    if (zoom < 5.3)
        zoom = 5.3;
    
    if (!is_center_on_screen)
        t = _last_valid_center;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:t zoom: zoom];
    [mapView setCamera:camera];
    
    
    
    
}



- (void) toggleShowBackgroundImageOnly {
    
    if (!showingOnlyBackgroundImage){
        CGRect detail_rect_hidden = [[self detail_view] frame];
        detail_rect_hidden.origin.y = 275;
        UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0, 55.0, 0.0);
        self.map_view.settings.myLocationButton = NO;
        self.map_view.settings.compassButton = NO;
        [UIView animateWithDuration:1.0
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [[self detail_view] setFrame:detail_rect_hidden];
                             self.map_view.padding = mapInsets;
                             //self.pageControl.frame = pageFrame;
                             //self.background_layer.alpha = 0.0;
                             //self.map_view.mapType = kGMSTypeTerrain;
                         }
                         completion:^(BOOL finished){
                             showingOnlyBackgroundImage = TRUE;
                             self.detailViewTapRecognizer.enabled = TRUE;
                         }];
    }else {
        self.detailViewTapRecognizer.enabled = FALSE;
        CGRect detail_rect_visible = [[self detail_view] frame];
        detail_rect_visible.origin.y = 0;
        UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0, 330.0, 0);
        
        self.map_view.settings.myLocationButton = NO;
        self.map_view.settings.compassButton = NO;
        
        [UIView animateWithDuration:1.0
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.detail_view.frame = detail_rect_visible;
                             self.map_view.padding = mapInsets;
                             //self.pageControl.frame = pageFrame;
                             //self.map_view.mapType = kGMSTypeSatellite;
                         }
                         completion:^(BOOL finished){
                             showingOnlyBackgroundImage = FALSE;
                         }];
    }
}



- (GMSMarker*) getMarkerForLocationWithID: (NSString*) mid
{
    return [markersByLocationID objectForKey:mid];
}







- (GMSMarker*) addLocation: (NSDictionary*) location {
    NSString* lat = [[location objectForKey:@"location"] objectForKey:@"coordinates"][0] ;
    NSString* lng = [[location objectForKey:@"location"] objectForKey:@"coordinates"][1];
    NSString* geo_str = [NSString stringWithFormat:@"(%@, %@)", lng, lat];
    CLLocationCoordinate2D position = [self loadGeoCoordinate: geo_str];
    GMSMarker *marker = [GMSMarker markerWithPosition: position];
    marker.icon = [ctx markerForCategory:[location objectForKey:@"category"]];
    marker.userData = location;
    marker.title = [location objectForKey:@"name"] ;
    [marker setAppearAnimation: kGMSMarkerAnimationPop];
    marker.map = self.map_view;
    return marker;
        //[markersByLocationID setValue:marker forKey: location_id];
    
}

- (CLLocationCoordinate2D) loadGeoCoordinate: (NSString*) location_str {
    float lat;
    float lon;
    NSScanner* scan = [NSScanner scannerWithString:location_str];
    [scan scanString:@"(" intoString:NULL];
    [scan scanFloat: &lat];
    [scan scanString:@"," intoString:NULL];
    [scan scanFloat: &lon];
    [scan scanString:@")" intoString:NULL];
    //NSLog(@"LOCATION  >%@<", location_str);
    return CLLocationCoordinate2DMake(lat, lon);
}






- (void) gotoDetailsForMarker: (GMSMarker*) marker animated: (BOOL) animated
{
    //NSLog(@"GOING TO MARKER");
    NSDictionary* location = (NSDictionary*)marker.userData;
    [self.detail_title setText:[location objectForKey:@"name"]] ;
    [self.detail_text setText: [location objectForKey:@"description"]];
    [self loadBackgroundImageList: location];
    [self centerOnMarker: marker animated: animated];
    [self showDetailsOverlay];
}





- (void) centerOnMarker:  (GMSMarker *)  marker animated: (BOOL) animated{
    GMSCameraPosition *new_cam = [GMSCameraPosition cameraWithTarget:marker.position zoom:18 bearing:45 viewingAngle:45];
    _prior_camera_pos = self.map_view.camera;
    
    if (animated){
        [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
        GMSCameraPosition *new_cam = [GMSCameraPosition cameraWithTarget:marker.position zoom:18 bearing:45 viewingAngle:45];
        [self.map_view animateToCameraPosition: new_cam];
        [CATransaction setCompletionBlock:^{}];
        [CATransaction commit];
    }else {
        [self.map_view setCamera:new_cam];
    }
}
- (void) centerOnMarker:  (GMSMarker *)  marker{
    [self centerOnMarker:marker animated:TRUE];
}





- (void)fitBounds {
    
    GMSCameraPosition* cam = [self.map_view cameraForBounds:_valid_bounds
                                                     insets: UIEdgeInsetsMake(20, 20, 20, 20)
                              ];
    _last_valid_center = cam.target;
    self.map_view.camera = cam;
    
}





- (void) showDetailsOverlay {
    //make sure its in the correct hidden position before animating
    self.detail_view.hidden = FALSE;
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 600;
    [self.detail_view setFrame:detail_rect_hidden];
    [self.detail_view setContentSize: CGSizeMake(320, 900) ];
    
    CGRect detail_rect_visible = [[self detail_view] frame];
    detail_rect_visible.origin.y = 0;
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0, 0, 330.0, 0);
    self.map_view.settings.myLocationButton = NO;
    self.map_view.settings.compassButton = NO;
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.detail_view.frame = detail_rect_visible;
                         self.map_view.padding = mapInsets;
                     }
                     completion:^(BOOL finished){
                             self.background_layer.hidden = FALSE;
                     }];
}


- (void) hideDetailsOverlay {
    CGRect detail_rect_hidden = [[self detail_view] frame];
    detail_rect_hidden.origin.y = 600;
    
    
    
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0, 0, 0.0, 0);
    self.map_view.settings.myLocationButton = NO;
    self.map_view.settings.compassButton = NO;

    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [[self detail_view] setFrame:detail_rect_hidden];
                         self.map_view.padding = mapInsets;
                         self.background_layer.alpha = 0.0;
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