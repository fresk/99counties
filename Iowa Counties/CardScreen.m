//
//  CardScreen.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/7/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "CardScreen.h"

@interface CardScreen ()
@property (strong, nonatomic) IBOutlet UIButton *title;

@end

@implementation CardScreen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setData:(NSDictionary*) data {
    self.title.titleLabel.text = [data objectForKey:@"name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
