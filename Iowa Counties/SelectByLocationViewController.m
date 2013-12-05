//
//  SelectTypeGenius.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 12/3/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//


#import "SelectByLocationViewController.h"
#import "AppContext.h"
#import "Utils.h"
#import "ContextMenu.h"

@interface SelectByLocationViewController ()

@end

@implementation SelectByLocationViewController {
    AppContext* ctx;
    ContextMenu* parent_menu;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    ctx = [AppContext instance];
}



-(void) viewDidAppear:(BOOL)animated {
    parent_menu = (ContextMenu*) self.parentViewController;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[ctx cities] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    //cell.textLabel.text = name;

    
    // Configure the cell...
    cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* cat = [[ctx cities] objectAtIndex: [indexPath row]];
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
