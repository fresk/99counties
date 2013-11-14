//
//  DetailView.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/13/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "DetailView.h"

@interface DetailView ()

@end

@implementation DetailView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self set_location: nil];
    // Do any additional setup after loading the view from its nib.
}




- (void) set_location: (NSDictionary* )location {
    NSString* urlString = @"http://localhost:8000/render/location/5257141509c6187dcc3bdb16";
    //NSString* urlString = [NSString stringWithFormat:@"http://localhost:8000/render/location/%@", [location objectForKey:@"id"]];
    [self.web_view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    self.web_view.userInteractionEnabled = NO;
    self.web_view.opaque = NO;
    self.web_view.backgroundColor = [UIColor clearColor];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
