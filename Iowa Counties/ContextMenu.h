//
//  ContextMenu.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/14/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContextMenu : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL is_showing;

@property (strong, nonatomic) IBOutlet UITableView *table_view;
@property (strong, nonatomic) IBOutlet UIButton *context_tab_btn;
@property (strong, nonatomic) IBOutlet UIView *backdrop;


-(void) set_hidden_state;

@end
