//
//  CategoryListController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/10/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "CategoryListController.h"
#import "AppContext.h"
#import "CategoryListViewCell.h"
#import <UIKit/UIKit.h>

@interface CategoryListController ()

@property(strong, nonatomic) NSArray* category_ids;
@property(strong, nonatomic) NSArray* category_names;

@end

@implementation CategoryListController{
    AppContext* ctx;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    ctx = [AppContext instance];

    self.category_ids =  [[ctx.locationCategories allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.category_names = [ctx.locationCategories objectsForKeys:self.category_ids notFoundMarker:[NSNull null]];
    
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
    return [self.category_names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"category_cell_id";
    NSInteger idx = [indexPath row];
    
    NSString* cat_id = [self.category_ids objectAtIndex:idx];
    NSString* cat_name = [self.category_names objectAtIndex:idx];
    
    
    CategoryListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.titleField.text = cat_name;
    cell.markerImage.image = [ctx markerForCategoryID:cat_id];
    
    // Configure the cell...
    
    return cell;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    NSInteger idx = [[self.tableView indexPathForSelectedRow] row];
    NSString* cat_id = [self.category_ids objectAtIndex:idx];
    NSLog(@"request data by category: %@", cat_id);
    
    
    FilterResultsController* target = [segue destinationViewController];
    target.loadingIndicator.hidden = FALSE;
    [ctx fetchResources:@"/locations" withParams:nil setResultOn: target];

    
}


@end
