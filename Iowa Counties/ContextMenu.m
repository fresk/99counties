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
#import "SelectTypeGenius.h"

@interface ContextMenu ()

@end

@implementation ContextMenu {
    AppContext* ctx;
    NSArray* location_list;
    NSArray* group_list;
    MapViewController* map_view_ctrl;
    
    NSString* list_mode ;
    
    NSArray* filter_buttons;
    
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.context_tab_btn.frame  = CGRectMake(280,25,40,40);
    self.table_view.frame       = CGRectMake(320, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(320, 0, 260, 120);
    self.table_view.dataSource = self;
    self.table_view.delegate = self;
    [self hideFilterButtons];

    self.view.hidden = TRUE;
    ctx = [AppContext instance];
    list_mode = @"locations";

}


-(void) viewDidAppear:(BOOL)animated {
    [self set_hidden_state ];
    self.view.hidden = FALSE;
    map_view_ctrl = (MapViewController*) self.parentViewController;
    
}



-(void) hideFilterButtons {
    filter_buttons = [[NSArray alloc] initWithObjects: self.btn_city, self.btn_proximity, self.btn_type, nil];
    
    for (UIView* btn in filter_buttons) {
        btn.alpha = 0;
        btn.frame = CGRectMake(280,btn.frame.origin.y, 40,40);
    }
    
    self.context_tab_btn.frame = CGRectMake(280,25,40,40);
    self.context_tab_btn_close.frame  = CGRectMake(280,25,40,40);

    self.context_tab_btn.alpha = 1.0;
    self.context_tab_btn_close.alpha = 0.0;
    
    self.context_tab_btn.userInteractionEnabled = TRUE;
    self.context_tab_btn_close.userInteractionEnabled = FALSE;
    
    self.table_view.frame = CGRectMake(320, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(320, 0, 260, 120);
}


-(void) showFilterButtons {
    filter_buttons = [[NSArray alloc] initWithObjects: self.btn_city, self.btn_proximity, self.btn_type, nil];
    
    for (UIView* btn in filter_buttons) {
        btn.alpha = 0.7;
        btn.frame = CGRectMake(10,btn.frame.origin.y, 40,40);
    }
    
    self.context_tab_btn.frame = CGRectMake(10,25,40,40);
    self.context_tab_btn_close.frame  = CGRectMake(10,25,40,40);
    
    self.context_tab_btn.alpha = 0.0;
    self.context_tab_btn_close.alpha = 1.0;
    
 
    self.context_tab_btn.userInteractionEnabled = FALSE;
    self.context_tab_btn_close.userInteractionEnabled = TRUE;

    self.table_view.frame = CGRectMake(60, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(60, 0, 260, 120);
}




-(void) set_hidden_state {
    //self.context_tab_btn.imageView.image = [UIImage imageNamed:@"filterbtn-main"];
    self.table_view.frame = CGRectMake(320, 0, 260, 568);
    self.filter_header_image.frame = CGRectMake(320, 0, 260, 120);
    self.backdrop.hidden = TRUE;
    [self hideFilterButtons ];
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
    [self hideFilterButtons ];
    
    self.backdrop.hidden = FALSE;
    self.context_tab_btn.hidden = FALSE;
    self.context_tab_btn_close.hidden = FALSE;
    self.context_tab_btn.userInteractionEnabled = FALSE;
    self.context_tab_btn_close.userInteractionEnabled = FALSE;
    
    //eased animations
    [UIView animateWithDuration:1.0 animations:^(void){
        [self showFilterButtons];
    }];
    
    
    [UIView animateWithDuration:1.0 delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         [self showFilterButtons];
                     }
                     completion:^(BOOL finished) {

                     }];
    

    //linear animation
    self.backdrop.alpha = 0.0;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                         self.backdrop.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    

};


-(void) hide_menu {
    _is_showing = FALSE;
    NSLog(@"hiding");
    
    [self showFilterButtons];


    self.backdrop.hidden = FALSE;
    self.context_tab_btn.hidden = FALSE;
    self.context_tab_btn_close.hidden = FALSE;
    self.context_tab_btn.userInteractionEnabled = FALSE;
    self.context_tab_btn_close.userInteractionEnabled = FALSE;
    
    //eased animations

    [UIView animateWithDuration:1.0 delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         [self hideFilterButtons];
                     }
                     completion:^(BOOL finished) {
                         self.context_tab_btn.hidden = FALSE;
                         self.context_tab_btn.alpha =1.0;
                         self.context_tab_btn_close.hidden = TRUE;
                         self.context_tab_btn_close.alpha = 0.0;
                         self.context_tab_btn.userInteractionEnabled = TRUE;
                         self.context_tab_btn_close.userInteractionEnabled = FALSE;
                         [self hideFilterButtons];
                     }];
    [self hideFilterButtons];
    //linear animations
    self.backdrop.alpha = 1.0;
    [UIView animateWithDuration:1.0 delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(void){
                            self.backdrop.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.backdrop.hidden = TRUE;
                     }];
    

};

- (IBAction)tab_btn_pressed:(id)sender {
    self.is_showing = !self.is_showing;
}

- (IBAction)tab_btn_close_pressed:(id)sender {
    self.is_showing = !self.is_showing;
}






- (void)selectCategory: (NSString*) category_id {

}




- (void) setResults: (NSArray*) results {
    NSLog(@"setting results");
    list_mode = @"locations";
    //dispatch_async(dispatch_get_main_queue(), ^{
    if ([results count] > 0 ){
        location_list = results;
        [self.table_view reloadData];
        [map_view_ctrl setResults: results];
    }
    
}


- (void) overwriteResults: (NSArray*) results {
    NSLog(@"setting results");
    list_mode = @"locations";
    //dispatch_async(dispatch_get_main_queue(), ^{
    if ([results count] > 0 ){
        location_list = results;
        [self.table_view reloadData];
        //[map_view_ctrl setResults: results];
    }
    
}


- (void) setGroups: (NSArray*) results {
    NSLog(@"setting results");
    //dispatch_async(dispatch_get_main_queue(), ^{
    if ([results count] > 0 ){
        group_list = [results copy];
        [self.table_view reloadData];
    }
    //});
    
}









-(void) fadeHeaderImageTo:(NSString*) newHeader {
    
    UIImage * toImage = [UIImage imageNamed:newHeader];
    [UIView transitionWithView:self.filter_header_image
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.filter_header_image.image = toImage;
                    } completion:nil];
    
}


-(NSArray*) getFilterButtons{
    return [[NSArray alloc] initWithObjects: self.btn_city, self.btn_proximity, self.btn_type, nil];
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
        cell.textLabel.text = [[ctx.counties objectForKey: county] objectForKey:@"name"];
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
        UITableViewCell * cell = [self.table_view dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
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
        NSString* cat = [[group_list objectAtIndex:idx] objectForKey:@"id"];
        [self setResults: [ctx getLocationsByCategory: cat ]];
        NSString* filter_img = [NSString stringWithFormat:@"filter-header-%@", cat];
        [self fadeHeaderImageTo:filter_img];
        //[ctx fetchResource:@"/locations" withParams:@{@"category":cat_id} onComplete:^(NSDictionary *data) {
        //    [self setResults: [data objectForKey:@"result"]];
        //}];
    }
    
    if ([list_mode isEqualToString:@"city"]){
        NSString* city = [[group_list objectAtIndex:idx] objectForKey:@"name"];
        NSLog(@"SELECTED CITY: %@", city);
        [self setResults:[ctx getLocationsByCity:city ]];
        
        /*[ctx fetchResource:@"/locations" withParams:@{@"city":[city objectForKey:@"name"]} onComplete:^(NSDictionary *data) {
            [self setResults: [data objectForKey:@"result"]];
        }];
         */
    }
    
    /*
    if ([list_mode isEqualToString:@"county"]){
        NSString* county_id = [group_list objectAtIndex:idx];
        NSString* county_name = [[ctx.counties objectForKey:county_id] objectForKey:@"name"];
        [ctx fetchResource:@"/locations" withParams: @{@"county": county_name } onComplete:^(NSDictionary *data) {
            [self setResults: [data objectForKey:@"result"]];
        }];
    }
     */
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 0){
        return 120.0;
    }
    return 44.0;
    
}










- (IBAction)filter_type:(id)sender {
    list_mode = @"category";
    //self.filter_header_image.image = [UIImage imageNamed:@"filter-bytype"];
    //[self fadeHeaderImageTo: @"filter-bytype"];
    NSArray* categories = [[ctx.categories allValues]
                           sortedArrayUsingComparator:^(NSDictionary* item1, NSDictionary* item2){
                               NSString* key1 = [item1 objectForKey:@"name"];
                               NSString* key2 = [item2 objectForKey:@"name"];
                               return [key1 compare:key2];
                           }];
    //[self setGroups: categories];
    
    filter_buttons = [self getFilterButtons];
    for (UIView* btn in filter_buttons) {
        btn.alpha = 0.7;
    }
    self.btn_type.alpha = 1.0;
    
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"genius" bundle:nil];
    UIViewController* type_selection_view = [sb instantiateViewControllerWithIdentifier:@"TypeSelection"];
    [self addChildViewController:type_selection_view];
    [self.overlay addSubview:type_selection_view.view];
    
    type_selection_view.view.alpha = 0.0;
    [UIView animateWithDuration:0.8
                     animations:^{type_selection_view.view.alpha = 1.0;}
                     completion:^(BOOL finished){}];
    
}

- (IBAction)filter_city:(id)sender {
    
    list_mode = @"city";
    //self.filter_header_image.image = [UIImage imageNamed:@"filter-bycity"];
    [self fadeHeaderImageTo: @"filter-bycity"];
    NSArray* cities = [ctx.cities sortedArrayUsingComparator:^(NSDictionary* item1, NSDictionary* item2){
        NSString* key1 = [item1 objectForKey:@"name"];
        NSString* key2 = [item2 objectForKey:@"name"];
        return [key1 compare:key2];
    }];
    [self setGroups: cities];
    
    filter_buttons = [self getFilterButtons];
    for (UIView* btn in filter_buttons) {
        btn.alpha = 0.7;
    }
    self.btn_city.alpha = 1.0;
    
}

- (IBAction)filter_proximity:(id)sender {
    //self.filter_header_image.image = [UIImage imageNamed:@"filter-byproximity"];
    [self fadeHeaderImageTo: @"filter-byproximity"];
    
    [map_view_ctrl gotoLocationandNearby];
    
    filter_buttons = [self getFilterButtons];
    for (UIView* btn in filter_buttons) {
        btn.alpha = 0.7;
    }
    self.btn_proximity.alpha = 1.0;
}


















@end
