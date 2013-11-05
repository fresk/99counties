//
//  TripPlanerViewController.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/29/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "TripPlanerViewController.h"
#import "MDDirectionService.h"

@interface TripPlanerViewController ()
@property (strong, nonatomic) IBOutlet UITextField *textfield_from;
@property (strong, nonatomic) IBOutlet UITextField *textfield_to;

@end

@implementation TripPlanerViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqual: @"plan_a_trip"]){
        
            NSDictionary *query = @{
                @"sensor": @"false",
                @"waypoints": [NSArray arrayWithObjects:@"Iowa City, IA", @"Des Moines, IA"]
            };
        
            MDDirectionService *mds=[[MDDirectionService alloc] init];
            SEL selector = @selector(addDirections:);
            [mds setDirectionsQuery:query withSelector:selector withDelegate:self];

        
    }
}


@end
