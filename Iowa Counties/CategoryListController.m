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

@property(strong, nonatomic) NSArray* categories;

@end

@implementation CategoryListController{
    AppContext* ctx;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    ctx = [AppContext instance];

    self.categories = [[ctx.categories allValues]
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
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"category_cell_id";
    NSInteger idx = [indexPath row];
    
    NSDictionary* cat = [self.categories objectAtIndex:idx];
    
    
    CategoryListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.titleField.text = [cat objectForKey:@"name"];
    cell.markerImage.image = [ctx markerForCategoryID:[cat objectForKey:@"id"]];
    cell.countLabel.text = [NSString stringWithFormat:@"(%@)", [cat objectForKey:@"num_entries"]];
    
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
    NSDictionary* cat = [self.categories objectAtIndex:idx];
    
    NSString* cat_id = [cat objectForKey:@"id"];
    NSLog(@"request data by category: %@", cat_id);
    
    
    FilterResultsController* target = [segue destinationViewController];
    target.loadingIndicator.hidden = FALSE;
    [ctx fetchResources:@"/locations" withParams:@{@"category":cat_id} setResultOn: target];

    
}


@end
