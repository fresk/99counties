//
//  ContextList.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/13/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface ContextList : UITableViewController

@property BOOL isHidden;

@property (strong, atomic) MapViewController* parent_controller;


-(void)setResults: (NSArray*) results;


@end
