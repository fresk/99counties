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
        
        self.logo.alpha = 0.0;
        self.skip_btn.alpha = 0.0;
        
    }
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 
    
    self.logo.alpha = 0.0;
    self.skip_btn.alpha = 0.0;
    
    
    
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
    [self.view bringSubviewToFront: self.skip_btn];
    
    [self.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    
}

- (void)movieFinishedCallBack:(NSNotification *) aNotification {
    MPMoviePlayerController *player = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self goto_main_menu];
}



-(void) goto_main_menu {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainMenuViewController = [storyBoard instantiateViewControllerWithIdentifier:@"main_menu"];
    mainMenuViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController: mainMenuViewController animated:YES];
}


- (IBAction)skip_button_pushed:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [self.player stop];
    [self goto_main_menu];
}


- (void) viewDidAppear:(BOOL)animated
{
    self.logo.alpha = 0.0;
    self.skip_btn.alpha = 0.0;
    
    [UIView animateWithDuration:2.0 delay:3.0 options: UIViewAnimationOptionCurveLinear animations:^{
        self.logo.alpha = 1.0;
        self.skip_btn.alpha = 1.0;
    } completion:^(BOOL finished) {

        
        [UIView animateWithDuration:1.0 delay:9.0 options: UIViewAnimationOptionCurveLinear animations:^{
            self.logo.alpha = 0.0;
            self.skip_btn.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];

    }];
}


- (void) viewWillDisappear:(BOOL)animated {
    [self.player stop];
}

- (IBAction)viewTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [self.player stop];
    [self goto_main_menu];
}


@end
