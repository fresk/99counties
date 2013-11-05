//
//  CategoryListController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/10/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "CountyListController.h"
#import "CategoryListViewCell.h"
#import "FilterResultsController.h"
#import "AppContext.h"
#import <UIKit/UIKit.h>

@interface CountyListController ()

@property(strong, nonatomic) NSArray* category_ids;
@property(strong, nonatomic) NSArray* category_names;

@end

@implementation CountyListController{
    AppContext* ctx;
    NSArray* county_ids;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ctx = [AppContext instance];
    county_ids  = [[ctx.counties allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"number of items in table:  %d", [ctx.counties count]);
    return [ctx.counties count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CountyCell";
    CategoryListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger idx = [indexPath row];
    NSString* county_id = [county_ids objectAtIndex:idx];
    
    cell.titleField.text  = [[ctx.counties objectForKey:county_id] objectForKey:@"name"];
    cell.countLabel.text = [NSString stringWithFormat:@""];
    return cell;
}


 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"to_main_menu"]){return;}
     
     
//  Get the new view controller using [segue destinationViewController].
     NSInteger idx = [[self.tableView indexPathForSelectedRow] row];
     NSString* county_id = county_ids[idx];
     //NSLog(@"request data by county: %@", county_id);
     FilterResultsController* target = [segue destinationViewController];
     target.loadingIndicator.hidden = FALSE;
     NSString* county_name = [[ctx.counties objectForKey:county_id] objectForKey:@"name"];
     [ctx fetchResources:@"/locations" withParams: @{@"county": county_name } setResultOn: target];
}
 


@end
