//
//  FilterResultsController.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/18/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterResultsController : UITableViewController
@property(atomic, strong) NSString* result_category;

- (void) setResults: (NSArray*) results;
@end
