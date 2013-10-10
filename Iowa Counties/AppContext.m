//
//  AppContext.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "AppContext.h"
#import "Utils.h"

static AppContext *ctx_instance = nil;
static dispatch_once_t onceToken;

@implementation AppContext



+ (id)instance {
    dispatch_once(&onceToken, ^{
        ctx_instance = [self alloc];
        ctx_instance = [ctx_instance init];
        [ctx_instance initializeContext];
    });
    return ctx_instance;
}

- (void)initializeContext {
    self.appName = @"Find Your Iowa";
    self.locationCategories = [Utils loadJsonFile:@"data/categories"];
    NSLog(@"APP Context initialized %d", [self.locationCategories count]);
}


@end
