//
//  DirectionAPI.h
//  
//
//  Created by Akash Mudubagilu on 3/31/16.
//
//

#import <CoreLocation/CoreLocation.h>



@interface DirectionAPI : NSObject

- (void)getDirectionFrom:(CLLocation*)fromLocation to:(CLLocation *)toLocation completion:(void (^)(id data, NSError * error))completion;

@end
