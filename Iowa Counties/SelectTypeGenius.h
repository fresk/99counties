//
//  SelectTypeGenius.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 12/3/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectTypeGenius : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
