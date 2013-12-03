//
//  SelectTypeGenius.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 12/3/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//


#import "SelectTypeGenius.h"
#import "AppContext.h"
#import "Utils.h"
#import "ContextMenu.h"

@interface SelectTypeGenius ()

@end

@implementation SelectTypeGenius {

    NSArray* categories;
    AppContext* ctx;
    ContextMenu* parent_menu;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    ctx = [AppContext instance];
    categories = [[ctx.categories allValues] sortedArrayUsingComparator:^(NSDictionary* item1, NSDictionary* item2){
                               NSString* key1 = [item1 objectForKey:@"name"];
                               NSString* key2 = [item2 objectForKey:@"name"];
                               return [key1 compare:key2];
    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



-(void) viewDidAppear:(BOOL)animated {

    parent_menu = (ContextMenu*) self.parentViewController;

}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TypeSelection";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary* cat = [categories objectAtIndex: [indexPath row]];
    NSString* color = [[ctx.categoryNames objectForKey: [cat objectForKey:@"id"]] objectForKey:@"color"];
    NSString* name =  [[ctx.categoryNames objectForKey: [cat objectForKey:@"id"]] objectForKey:@"name"];
    cell.textLabel.text = name;
    cell.backgroundColor = [UIColor pxColorWithHexValue:color];

    // Configure the cell...
    cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* cat = [categories objectAtIndex: [indexPath row]];
    NSLog(@"selected category: %@", [cat objectForKey:@"id"]);
    [parent_menu setResults:[ctx getLocationsByCategory:[cat objectForKey:@"id"]]];

     
     [UIView animateWithDuration:0.5
                      animations:^{self.view.alpha = 0.0;}
                      completion:^(BOOL finished){ [self.view removeFromSuperview]; }];
     
     [self removeFromParentViewController];
}





- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0;
}



@end
