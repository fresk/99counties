//
//  CategoryListController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/10/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "CountyListController.h"
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
    NSLog(@"number of items in table:  %d", [ctx.counties count]);
    return [ctx.counties count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger idx = [indexPath row];
    NSString* county_id = [county_ids objectAtIndex:idx];
    
    cell.textLabel.text = [[ctx.counties objectForKey:county_id] objectForKey:@"name"];
    return cell;
}


 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
     NSInteger idx = [[self.tableView indexPathForSelectedRow] row];
     NSString* county_id = county_ids[idx];
     NSLog(@"request data by county: %@", county_id);
     [ctx fetchResources:@"/locations" withParams:nil setResultOn: [segue destinationViewController]];
    //[ctx loadLocationsWhere:@"county" Matches:county_id intoTable:[segue destinationViewController]];

 }
 


@end
