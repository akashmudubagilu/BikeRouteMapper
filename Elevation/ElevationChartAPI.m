//
//  ElevationChartAPI.m
//  Elevation
//
//  Created by Akash Mudubagilu on 4/2/16.
//  Copyright © 2016 Akash Mudubagilu. All rights reserved.
//

#import "ElevationChartAPI.h"
#import "AFNetworking.h"
#import "AFImageDownloader.h"
#import "NSString+Utilities.h"

#define kElevationChartURL "https://open.mapquestapi.com/elevation/v1/chart?key=%@&inFormat=kvp&shapeFormat=raw&width=%@&height=%@&latLngCollection=%@"

@implementation ElevationChartAPI

- (NSString *)getURLStringForLocations:(NSArray *)locations forSize:(CGSize)size{

    NSString *locationsString = [self getLocationStringFromLocations:locations];
    
    NSString *URLString = [NSString stringWithFormat:@kElevationChartURL,kMapQuestSecretKey,[NSString intStringWithFloat:size.width], @"250",locationsString];
    
    NSLog(@"%@",URLString);
    return URLString;
}

- (NSString *)getLocationStringFromLocations:(NSArray *)locations
{
    NSString *locationString = @"";
    for (CLLocation *location in locations)
    {
        locationString = [NSString stringWithFormat:@"%@%@,%@,",locationString,[NSString stringWithFloat:location.coordinate.latitude], [NSString stringWithFloat:location.coordinate.longitude]];
    }
    
    return locationString;
}

- (void)getChartForLocations:(NSArray *)locations size:(CGSize)size completion:(void (^)(UIImage *image, NSError *error))completion;
{
    NSParameterAssert(completion);
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[self getURLStringForLocations:locations forSize:size]]];
    
    AFImageDownloader *imageDownloader = [[AFImageDownloader alloc]init];
    [imageDownloader downloadImageForURLRequest:request
                                        success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                                                completion(responseObject, nil);
                                        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                completion(nil, error);
                                        }];


}
@end
