//
//  DirectionAPI.m
//  
//
//  Created by Akash Mudubagilu on 3/31/16.
//
//

#import "DirectionAPI.h"
#import "AFNetworking.h"

#define kDirectionString "https://open.mapquestapi.com/directions/v2/route?key=%@&outFormat=json&routeType=bicycle&timeType=1&enhancedNarrative=false&shapeFormat=raw&generalize=0&locale=en_US&unit=m&drivingStyle=2&from=%@,%@&to=%@,%@"


@implementation DirectionAPI

- (NSString *)getURLStringForDirectionFrom:(CLLocation*)fromLocation to:(CLLocation *)toLocation{
    
    NSString *fromLat = [[NSNumber numberWithDouble:fromLocation.coordinate.latitude] stringValue];
    NSString *fromLong = [[NSNumber numberWithDouble:fromLocation.coordinate.longitude] stringValue];
    NSString *toLat = [[NSNumber numberWithDouble:toLocation.coordinate.latitude] stringValue];
    NSString *toLong = [[NSNumber numberWithDouble:toLocation.coordinate.longitude] stringValue];
    
    
    NSString *urlString = [NSString stringWithFormat:@kDirectionString,kMapQuestSecretKey, fromLat, fromLong, toLat, toLong];
    
    
    return urlString;
}

- (void)getDirectionFrom:(CLLocation*)fromLocation to:(CLLocation *)toLocation completion:(void (^)(id data, NSError * error))completion{
    
    NSParameterAssert(completion);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:[self getURLStringForDirectionFrom:fromLocation to:toLocation] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        NSDictionary *route = [(NSDictionary *)responseObject objectForKey:@"route"];
        NSDictionary *shape = [(NSDictionary *)route objectForKey:@"shape"];
        NSArray *shapePointsArray = [shape objectForKey:@"shapePoints"];
        if (completion){
            completion(shapePointsArray,nil);
        }

        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
      //  NSLog(@"Error: %@", error);
        completion(nil,error);

    }];
}
@end
