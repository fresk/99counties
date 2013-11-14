//
//  Utils.m
//  Iowa Counties
//
//  Created by Thomas Hansen on 10/9/13.
//  Copyright (c) 2013 fresk. All rights reserved.
//

#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>






@implementation Utils


+ (NSDictionary*) loadJsonFile: (NSString*)filename {
    NSError *err;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    NSLog(@"read Error: %@", err ) ;
    if (err)
        return nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    NSLog(@"json Error: %@", err ) ;
    if (err)
        return nil;
    return json;
}






+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


@end



/*
@implementation UIButton (CustomFont)

- (NSString *)fontName {
    return self.titleLabel.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.titleLabel.font = [UIFont fontWithName:fontName size:self.titleLabel.font.pointSize];
}

- (NSInteger)fontSize {
    return self.titleLabel.font.pointSize;
}

- (void)setFontSize:(NSInteger)fontSize {
    self.titleLabel.font = [UIFont fontWithName: self.fontName size: fontSize];
}

@end



@implementation UILabel (CustomFont)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

- (NSInteger)fontSize {
    return self.font.pointSize;
}

- (void)setFontSize:(NSInteger)fontSize {
    self.font = [UIFont fontWithName: self.fontName size: fontSize];
}


@end



@implementation UITextField (CustomFont)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

- (NSInteger)fontSize {
    return self.font.pointSize;
}

- (void)setFontSize:(NSInteger)fontSize {
    self.font = [UIFont fontWithName:[self fontName] size:self.fontSize];
}
@end



*/

@implementation NSDictionary (NSURL)

- (NSString*) getAsQueryParams {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncode(id object) {
    return [[NSString stringWithFormat: @"%@", object] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

+ (NSDictionary *)URLQueryParameters:(NSURL *)URL {
    NSString *queryString = [URL query];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters)
    {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [[parts objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([parts count] > 1)
        {
            id value = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [result setObject:value forKey:key];
        }
    }
    return result;
}

@end



@implementation NSURL (QueryParams)

+ (NSURL*) URLWithPath: (NSString*) path andParams: (NSDictionary*) params {
    return (params != nil) ? [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", path, [params getAsQueryParams]]] : [NSURL URLWithString:path];
}

@end