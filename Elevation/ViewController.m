//
//  ViewController.m
//  Elevation
//
//  Created by Akash Mudubagilu on 3/31/16.
//  Copyright © 2016 Akash Mudubagilu. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "DirectionAPI.h"
#import "ElevationChartAPI.h"
#import "Route.h"

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property(nonatomic, weak)IBOutlet MKMapView *mapView;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) Route *currentRoute;
@property(nonatomic, weak)IBOutlet UIImageView *elevationChartImageView;
@property(nonatomic, strong) MKPolyline *routeLine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500; // meters
    
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    [self centerMapOnLocation:self.locationManager.location];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter/getter

- (Route *)currentRoute
{
    if(!_currentRoute){
        _currentRoute = [[Route alloc] init];
    }
    return _currentRoute;
}

#pragma mark - MKMapViewDelegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay NS_AVAILABLE(10_9, 7_0);
{
    MKPolylineRenderer *render =  [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    render.strokeColor = [UIColor greenColor];
    return render;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

}


#pragma mark - IBActions

- (IBAction)takeMeToMyCurrentLocation:(id)sender{
   
    [self centerMapOnLocation:self.locationManager.location];
}

- (IBAction)resetRoute:(id)sender{
    [self centerMapOnLocation:self.locationManager.location];
    
    [self.mapView removeOverlay:self.routeLine];

    [self.mapView removeAnnotations:self.currentRoute.annotations];
    self.elevationChartImageView.image = nil;
    self.currentRoute = nil;
    [self.mapView setNeedsDisplay];

}

#pragma mark - private methods
- (void)centerMapOnLocation:(CLLocation *)userLocation{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}

- (NSArray *)getLocationsForPoints:(NSArray *)points
{
    NSMutableArray *mutableTempArray = [NSMutableArray array];
    for(int i = 0; i < points.count-1 ; i = i+2){
        double lat = [points[i] floatValue];
        double lon = [points[i+1] floatValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon ];
        [mutableTempArray addObject:location];
    }
    return mutableTempArray;
}

- (void)drawPolyLineForCoOrdinates:(NSArray *)coOrdinates{
    
    long numPoints = [coOrdinates count];
    if (numPoints > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [coOrdinates objectAtIndex:i];
            coords[i] = current.coordinate;
        }
      
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf.mapView removeOverlay:self.routeLine];

            strongSelf.routeLine = [MKPolyline polylineWithCoordinates:coords count:numPoints];
            free(coords);
            
            [strongSelf.mapView addOverlay:self.routeLine];
            [strongSelf.mapView setNeedsDisplay];

        });
        
    }
}

- (void)makeChartCall{
    ElevationChartAPI *elevationAPI = [[ElevationChartAPI alloc] init];
    [elevationAPI getChartForLocations:self.currentRoute.userDefinedPoints size:self.elevationChartImageView.frame.size completion:^(UIImage *image, NSError *error) {
        if (image && !error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.elevationChartImageView.image = image;
            });
        }
        
    }];
    
}
#pragma mark - gestureRecognizer handlers

- (IBAction)longTapGestureRecognizer:(UILongPressGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        CGPoint touchPoint = [recognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchPointCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        CLLocation *tappedLocation = [[CLLocation alloc] initWithLatitude:touchPointCoordinate.latitude longitude:touchPointCoordinate.longitude];
        
        [self.currentRoute.userDefinedPoints addObject:tappedLocation];
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = touchPointCoordinate;
        [self.mapView addAnnotation:annotation];
        [self.currentRoute.annotations addObject:annotation];
        
        if ([self.currentRoute shouldMakeDirectionCall])
        {
            DirectionAPI *directionAPI = [[DirectionAPI alloc]init];
            __weak typeof(self) weakSelf = self;

            [directionAPI getDirectionFrom:[self.currentRoute getPreviousPoint] to:tappedLocation completion:^(id data, NSError *error) {
                
                __strong typeof(self) strongSelf = weakSelf;
                
                //NSLog(@"%@",data);
                
                if ([data isKindOfClass:NSArray.class]) {
                    NSArray *locations = [strongSelf getLocationsForPoints:data];
                    [strongSelf.currentRoute.shapePoints addObjectsFromArray:locations];
                    [strongSelf drawPolyLineForCoOrdinates:strongSelf.currentRoute.shapePoints];

                    [self makeChartCall];
                }
                
                
            }];
            
            
            
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        //Do Whatever You want on Began of Gesture
    }
    
   
    

}
@end
