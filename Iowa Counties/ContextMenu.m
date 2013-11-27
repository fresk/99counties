//
//  ContextMenu.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/14/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "ContextMenu.h"
#import "AppContext.h"
#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "CategoryListViewCell.h"

@interface ContextMenu ()

@end

@implementation ContextMenu {
    AppContext* ctx;
    NSArray* location_list;
    NSArray* group_list;
    MapViewController* map_view_ctrl;
    
    NSString* list_mode ;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.btn_city.frame      = CGRectMake(280,self.btn_city.frame.origin.y, 40,40);
    self.btn_county.frame    = CGRectMake(280,self.btn_county.frame.origin.y, 40,40);
    self.btn_new.frame       = CGRectMake(280,self.btn_new.frame.origin.y, 40,40);
    self.btn_popular.frame   = CGRectMake(280,self.btn_popular.frame.origin.y, 40,40);
    self.btn_proximity.frame = CGRectMake(280,self.btn_proximity.frame.origin.y, 40,40);
    self.btn_type.frame      = CGRectMake(280,self.btn_type.frame.origin.y, 40,40);
    self.context_tab_btn.frame  = CGRectMake(280,25,40,40);
    self.table_view.frame       = CGRectMake(320, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(320, 0, 260, 120);
    self.table_view.dataSource = self;
    self.table_view.delegate = self;
    [self hideFilterButtons ];
    
    
    self.view.hidden = TRUE;
    ctx = [AppContext instance];
    list_mode = @"locations";

}



-(void) hideFilterButtons {

    self.btn_city.alpha      = 0;
    self.btn_new.alpha       = 0;
    self.btn_county.alpha    = 0;
    self.btn_popular.alpha   = 0;
    self.btn_proximity.alpha = 0;
    self.btn_type.alpha      = 0;

}


-(void) showFilterButtons {
    
    self.btn_city.alpha      = 1.0;
    self.btn_county.alpha      = 1.0;
    self.btn_new.alpha       = 1.0;
    self.btn_popular.alpha   = 1.0;
    self.btn_proximity.alpha = 1.0;
    self.btn_type.alpha      = 1.0;
    
}


-(void) viewDidAppear:(BOOL)animated {
    [self set_hidden_state ];
    self.view.hidden = FALSE;
    map_view_ctrl = (MapViewController*) self.parentViewController;
}


-(void) set_hidden_state {

    self.context_tab_btn.frame = CGRectMake(280,25,40,40);
    self.table_view.frame = CGRectMake(320, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(320, 0, 260, 120);
    self.backdrop.hidden = TRUE;
    
    [self hideFilterButtons ];
    
    self.btn_city.frame      = CGRectMake(280,self.btn_city.frame.origin.y, 40,40);
    self.btn_county.frame    = CGRectMake(280,self.btn_county.frame.origin.y, 40,40);
    self.btn_new.frame       = CGRectMake(280,self.btn_new.frame.origin.y, 40,40);
    self.btn_popular.frame   = CGRectMake(280,self.btn_popular.frame.origin.y, 40,40);
    self.btn_proximity.frame = CGRectMake(280,self.btn_proximity.frame.origin.y, 40,40);
    self.btn_type.frame      = CGRectMake(280,self.btn_type.frame.origin.y, 40,40);
}



-(void)setIs_showing:(BOOL)is_showing {
    NSLog(@"SETTING FROM %d  to  %d", _is_showing, is_showing);
    if(!is_showing)
        [self hide_menu];
    else if (is_showing)
        [self show_menu];
    _is_showing = is_showing;
}


-(void) show_menu {
    _is_showing = TRUE;
    NSLog(@"showing");
    
    //MapViewController* map_view_ctrl = (MapViewController*) self.parentViewController;
    [self setResults: [map_view_ctrl get_visible_locations]];
    
    self.context_tab_btn.frame = CGRectMake(280,25,40,40);
    self.table_view.frame = CGRectMake(320, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(320, 0, 260, 120);
    
    self.btn_city.frame      = CGRectMake(280,self.btn_city.frame.origin.y, 40,40);
    self.btn_county.frame    = CGRectMake(280,self.btn_county.frame.origin.y, 40,40);
    self.btn_new.frame       = CGRectMake(280,self.btn_new.frame.origin.y, 40,40);
    self.btn_popular.frame   = CGRectMake(280,self.btn_popular.frame.origin.y, 40,40);
    self.btn_proximity.frame = CGRectMake(280,self.btn_proximity.frame.origin.y, 40,40);
    self.btn_type.frame      = CGRectMake(280,self.btn_type.frame.origin.y, 40,40);
    [self hideFilterButtons ];

    
    //eased animations
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab_btn.frame = CGRectMake(10,25,40,40);
        self.table_view.frame = CGRectMake(60, 0, 260, 568);
        self.filter_header_image.frame = CGRectMake(60, 0, 260, 120);
        self.btn_city.frame      = CGRectMake(10,self.btn_city.frame.origin.y, 40,40);
        self.btn_county.frame    = CGRectMake(10,self.btn_county.frame.origin.y, 40,40);
        self.btn_new.frame       = CGRectMake(10,self.btn_new.frame.origin.y, 40,40);
        self.btn_popular.frame   = CGRectMake(10,self.btn_popular.frame.origin.y, 40,40);
        self.btn_proximity.frame = CGRectMake(10,self.btn_proximity.frame.origin.y, 40,40);
        self.btn_type.frame      = CGRectMake(10,self.btn_type.frame.origin.y, 40,40);
        [self showFilterButtons];
        
        
    }];
    
    //linear animation
    self.backdrop.hidden = FALSE;
    self.backdrop.alpha = 0.0;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         self.backdrop.alpha = 0.8;
                     }
                     completion:^(BOOL finished) {}];
};


-(void) hide_menu {
    _is_showing = FALSE;
    NSLog(@"hiding");
    
    self.context_tab_btn.frame = CGRectMake(10,25,40,40);
    self.table_view.frame = CGRectMake(60, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(60, 0, 260, 120);
    self.backdrop.hidden = FALSE;
    self.backdrop.alpha = 0.8;
    
    [self showFilterButtons];
    
    self.btn_city.frame      = CGRectMake(10,self.btn_city.frame.origin.y, 40,40);
    self.btn_county.frame    = CGRectMake(10,self.btn_county.frame.origin.y, 40,40);
    self.btn_new.frame       = CGRectMake(10,self.btn_new.frame.origin.y, 40,40);
    self.btn_popular.frame   = CGRectMake(10,self.btn_popular.frame.origin.y, 40,40);
    self.btn_proximity.frame = CGRectMake(10,self.btn_proximity.frame.origin.y, 40,40);
    self.btn_type.frame      = CGRectMake(10,self.btn_type.frame.origin.y, 40,40);
    
    //eased animations
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab_btn.frame = CGRectMake(280,25,40,40);
        self.table_view.frame = CGRectMake(320, 0, 260, 568);
        self.filter_header_image.frame = CGRectMake(320, 0, 260, 120);
        
        self.btn_city.frame      = CGRectMake(280,self.btn_city.frame.origin.y, 40,40);
        self.btn_county.frame    = CGRectMake(280,self.btn_county.frame.origin.y, 40,40);
        self.btn_new.frame       = CGRectMake(280,self.btn_new.frame.origin.y, 40,40);
        self.btn_popular.frame   = CGRectMake(280,self.btn_popular.frame.origin.y, 40,40);
        self.btn_proximity.frame = CGRectMake(280,self.btn_proximity.frame.origin.y, 40,40);
        self.btn_type.frame      = CGRectMake(280,self.btn_type.frame.origin.y, 40,40);
        
        [self hideFilterButtons];
    }];
    
    //linear animations
    [UIView animateWithDuration:1.0 delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         self.backdrop.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.backdrop.hidden = TRUE;
                     }];
};



- (void) setResults: (NSArray*) results {
    NSLog(@"setting results");
    list_mode = @"locations";
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([results count] > 0 ){
            location_list = [results copy];
            [self.table_view reloadData];

        }
    });
    
}



- (void) setGroups: (NSArray*) results {
    NSLog(@"setting results");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([results count] > 0 ){
            group_list = [results copy];
            [self.table_view reloadData];
        }
    });
    
}



- (IBAction)tab_btn_pressed:(id)sender {
    self.is_showing = !self.is_showing;
}


- (IBAction)filter_proximity:(id)sender {
    self.filter_header_image.image = [UIImage imageNamed:@"filter-byproximity"];
    [map_view_ctrl gotoLocationandNearby];
    
    CLLocationCoordinate2D cloc = [map_view_ctrl get_current_location];
    [ctx fetchResources:@"/nearby"
             withParams:@{
                          @"lat": [NSNumber numberWithDouble: cloc.latitude],
                          @"lng": [NSNumber numberWithDouble: cloc.longitude]
                          }
            setResultOn: self];
    
}


- (IBAction)filter_popular:(id)sender {
    self.filter_header_image.image = [UIImage imageNamed:@"filter-bypopularity"];
    [ctx fetchResource:@"/popular/" withParams:nil onComplete:^(NSDictionary* data){
        
        [self setResults: [data objectForKey:@"result"]];
        [map_view_ctrl setResults:[data objectForKey:@"result"]];
    }];
    
}


- (IBAction)filter_newest:(id)sender {
    
    NSLog(@"FILTER BY NEWEST");
    self.filter_header_image.image = [UIImage imageNamed:@"filter-byrecent"];
    [ctx fetchResource:@"/recent/" withParams:nil onComplete:^(NSDictionary* data){
        
        [self setResults: [data objectForKey:@"result"]];
        [map_view_ctrl setResults:[data objectForKey:@"result"]];
    }];
    
}


- (IBAction)filter_type:(id)sender {
    list_mode = @"category";
    self.filter_header_image.image = [UIImage imageNamed:@"filter-bytype"];
    NSArray* categories = [[ctx.categories allValues]
                           sortedArrayUsingComparator:^(NSDictionary* item1, NSDictionary* item2){
                               NSString* key1 = [item1 objectForKey:@"name"];
                               NSString* key2 = [item2 objectForKey:@"name"];
                               return [key1 compare:key2];
                           }];
    [self setGroups: categories];
}


- (IBAction)filter_city:(id)sender {

    list_mode = @"city";
    self.filter_header_image.image = [UIImage imageNamed:@"filter-bycity"];
    NSArray* cities = [ctx.cities sortedArrayUsingComparator:^(NSDictionary* item1, NSDictionary* item2){
        NSString* key1 = [item1 objectForKey:@"name"];
        NSString* key2 = [item2 objectForKey:@"name"];
        return [key1 compare:key2];
    }];
    [self setGroups: cities];
    
}


- (IBAction)filter_county:(id)sender {
    
    list_mode = @"county";
    self.filter_header_image.image = [UIImage imageNamed:@"filter-bycounty"];
    NSArray* counties = [[ctx.counties allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self setGroups: counties];
}











- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    if ([list_mode isEqualToString:@"locations"])
        return [location_list count];
    return [group_list count];
}





-(UITableViewCell*) groupCellForIndexPath: (NSIndexPath *)indexPath{
    NSInteger idx = [indexPath row];
    
    if ([list_mode isEqualToString:@"category"]){
        UITableViewCell* cell = [self.table_view dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
        NSDictionary* cat = [group_list objectAtIndex: idx];
        cell.textLabel.text = [cat objectForKey:@"name"];
        //cell.markerImage.image = [ctx markerForCategoryID:[cat objectForKey:@"id"]];
        //cell.countLabel.text = [NSString stringWithFormat:@"(%@)", [cat objectForKey:@"num_entries"]];
        return cell;
    }
    
    if ([list_mode isEqualToString:@"city"]){
        NSDictionary* city = [group_list objectAtIndex: idx];
        UITableViewCell* cell = [self.table_view dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
        cell.textLabel.text = [city objectForKey:@"name"];
        //cell.detailTextLabel.text = [city objectForKey:@"num_entries"];
        return cell;
    }
    
    if ([list_mode isEqualToString:@"county"]){
        NSString* county = [group_list objectAtIndex: idx];
        UITableViewCell* cell = [self.table_view dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
        //cell.textLabel.text = [[ctx.counties objectForKey: county] objectForKey:@"name"];
        return cell;
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterHeaderCell" forIndexPath:indexPath];
        //[cell.contentView.subviews objectAtIndex:0]
        return cell;
    }
    

    UITableViewCell *cell;
    if ([list_mode isEqualToString:@"locations"]){
        NSInteger idx = [indexPath row];
        NSDictionary* location = [location_list objectAtIndex:idx];
        UITableViewCell * cell = [self.table_view dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];
        cell.textLabel.text = [location objectForKey:@"name"];
        //cell.markerImage.image = [ctx markerForCategory:[location objectForKey:@"category"]];
        return cell;
    }

        return[self groupCellForIndexPath: indexPath];
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ROW SELECTED: %d: %d", [indexPath section], [indexPath row] );
    if ([indexPath section] == 0){
        return;
    }
    
    NSInteger idx = [indexPath row];
    
    if ([list_mode isEqualToString:@"locations"]){
        NSDictionary* location = [location_list objectAtIndex:idx];
        [map_view_ctrl select_location: location];
        return;
    }
    
    if ([list_mode isEqualToString:@"category"]){
        NSDictionary* cat = [group_list objectAtIndex:idx];
        NSString* cat_id = [cat objectForKey:@"id"];
        [ctx fetchResource:@"/locations" withParams:@{@"category":cat_id} onComplete:^(NSDictionary *data) {
            [self setResults: [data objectForKey:@"result"]];
        }];
    }
    
    if ([list_mode isEqualToString:@"city"]){
        NSDictionary* city = [group_list objectAtIndex:idx];
        [ctx fetchResource:@"/locations" withParams:@{@"city":[city objectForKey:@"name"]} onComplete:^(NSDictionary *data) {
            [self setResults: [data objectForKey:@"result"]];
        }];
    }
    
    
    if ([list_mode isEqualToString:@"county"]){
        NSString* county_id = [group_list objectAtIndex:idx];
        NSString* county_name = [[ctx.counties objectForKey:county_id] objectForKey:@"name"];
        [ctx fetchResource:@"/locations" withParams: @{@"county": county_name } onComplete:^(NSDictionary *data) {
            [self setResults: [data objectForKey:@"result"]];
        }];
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 0){
        return 120.0;
    }
    return 44.0;
    
}








@end
