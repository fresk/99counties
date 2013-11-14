//
//  ContextList.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/13/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "ContextList.h"
#import "AppContext.h"


@interface ContextList ()

@end

@implementation ContextList {
    AppContext* ctx;
    NSArray* location_list;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ctx = [AppContext instance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //if ([location_list count] > 0){
    //    [self.tableView reloadData ];
    //    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationRight];
    // }
}






- (void) setResults: (NSArray*) results
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([results count] > 0 ){
            location_list = [results copy];
            [self.tableView reloadData];
            //NSLog(@"HIDING loading indicator!!!");
            //self.loadingIndicator.hidden = TRUE;
        }
    });
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationRight];
}








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //NSLog(@"number of rows: %d", [location_list count]);
    
    return [location_list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idx = [indexPath row];
    
    //NSLog(@"cell #: %d", [location_list count]);
    
    
    
    NSDictionary* location = [location_list objectAtIndex:idx];

    UITableViewCell* cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cell"];
    cell.textLabel.text = [location objectForKey:@"name"];
    cell.imageView.image = [ctx markerForCategory:[location objectForKey:@"category"]];
    
    return cell;
}






@end
