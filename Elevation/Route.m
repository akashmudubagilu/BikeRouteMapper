//
//  Route.m
//  Elevation
//
//  Created by Akash Mudubagilu on 4/1/16.
//  Copyright © 2016 Akash Mudubagilu. All rights reserved.
//

#import "Route.h"

@implementation Route

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userDefinedPoints = [NSMutableArray array];
        _shapePoints = [NSMutableArray array];
        _annotations = [NSMutableArray array];

    }
    return self;
}

- (BOOL)shouldMakeDirectionCall;
{
    if (self.userDefinedPoints.count > 1) {
        return YES;
    }
    return NO;
}

- (CLLocation *)getPreviousPoint;
{
    long length = self.userDefinedPoints.count;
    if (length > 1) {
        return [self.userDefinedPoints objectAtIndex:length-2];
    }
    return  nil;
}

@end
