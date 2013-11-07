//
//  MainMenuViewController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/6/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "MainMenuViewController.h"
#import "FilterResultsController.h"
#import "ExploreViewController.h"
#import "AppContext.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController{
    AppContext* ctx;
}

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
    ctx = [AppContext instance];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)gotoCardScreen:(id)sender {

    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Cards" bundle:nil];
    
    UIViewController *initViewController = [storyBoard instantiateInitialViewController];
    
    [self.view.window setRootViewController:initViewController];
}




@end
