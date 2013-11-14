//
//  FYIScreen.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 11/13/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ContextList.h"
#import "DetailView.h"

@interface FYIScreen :  UIViewController<GMSMapViewDelegate>


@property (weak, nonatomic) IBOutlet GMSMapView *map_view;
@property (strong, nonatomic) IBOutlet UIButton *context_tab;
@property (strong, atomic) ContextList* context_list;
@property (strong, atomic) DetailView* detail_view;


@end
