//
//  CategoryListViewController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/10/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "ExploreViewController.h"
#import "AppContext.h"
#import "CategoryListViewCell.h"

@interface ExploreViewController ()

@property(strong, nonatomic) NSArray* category_ids;
@property(strong, nonatomic) NSArray* category_names;

@end

@implementation ExploreViewController{
    AppContext* ctx;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"to_main_menu"]){return;}
    
    
    NSInteger idx = [[self.tableView indexPathForSelectedRow] row];
    //NSLog(@"navigate: %@", segue.identifier);
    

    if ([segue.identifier isEqualToString:@"showRecentlyAdded"]){
        //[ctx fetchResources:@"/recent" withParams:nil setResultOn:target];
        FilterResultsController* target = [segue destinationViewController];
        target.loadingIndicator.hidden = FALSE;
        [ctx fetchResources:@"/recent/" withParams:nil setResultOn: target];
        
    }
    
    else if ([segue.identifier isEqualToString:@"showPopular"]){
        //[ctx fetchResources:@"/popular" withParams:nil setResultOn:target];
        FilterResultsController* target = [segue destinationViewController];
        target.loadingIndicator.hidden = FALSE;
        [ctx fetchResources:@"/locations/" withParams:nil setResultOn: target];
    }
    
    else if ([segue.identifier isEqualToString:@"showProximity"]){
        FilterResultsController* target = [segue destinationViewController];
        target.loadingIndicator.hidden = FALSE;
        CLLocationCoordinate2D cloc = [ctx getCurrentLocation];
        [ctx fetchResources:@"/nearby"
                  withParams:@{
                              @"lat": [NSNumber numberWithDouble: cloc.latitude],
                              @"lng": [NSNumber numberWithDouble: cloc.longitude]
                              }
                setResultOn: target];
    }
    
    else {
        return;
    }
    
    
    

    
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



@end
