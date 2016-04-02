//
//  NSString+Utilities.m
//  Elevation
//
//  Created by Akash Mudubagilu on 4/2/16.
//  Copyright © 2016 Akash Mudubagilu. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

+ (NSString *)intStringWithFloat:(float)floatValue{
    NSString *string = [NSString stringWithFormat:@"%d", (int)floatValue];
    return string;
    
}
+ (NSString *)stringWithFloat:(float)floatValue;
{
    NSString *string = [NSString stringWithFormat:@"%f", floatValue];
    return string;
}

@end
