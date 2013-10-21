//
//  FilterResultsController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/18/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "FilterResultsController.h"
#import "CategoryListViewCell.h"
#import "AppContext.h"
#import "MapViewController.h"

@interface FilterResultsController ()

@end

@implementation FilterResultsController {

    AppContext* ctx;
  
    NSArray* location_list;


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
        NSLog(@"HIDING loading indicator!!!");
        self.loadingIndicator.hidden = TRUE;
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
    
    NSLog(@"number of rows: %d", [location_list count]);

    return [location_list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger idx = [indexPath row];
    
    NSLog(@"cell #: %d", [location_list count]);
    

    
    NSDictionary* location = [location_list objectAtIndex:idx];
    static NSString *CellIdentifier = @"ResultCell";

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
    
    
    NSLog(@"GOTO PLACE ON MAP");
    MapViewController* map = (MapViewController*) [segue destinationViewController];    
    NSInteger idx = [[self.tableView indexPathForSelectedRow] row];
    NSDictionary* location = [location_list objectAtIndex:idx];
    //[map gotoDetailsForLocationWithID: [location objectForKey:@"id"]];
    //map.selectedLocation = location;
    //map.selectedLocationID = [location objectForKey:@"id"];
    dispatch_async(dispatch_get_main_queue(), ^{
        map.selectedLocationID = [location objectForKey:@"id"];
        GMSMarker* marker = [map addLocation:location];
        [map gotoDetailsForMarker:marker animated:FALSE];

    });


}






/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*

 */

@end
