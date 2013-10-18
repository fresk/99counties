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


- (void) loadLocationsByCounty: (NSString*) county intoTable: (FilterResultsController*) target
{


    
    NSURL *URL = [NSURL URLWithString:@"http://findyouriowa.com/api/locations"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSError *err;
                                      if (err != nil)
                                          NSLog(@"URLRequest callback error (loadLocationsByCounty): %@", err);
                                      
                                      
                                      NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
                                      if (err != nil)
                                          NSLog(@"Json parsing error (loadLocationsByCounty): %@", err);

                                      [target setResults: results];
                                  }];
    
    [task resume];
    

    

}



@end
