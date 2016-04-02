//
//  Route.h
//  Elevation
//
//  Created by Akash Mudubagilu on 4/1/16.
//  Copyright © 2016 Akash Mudubagilu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Route : NSObject

@property(nonatomic, strong) NSMutableArray *userDefinedPoints;
@property(nonatomic, strong) NSMutableArray *shapePoints;
@property(nonatomic, strong) NSMutableArray *annotations;


- (BOOL)shouldMakeDirectionCall;
- (CLLocation *)getPreviousPoint;
@end
