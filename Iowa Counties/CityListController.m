//
//  CityListController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/10/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "CityListController.h"
#import "AppContext.h"
#import "CategoryListViewCell.h"
#import <UIKit/UIKit.h>

@interface CityListController ()

@property(strong, nonatomic) NSArray* cities;

@end

@implementation CityListController{
    AppContext* ctx;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    ctx = [AppContext instance];
    
    self.cities = [ctx.cities sortedArrayUsingComparator:^(NSDictionary* item1, NSDictionary* item2){
        NSString* key1 = [item1 objectForKey:@"name"];
        NSString* key2 = [item2 objectForKey:@"name"];
        return [key1 compare:key2];
    }];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CityCell";
    NSInteger idx = [indexPath row];
    
    NSDictionary* city = [self.cities objectAtIndex:idx];
    
    
    CategoryListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.titleField.text = [city objectForKey:@"name"];
    //cell.markerImage.image = [ctx markerForCategoryID:[city objectForKey:@"id"]];
    cell.countLabel.text = [NSString stringWithFormat:@"(%@)", [city objectForKey:@"num_entries"]];
    
    // Configure the cell...
    
    return cell;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"to_main_menu"]){return;}
    
    
    // Get the new view controller using [segue destinationViewController].
    NSInteger idx = [[self.tableView indexPathForSelectedRow] row];
    NSDictionary* city = [self.cities objectAtIndex:idx];

    
    FilterResultsController* target = [segue destinationViewController];
    target.loadingIndicator.hidden = FALSE;
    
    [ctx fetchResources:@"/locations" withParams:@{@"city":[city objectForKey:@"name"]} setResultOn: target];
    
    
}


@end
