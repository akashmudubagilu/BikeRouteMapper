//
//  ElevationChartAPI.h
//  Elevation
//
//  Created by Akash Mudubagilu on 4/2/16.
//  Copyright © 2016 Akash Mudubagilu. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface ElevationChartAPI : NSObject

- (void)getChartForLocations:(NSArray *)locations size:(CGSize)size completion:(void (^)(UIImage *image, NSError *error))completion;

@end
