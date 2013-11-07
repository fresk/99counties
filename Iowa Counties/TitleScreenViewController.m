//
//  TitleScreenViewController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/5/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "TitleScreenViewController.h"
#import <MediaPLayer/MPMoviePlayerController.h>

@interface TitleScreenViewController ()
@property (strong, nonatomic) MPMoviePlayerController* player;


@end

@implementation TitleScreenViewController

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
	// Do any additional setup after loading the view.
    
    
	NSURL *theMovieURL = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle)
	{
		NSString *moviePath = [bundle pathForResource:@"intro_bg" ofType:@"mov"];
		if (moviePath)
		{
			theMovieURL = [NSURL fileURLWithPath:moviePath];
		}
	}


    self.player = [[MPMoviePlayerController alloc] initWithContentURL:theMovieURL];
    self.player.movieSourceType = MPMovieSourceTypeFile;
    [self.player prepareToPlay];
    self.player.controlStyle = MPMovieControlStyleNone;
    [self.player.view setFrame:self.bg_view.frame];  // player's frame must match parent's
    
    [self.bg_view addSubview: self.player.view];
    
    [self.player play];
    
    
}


- (void) viewDidDisappear:(BOOL)animated {
    [self.player stop];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
