//
//  CategoryListController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/10/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "AppContext.h"
#import "CategoryListViewCell.h"
#import "MapViewController.h"
#import <UIKit/UIKit.h>

@interface FavoritesTableViewController ()

@property(strong, nonatomic) NSArray* categories;

@end

@implementation FavoritesTableViewController{
    AppContext* ctx;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    ctx = [AppContext instance];
    
    self.favorites = [[ctx.favorites allValues]
                       sortedArrayUsingComparator:^(NSDictionary* item1, NSDictionary* item2){
                           NSString* key1 = [item1 objectForKey:@"name"];
                           NSString* key2 = [item2 objectForKey:@"name"];
                           return [key1 compare:key2];
                       }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoritesCell";
    NSInteger idx = [indexPath row];
    NSDictionary* location = [self.favorites objectAtIndex:idx];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [location objectForKey:@"name"];
    cell.imageView.image = [ctx markerForCategory:[location objectForKey:@"category"]];
    
    return cell;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"to_main_menu"]){return;}

    
    //NSLog(@"GOTO PLACE ON MAP");
    MapViewController* map = (MapViewController*) [segue destinationViewController];
    NSInteger idx = [[self.tableView indexPathForSelectedRow] row];
    NSDictionary* location = [self.favorites objectAtIndex:idx];
     dispatch_async(dispatch_get_main_queue(), ^{
        map.selectedLocationID = [location objectForKey:@"id"];
        GMSMarker* marker = [map addLocation:location];
        [map gotoDetailsForMarker:marker animated:FALSE];
        
    });
    
    
    
}


@end
