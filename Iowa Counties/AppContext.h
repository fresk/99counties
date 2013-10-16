//
//  AppContext.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject 

@property(atomic, strong) NSString* appName;
@property(atomic, strong) NSDictionary* locationCategories;

+ (id)instance;
- (UIImage*) markerForCategory: (NSArray*) category;
- (UIImage*) markerForCategoryID: (NSString*) category;

@end
