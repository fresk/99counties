//
//  Utils.h
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Utils : NSObject
+ (NSDictionary*) loadJsonFile: (NSString*)filename ;
@end


@interface UIButton (CustomFont)
@property (nonatomic, copy) NSString* fontName;
@end

@interface UILabel (CustomFont)
@property (nonatomic, copy) NSString* fontName;
@end

@interface UITextField (CustomFont)
@property (nonatomic, copy) NSString* fontName;
@end

@interface NSDictionary (NSURL)
- (NSString*) getAsQueryParams;
+ (NSDictionary *)URLQueryParameters:(NSURL *)URL;
@end

@interface NSURL (QueryParams)
+ (NSURL*) URLWithPath: (NSString*) path andParams: (NSDictionary*) params;
@end