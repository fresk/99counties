//
//  LayerView.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 9/24/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "LayerView.h"


@implementation LayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *result = [super hitTest:point withEvent:event];
    if (result ==  self){
        return nil;
    }
    return result;
    
}

@end



@implementation ScrollLayer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *result = [super hitTest:point withEvent:event];
    if (result ==  self){
        return nil;
    }
    return result;
    
}

@end
