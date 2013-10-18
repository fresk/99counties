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

@implementation AppContext {


}



+ (id)instance {
    dispatch_once(&onceToken, ^{
        ctx_instance = [self alloc];
        ctx_instance = [ctx_instance init];
        [ctx_instance initializeContext];
    });
    return ctx_instance;
}


- (UIImage*) markerForCategory: (NSArray*) category {
    NSString* fname = [NSString stringWithFormat:@"marker-%@.png", category[0]];
    UIImage* img =  [UIImage imageNamed: fname];
    NSLog(@"LOAD IMAGE:  %@ (%f, %f)", fname, img.size.width, img.size.height);
    return img;
}

- (UIImage*) markerForCategoryID: (NSString*) category {
    NSString* fname = [NSString stringWithFormat:@"marker-%@.png", category];
    UIImage* img =  [UIImage imageNamed: fname];
    NSLog(@"LOAD IMAGE:  %@ (%f, %f)", fname, img.size.width, img.size.height);
    return img;
}


- (void)initializeContext {
    self.appName = @"Find Your Iowa";
    self.locationCategories = [Utils loadJsonFile:@"data/categories"];
    self.counties = [Utils loadJsonFile:@"data/counties"];
    
    NSLog(@"COUNTIES %@", [self.counties allKeys]);
}




- (void) fetchResources:(NSString*) path withParams: (NSDictionary*) params setResultOn:(id)target
{
    if ([path hasPrefix:@"/"]){
        path = [path substringFromIndex:1];
    }
    
    NSLog(@"making request to: %@\/   params: %@\/  target: %@\n\n", path, params, target);
    
    NSString *endpoint = [NSString stringWithFormat:@"http://findyouriowa.com/api/%@", path];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithPath:endpoint andParams:params]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSError *err;
                                      if (err != nil)
                                          NSLog(@"URLRequest callback error {{loadLocationsWhere: Matches: intoTable:}}: %@", err);
                                      NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
                                      if (err != nil)
                                          NSLog(@"Json parsing error {{loadLocationsWhere: Matches: intoTable:}}: %@", err);
                                      
                                      NSLog(@"GOT RESPONSE: %d", [results count]);
                                      [target setResults: results];
                                  }];
    [task resume];
}





@end
