//
//  AppContext.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "AppContext.h"
#import "Utils.h"

@implementation AppContext


+ (id)instance {
    static AppContext *ctx_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ctx_instance = [[self alloc] init];
    });
    return ctx_instance;
}

- (id)init {
    if (self = [super init]) {
        self.appName = @"Find Your Iowa";
        self.locationCategories = [Utils loadJsonFile:@"categories"];
    }
    return self;
}


@end
