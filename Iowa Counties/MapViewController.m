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
#import "Utils.h"
#import "AppContext.h"
#import "ContextList.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet GMSMapView *map_view;


@property (weak, nonatomic) IBOutlet UIScrollView *detail_view;
@property (weak, nonatomic) IBOutlet UILabel *detail_title;
@property (strong, nonatomic) IBOutlet UILabel *address_label;
@property (strong, nonatomic) IBOutlet UIWebView *detail_text;
//@property (weak, nonatomic) IBOutlet UITextView *detail_text;
@property (strong, nonatomic) IBOutlet UILabel *phone_label;
@property (strong, nonatomic) IBOutlet UILabel *www_label;
@property (strong, nonatomic) IBOutlet UILabel *email_label;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;


@property (strong, nonatomic) IBOutlet UIView *background_layer;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *backgroundImageViews;
@property (strong, nonatomic) NSMutableArray *imageUrls;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *detailViewTapRecognizer;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *backgroundViewPinchRecognizer;
@property (strong, nonatomic) UIImageView* snapshot;




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
    BOOL comingFromListView;
    
    UIImage* _placehodler_image;
    
    NSDictionary* _selected_location;
    
    UIImageView* _map_cover;
    
    NSMutableArray* _photoFramesForTop;
    NSMutableArray* _photoFramesForCenter;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    ctx = [AppContext instance];
    //NSLog(@"app name: %@", ctx.appName);
    //NSLog(@"app categories: %@", ctx.locationCategories)
    
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
    [self init_context_list];
}


- (void) viewDidAppear:(BOOL)animated {
    if (self.selectedLocationID == nil){
        comingFromListView = FALSE;
        //[ctx fetchResources:@"/locations/" withParams:nil setResultOn: self];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 50.0f; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
        [locationManager startUpdatingLocation];
    }
    else {
        comingFromListView = TRUE;
        self.map_view.padding = UIEdgeInsetsMake(100, 0, 330.0, 0);
        
        [self navigationController].navigationBarHidden = TRUE;
        
    }
    
}



- (void) viewWillDisappear:(BOOL)animated {
    self.selectedLocationID = nil;
}





-(void) init_context_list {
    self.go_back_button.enabled = TRUE;
    self.go_back_button.alpha = 1.0;
    
    self.context_list = [[ContextList alloc] initWithNibName:@"ContextList" bundle:nil];
    self.context_tab.frame = CGRectMake(280,40,40,40);
    self.context_list.view.frame = CGRectOffset(self.view.frame, 320, 0);

    [self addChildViewController:self.context_list];
    [self.view addSubview:self.context_list.view];
}




- (IBAction)show_context_list_btn:(id)sender {
    if (self.go_back_button.enabled){
        [self show_context_list];
    }
    else {
        [self hide_context_list];
    }
}


-(void) show_context_list {
    NSMutableArray* visible_locations = [[NSMutableArray alloc] init];
    GMSProjection* projection = self.map_view.projection;
    for(int i=0; i<[self.map_view.markers count]; i++){
        GMSMarker* m = [self.map_view.markers objectAtIndex:i];
        if ([projection containsCoordinate: m.position]){
            [visible_locations addObject: m.userData];
        }
    }
    ContextList* ctx_list = (ContextList*) self.context_list;
    [ctx_list setResults: visible_locations];

    self.context_list.view.frame = CGRectOffset(self.view.frame, 320, 0);
    self.go_back_button.enabled = FALSE;
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab.frame = CGRectMake(10,25,40,40);
        self.context_list.view.frame = CGRectOffset(self.view.frame, 60, 0);
    }];
    
    [UIView animateWithDuration:1.0 delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         self.go_back_button.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}


-(void) hide_context_list {
    
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab.frame = CGRectMake(280,25,40,40);
        self.context_list.view.frame = CGRectOffset(self.view.frame, 320, 0);
    }];
    
    self.go_back_button.enabled = TRUE;
    [UIView animateWithDuration:1.0 delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         self.go_back_button.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
 
                     }];
}



-(GMSMarker*) getMarkerForLocationID: (NSString*) lid
{
    for(int i=0; i<[self.map_view.markers count]; i++){
        GMSMarker* m = [self.map_view.markers objectAtIndex:i];
        if ([lid isEqualToString: [m.userData objectForKey:@"id"]]){
            return m;
        }
    }
    return nil;

}


-(void)select_location: (NSDictionary*) location {
    ctx.selected_location = location;
    GMSMarker* selected_marker = [self getMarkerForLocationID:[location objectForKey:@"id"]];
    [self gotoDetailsForMarker:selected_marker animated:TRUE];
    [self hide_context_list];

}





//####################################################################################
//
//   IB Actions
//
//####################################################################################

- (IBAction)button_back_pressed:(id)sender {
    
    if (comingFromListView){
        [[self navigationController] popViewControllerAnimated:TRUE];
        [self navigationController].navigationBarHidden = FALSE;
        return;
    }
    
    if(self.background_layer.hidden == TRUE){
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainMenuViewController = [storyBoard instantiateViewControllerWithIdentifier:@"main_menu"];
        [self presentModalViewController: mainMenuViewController animated:YES];
        
    }
    else {
        [self hideDetailsOverlay];
    
    }
    
}


- (IBAction)button_show_pressed:(id)sender {
    //[self showDetailsOverlay];
}

- (IBAction)button_hide_pressed:(id)sender {
    [self hideDetailsOverlay];
}

- (IBAction)backgroundImageScrollViewTapped:(id)sender {
    //NSLog(@"Image Tapped: %@", sender);
    [self toggleShowBackgroundImageOnly];
}

- (IBAction)toggleMapType:(id)sender {
    if (self.map_view.mapType == kGMSTypeNormal)
        self.map_view.mapType = kGMSTypeSatellite;
    
    else if (self.map_view.mapType == kGMSTypeSatellite)
        self.map_view.mapType = kGMSTypeTerrain;
    
    else if (self.map_view.mapType == kGMSTypeTerrain)
        self.map_view.mapType = kGMSTypeHybrid;
    
    else if (self.map_view.mapType == kGMSTypeHybrid)
        self.map_view.mapType = kGMSTypeNormal;
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





//####################################################################################
//
//   MAP METHODS
//
//####################################################################################

-(void)setResults: (NSArray*) results
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ContextList* ctx_list = (ContextList*) self.context_list;
        [ctx_list setResults: results];
    
    });
    
    NSDictionary* item;
    for (item in results){
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"ADDING MARKER: %@", item);
            [self addLocation: item];
        });
    }
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


- (BOOL) mapView: (GMSMapView *) mapView didTapMarker: (GMSMarker *)  marker {
    [self gotoDetailsForMarker:marker animated: FALSE];
    return TRUE;
}


- (GMSMarker*) getMarkerForLocationWithID: (NSString*) mid
{
    return [markersByLocationID objectForKey:mid];
}



- (void)addDirections:(NSDictionary *)json {
    
    NSDictionary *routes = [json objectForKey:@"routes"][0];
    
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overview_route = [route objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = self.map_view;
}


- (void)fitBounds {
    GMSCameraPosition* cam;
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 20, 20, 20);
    cam= [self.map_view cameraForBounds:_valid_bounds insets: padding];
    _last_valid_center = cam.target;
    self.map_view.camera = cam;
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


-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D here =  newLocation.coordinate;
    //NSLog(@" GOT POSITION  %f  %f ", here.latitude, here.longitude);
    
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget: here zoom:12];
    [self.map_view animateWithCameraUpdate:update];
    [manager stopUpdatingLocation];
    
    CLLocationCoordinate2D cloc = newLocation.coordinate;
    [ctx fetchResources:@"/nearby"
             withParams:@{
                          @"lat": [NSNumber numberWithDouble: cloc.latitude],
                          @"lng": [NSNumber numberWithDouble: cloc.longitude]
                          }
            setResultOn: self];

    
}


-(void) animateToNewCameraPosition: (GMSCameraPosition*) new_cam
{
    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
    [self.map_view animateToCameraPosition: new_cam];
    [CATransaction setCompletionBlock:^{}];
    [CATransaction commit];

}





//####################################################################################
//
//   PHOTO PAGER FOR DETAIL BACKGROUND
//
//####################################################################################

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

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
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


- (void) loadBackgroundImageList: (NSDictionary*) location {
    for (UIView *view in [self.scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    _photoFramesForTop = nil;
    _photoFramesForCenter = nil;
    self.backgroundImageViews = nil;
    
    _photoFramesForTop = [[NSMutableArray alloc] init];
    _photoFramesForCenter = [[NSMutableArray alloc] init];
    self.backgroundImageViews = [[NSMutableArray alloc] init];
    
    self.imageUrls = nil;
    self.imageUrls = [[NSMutableArray alloc] init];
    [self.imageUrls addObject: @"transparent.png"];

    NSArray* location_images = [location objectForKey:@"images"];
    for (NSString* image_url in location_images) {
        if ([image_url length] > 4){
            [self.imageUrls addObject:image_url];
        }
    }
    
    NSLog(@"IMAGES: %@", self.imageUrls);
    
    int numberOfPages = [self.imageUrls count];
    
    CGSize frame_size = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(frame_size.width*numberOfPages, frame_size.height);
    

    for (NSUInteger i = 0; i < numberOfPages; i++){
        
        NSString *photo_src = [self.imageUrls objectAtIndex:i];
        
        CGFloat offsetX = 320 * i;
        CGRect photo_frame = CGRectOffset(self.scrollView.frame, offsetX, 0);
        [_photoFramesForTop addObject: [NSValue valueWithCGRect:photo_frame] ]; //still needs adjusted once we know size
        [_photoFramesForCenter addObject:[NSValue valueWithCGRect:photo_frame]];
   
        UIImageView* photo = [[UIImageView alloc] initWithFrame: photo_frame];
        photo.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:photo];
        [self.backgroundImageViews addObject:photo];
        
        if ([photo_src hasPrefix:@"http"]){
            NSURL* photo_url = [NSURL URLWithString:photo_src];
            
            [photo setImageWithURL:photo_url placeholderImage:_placehodler_image
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             
                             CGFloat scale =  320/image.size.width;
                             CGFloat scaled_height = image.size.height * scale;
                             
                             CGRect f = [[_photoFramesForTop objectAtIndex: i] CGRectValue];
                             f.size = CGSizeMake(f.size.width, scaled_height);
                             [_photoFramesForTop replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:f]];
                             
                             UIImageView* photo_ = [self.backgroundImageViews objectAtIndex: i];
                             photo_.frame = f;
                         }];
        }
        else
            [photo setImage:[UIImage imageNamed:photo_src] ];
    }
    
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
    [self gotoPage:FALSE];
    
    self.pageControl.hidden = (numberOfPages < 2);

}


// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView){
        CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
        NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        NSUInteger old_page = self.pageControl.currentPage;
        self.pageControl.currentPage = page;
        [_map_cover removeFromSuperview];
        _map_cover = nil;
        if (page == 0){
            self.background_layer.backgroundColor = [UIColor clearColor];
        }
    }
    
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


-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if(scrollView == self.scrollView){
        UIImage* snapshot = [Utils imageWithView:self.map_view];
        _map_cover = [[UIImageView alloc] initWithImage:snapshot];
        [self.scrollView addSubview:_map_cover];
        self.background_layer.backgroundColor = [UIColor blackColor];
    }
}

- (void) alignPhotosCenter {
    for(int i=0; i<[self.backgroundImageViews count]; i++) {
        UIImageView* photo = [self.backgroundImageViews objectAtIndex:i];
        CGRect f = [[_photoFramesForCenter objectAtIndex:i] CGRectValue];
        [UIView animateWithDuration:1.0 animations:^(void) {
            photo.frame = f;
        }];
    }
}

- (void) alignPhotosTop {
    for(int i=0; i<[self.backgroundImageViews count]; i++) {
        UIImageView* photo = [self.backgroundImageViews objectAtIndex:i];
        CGRect f = [[_photoFramesForTop objectAtIndex:i] CGRectValue];
        [UIView animateWithDuration:1.0 animations:^(void) {
            photo.frame = f;
        }];
    }
}







//####################################################################################
//
//   DETAIL VIEW
//
//####################################################################################




- (void) gotoDetailsForMarker: (GMSMarker*) marker animated: (BOOL) animated {
    NSDictionary* location = (NSDictionary*)marker.userData;
    _selected_location = location;
    _prior_camera_pos = self.map_view.camera;

    [self populateDetailViewWithData:location];
    
    [self loadBackgroundImageList: location];
    
    [self ZommInOnMarker: marker animated: FALSE];
    
    [self showDetailsOverlay];

}



- (void) ZommInOnMarker:  (GMSMarker *)  marker animated: (BOOL) animated{
    GMSCameraPosition *new_cam;

    new_cam = [GMSCameraPosition cameraWithTarget:marker.position zoom:18 bearing:0 viewingAngle:0];
    if (animated)
        return [self animateToNewCameraPosition:new_cam];
    return [self.map_view setCamera:new_cam];
}


-(void) flyBackToMap {
    [CATransaction setValue:[NSNumber numberWithFloat: 1.0f] forKey:kCATransactionAnimationDuration];
    [self.map_view animateToCameraPosition:_prior_camera_pos];
    [CATransaction setCompletionBlock:^{}];
    [CATransaction commit];
}






- (void) showDetailsOverlay {
    //make sure its in the correct hidden position before animating
    self.detail_view.hidden = FALSE;
    self.background_layer.hidden = FALSE;
    self.detail_view.frame = CGRectOffset(self.view.frame, 0, 600);
    self.map_view.padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
    [UIView animateWithDuration:1.0 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.detail_view.frame = CGRectOffset(self.view.frame, 0, 0);
                         self.map_view.padding = UIEdgeInsetsMake(100, 0, 330.0, 0);
                     }
                     completion:^(BOOL finished){
                         [self updateDetailPageContentSize];
                     }];
}


- (void) hideDetailsOverlay {
    [UIView animateWithDuration:1.0 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.detail_view.frame = CGRectOffset(self.view.frame, 0, 600);
                         self.map_view.padding = UIEdgeInsetsMake(0, 0, 0, 0);
                         //self.scrollView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];

                     }
                     completion:^(BOOL finished){
                         self.detail_view.hidden = TRUE;
                         self.background_layer.hidden = TRUE;
                        [self flyBackToMap];
                     }];
}








- (void) toggleShowBackgroundImageOnly {
    
    //start showing just the BG
    if (showingOnlyBackgroundImage == FALSE){
        [self alignPhotosCenter];
        [UIView animateWithDuration:1.0 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.detail_view.frame = CGRectOffset(self.view.frame, 0, 250);
                             self.map_view.padding = UIEdgeInsetsMake(100, 0, 55, 0);
                         }
                         completion:^(BOOL finished){
                             showingOnlyBackgroundImage = TRUE;
                             self.detailViewTapRecognizer.enabled = TRUE;
                            
                         }];
    }
    
    //go back to normal detail view
    else {
        [self alignPhotosTop];
        self.detailViewTapRecognizer.enabled = FALSE;
        [UIView animateWithDuration:1.0 delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.detail_view.frame = CGRectOffset(self.view.frame, 0, 0);
                             self.map_view.padding = UIEdgeInsetsMake(100, 0, 330.0, 0);
                         }
                         completion:^(BOOL finished){
                             showingOnlyBackgroundImage = FALSE;

                             
                         }];
    }
}





-(void) populateDetailViewWithData: (NSDictionary*) location {
    NSString* location_id = [_selected_location objectForKey:@"id"];
    NSDictionary* favorite = [ctx.favorites objectForKey:location_id];
    if (favorite == nil){
        [self.favoriteButton setTitle:@"add-star" forState:UIControlStateNormal];
        [self.favoriteButton setImage: [UIImage imageNamed:@"btn-singleview-savespot.png"] forState:UIControlStateNormal];
        
    }
    else {
        [self.favoriteButton setTitle:@"un-star" forState:UIControlStateNormal];
        [self.favoriteButton setImage: [UIImage imageNamed:@"btn-singleview-savespot-active.png"] forState:UIControlStateNormal];
        
    }

    /*
    // TITLE LABEL ------------------------------------------------------------------------------
    NSString* tText = [NSString stringWithFormat:@"\n%@", [location objectForKey:@"name"]];
    self.detail_title.numberOfLines = 0;
    self.detail_title.backgroundColor = [UIColor clearColor];
    self.detail_title.clipsToBounds = FALSE;
    
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [titleStyle setLineHeightMultiple:0.7] ;
    self.detail_title.attributedText  = [[NSAttributedString alloc] initWithString:tText attributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:26.0],
        NSParagraphStyleAttributeName: titleStyle
    }];
    [self.detail_title sizeToFit];

    
    // DETAIL TEXT LABEL --------------------------------------------------------------------------
    NSString* dtText = [location objectForKey:@"description"];
    if ([dtText length] < 5) {
        dtText = @"Not much here - yet! Have a comment about this spot? (Tap Link Here)";
    }
    
    NSMutableParagraphStyle* detailStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [detailStyle setLineHeightMultiple:1.0] ;
    detailStyle.minimumLineHeight = 0.1;
    detailStyle.maximumLineHeight = 150;
    
    self.detail_text.attributedText  = [[NSAttributedString alloc] initWithString:dtText attributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"Avenir-Book" size:14.0],
        NSParagraphStyleAttributeName: detailStyle
    }];
    [self.detail_text sizeToFit];
    CGRect tf = self.detail_title.frame;
    CGRect f = self.detail_text.frame;
    self.detail_text.frame = CGRectOffset(self.detail_text.frame, 0, tf.size.height -50);
    
    // DETAIL VIEW CONTENT SIZE
    CGFloat content_height = f.origin.y + f.size.height;
    CGSize content_size = CGSizeMake(320.0, content_height);
    self.detail_view.contentSize = content_size;
    */
    
    

    /*NSString* embedHTML = @"<html><head></head><body><h4>Description:</h4><p>%@</p><h4>website:</h4><p><a href='%@'>%@</a></p></body></html>";
    
    embedHTML = [NSString stringWithFormat:embedHTML, dtText, [location objectForKey:@"website"], [location objectForKey:@"website"]];
    */
    

    NSString* urlString = [NSString stringWithFormat:@"http://findyouriowa.com/render/location/%@", [location objectForKey:@"id"]];
    //NSString* urlString = [NSString stringWithFormat:@"http://localhost:8000/render/location/%@", [location objectForKey:@"id"]];
    [self.detail_text loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    self.detail_text.userInteractionEnabled = NO;
    self.detail_text.opaque = NO;
    self.detail_text.backgroundColor = [UIColor clearColor];
    //[self.detail_text loadHTMLString: embedHTML baseURL: nil];
    NSInteger height = [[self.detail_text stringByEvaluatingJavaScriptFromString:
                         @" Math.max(document.body.scrollHeight, document.body.offsetHeight, document.height, document.body.clientHeight)"] integerValue];
    
    //CGRect tf = self.detail_title.frame;
    //CGRect f = self.detail_text.frame;
    //self.detail_text.frame = CGRectMake(f.origin.x, f.origin.y + tf.size.height -50, f.size.width, height+200);
    
    [self.detail_text sizeToFit];
    /*
    CGRect tf = self.detail_title.frame;
    CGRect f = self.detail_text.frame;
    self.detail_text.frame = CGRectOffset(self.detail_text.frame, 0, tf.size.height -50);
    */
    // DETAIL VIEW CONTENT SIZE
    CGRect f = self.detail_text.frame;
    CGFloat content_height = f.origin.y + f.size.height;
    CGSize content_size = CGSizeMake(320.0, content_height);
    self.detail_view.contentSize = content_size;
    

}






- (IBAction)toggleFavoriteStatus:(id)sender {
    NSString* location_id = [_selected_location objectForKey:@"id"];
    NSDictionary* favorite = [ctx.favorites objectForKey:location_id];
    if (favorite == nil){
        [ctx.favorites setObject: [NSDictionary dictionaryWithDictionary:_selected_location]
                          forKey: location_id];
        [self.favoriteButton setTitle:@"un-star" forState:UIControlStateNormal];
        [self.favoriteButton setImage: [UIImage imageNamed:@"btn-singleview-savespot-active.png"] forState:UIControlStateNormal];
    }
    else {
        [ctx.favorites removeObjectForKey:location_id];
        [self.favoriteButton setTitle:@"add-star" forState:UIControlStateNormal];
        [self.favoriteButton setImage: [UIImage imageNamed:@"btn-singleview-savespot.png"] forState:UIControlStateNormal];
    }
    [ctx saveFavorites];
}



-(void) updateDetailPageContentSize {
    CGRect f = self.detail_text.frame;
    CGFloat content_height = f.origin.y + f.size.height + 300.0;
    CGSize content_size = CGSizeMake(320.0, content_height);
    self.detail_view.contentSize = content_size;
}



@end