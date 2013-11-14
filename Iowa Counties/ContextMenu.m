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

@interface ContextMenu ()

@end

@implementation ContextMenu {
    AppContext* ctx;
    NSArray* location_list;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.context_tab_btn.frame = CGRectMake(280,25,40,40);
    self.table_view.frame = CGRectMake(320, 0, 260, 568);
    self.table_view.dataSource = self;
    self.table_view.delegate = self;
    
    self.view.hidden = TRUE;
}



-(void) viewDidAppear:(BOOL)animated {
    [self set_hidden_state ];
    self.view.hidden = FALSE;
}


-(void) set_hidden_state {

    self.context_tab_btn.frame = CGRectMake(280,25,40,40);
    self.table_view.frame = CGRectMake(320, 0, 260, 568);
    self.backdrop.hidden = TRUE;

}


- (IBAction)tab_btn_pressed:(id)sender {
    self.is_showing = !self.is_showing;
}

-(void)setIs_showing:(BOOL)is_showing {
    NSLog(@"SETTING FROM %d  to  %d", _is_showing, is_showing);
    if(!is_showing)
        [self hide_menu];
    else if (is_showing)
        [self show_menu];
    _is_showing = is_showing;
}

- (IBAction)hide_btn_pressed:(id)sender {
    self.is_showing = FALSE;
}

-(void) show_menu {
    _is_showing = TRUE;
    NSLog(@"showing");
    
    MapViewController* map_view_ctrl = (MapViewController*) self.parentViewController;
    [self setResults: [map_view_ctrl get_visible_locations]];
    
    self.context_tab_btn.frame = CGRectMake(280,25,40,40);
    self.table_view.frame = CGRectMake(320, 0, 260, 568);
    
    //eased animations
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab_btn.frame = CGRectMake(10,25,40,40);
        self.table_view.frame = CGRectMake(60, 0, 260, 568);
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
    self.backdrop.hidden = FALSE;
    self.backdrop.alpha = 0.8;
    
    //eased animations
    [UIView animateWithDuration:1.0 animations:^(void){
        self.context_tab_btn.frame = CGRectMake(280,25,40,40);
        self.table_view.frame = CGRectMake(320, 0, 260, 568);
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([results count] > 0 ){
            location_list = [results copy];
            [self.table_view reloadData];
        }
    });

}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    return [location_list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterHeaderCell" forIndexPath:indexPath];
        //[cell.contentView.subviews objectAtIndex:0]
        return cell;
    }
    
    NSInteger idx = [indexPath row];
    NSDictionary* location = [location_list objectAtIndex:idx];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    cell.textLabel.text = [location objectForKey:@"name"];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ROW SELECTED: %d: %d", [indexPath section], [indexPath row] );
    if ([indexPath section] == 0){
        return;
    }
    
    NSInteger idx = [indexPath row];
    NSDictionary* location = [location_list objectAtIndex:idx];
    MapViewController* map_view_ctrl = (MapViewController*) self.parentViewController;
    [map_view_ctrl select_location: location];
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 0){
        return 120.0;
    }
    return 44.0;
    
}








@end
