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




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
