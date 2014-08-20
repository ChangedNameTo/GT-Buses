//
//  ViewController.m
//  GT-Buses
//
//  Created by Alex Perez on 1/22/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "RootViewController.h"

@import MapKit;

#import "AboutController.h"
#import "GBRequestHandler.h"
#import "XMLReader.h"
#import "Route.h"
#import "BusAnnotation.h"
#import "BusStopAnnotation.h"
#import "BusRouteLine.h"
#import "GBColors.h"
#import "MapHandler.h"
#import "MFSideMenu.h"
#import "GBConstants.h"
#import "GBUserInterface.h"
#import "BusRouteControlView.h"

@interface RootViewController () <RequestHandlerDelegate, CLLocationManagerDelegate> {
    NSTimer *refreshTimer;
    NSArray *busPositionData;
    NSMutableArray *routes;
    Route *selectedRoute;
    
    long long lastLocationUpdate;
    long long lastPredictionUpdate;
}

@property (nonatomic, strong) BusRouteControlView *busRouteControlView;
@property (nonatomic, strong) MapHandler *mapHandler;
@property (nonatomic, strong) CLLocationManager *manager;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.navigationController.navigationBar.topItem.title = @"GT Buses";
    self.navigationController.navigationBar.translucent = NO;
    if ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")))
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(aboutPressed)];
    aboutButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : [UIColor appTintColor];
    self.navigationItem.leftBarButtonItem = aboutButton;
    
//    UIImage *faceImage = [UIImage imageNamed:@"List.png"];
//    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
//    face.bounds = CGRectMake(0, 0, faceImage.size.width/2, faceImage.size.height/2);
//    [face setImage:faceImage forState:UIControlStateNormal];
    
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithCustomView:face];
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"List.png"] style:UIBarButtonItemStylePlain target:self action:nil];
//    listButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : [Colors appTintColor];
//    self.navigationItem.rightBarButtonItem = listButton;
    
    self.busRouteControlView = [[BusRouteControlView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [self.busRouteControlView.busRouteControl addTarget:self action:@selector(didChangeBusRoute) forControlEvents:UIControlEventValueChanged];
    
    float mapHeight = SCREEN_HEIGHT - (20 + 44);
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.busRouteControlView.frame.origin.y, SCREEN_WIDTH, mapHeight)];
    if ([self.mapView respondsToSelector:@selector(setRotateEnabled:)]) {
        self.mapView.rotateEnabled = NO;
    }
    self.mapHandler = [[MapHandler alloc] init];
    self.mapView.delegate = self.mapHandler;
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(33.775978, -84.399269), MKCoordinateSpanMake(0.025059, 0.023190));
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.busRouteControlView];
    
    routes = [NSMutableArray new];
    
    self.menuContainerViewController.menuWidth = (IS_IPAD) ? 200 : 150;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuStateEventOccurred:) name:MFSideMenuStateNotificationEvent object:nil];
    
    if (!(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")))
        [self updateVehicleLocations];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (IS_IPAD) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    if (self.menuContainerViewController.menuState == MFSideMenuStateClosed)
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    else
        self.menuContainerViewController.panMode = MFSideMenuPanModeCenterViewController;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorizationStatus: %d",status);
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.mapView setShowsUserLocation:YES];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (refreshTimer) [refreshTimer invalidate];
    [self.mapView setShowsUserLocation:NO];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"CLAuthorizationStatus: %d",status);
#warning only needed on ios 8
    if(status == kCLAuthorizationStatusNotDetermined) {
        self.manager = [[CLLocationManager alloc] init];
        [self.manager requestWhenInUseAuthorization];
    }
    else {
        [self.mapView setShowsUserLocation:YES];
    }
    
    [self updateVehicleLocations];
    if (!refreshTimer.isValid)
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateVehicleLocations) userInfo:nil repeats:YES];
}

- (void)aboutPressed {
    if (self.menuContainerViewController.menuState == MFSideMenuStateClosed)
        [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:NULL];
    else
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:NULL];
}

- (void)handleResponse:(RequestHandler *)handler data:(id)data {
    [self.busRouteControlView.activityIndicator stopAnimating];
    
    NSError *error;
    NSDictionary *dictionary = [XMLReader dictionaryForXMLData:data error:&error];
    
    if (!error) {
        self.navigationItem.rightBarButtonItem = nil;
        self.busRouteControlView.errorLabel.hidden = YES;
        self.busRouteControlView.busRouteControl.hidden = NO;
        
        if ([handler.task isEqualToString:@"routeConfig"]) {
            if (self.busRouteControlView.busRouteControl.numberOfSegments == 0) {
                NSArray *newRoutes = [[dictionary objectForKey:@"body"] objectForKey:@"route"];
                
                for (int x = 0; x < [newRoutes count]; x++) {
                    NSDictionary *routeDic = [newRoutes objectAtIndex:x];
                    Route *route = [routeDic toRoute];
                    [routes addObject:route];
                    [self.busRouteControlView.busRouteControl insertSegmentWithTitle:route.title atIndex:x animated:YES];
                }
                
                NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsKeySelectedRoute];
                if (self.busRouteControlView.busRouteControl.numberOfSegments > 0)
                    self.busRouteControlView.busRouteControl.selectedSegmentIndex = (index < self.busRouteControlView.busRouteControl.numberOfSegments) ? index : 0;
                
                if (!IS_IPAD)
                    self.busRouteControlView.busRouteControl.frame = CGRectMake(5, 5, SCREEN_WIDTH - ((SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? 9 : 10), 30);
                else if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
                    self.busRouteControlView.busRouteControl.frame = CGRectMake(15, 5, SCREEN_HEIGHT - 30, 30);
                
                [self didChangeBusRoute];
            }
        }
        else if ([handler.task isEqualToString:@"vehicleLocations"]) {
            long long newLocationUpdate = [[[[dictionary objectForKey:@"body"] objectForKey:@"lastTime"] objectForKey:@"time"] longLongValue];
            
            if (newLocationUpdate != lastLocationUpdate) {
                NSArray *vehicles = [[dictionary objectForKey:@"body"] objectForKey:@"vehicle"];
                
                if (vehicles) {
                    if (![vehicles isKindOfClass:[NSArray class]])
                        vehicles = [NSArray arrayWithObject:vehicles];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@",[BusAnnotation class]];
                    NSMutableArray *busAnnotations = [[self.mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                    
                    for (NSDictionary *busPosition in vehicles) {
                        BusAnnotation *annotation = [[BusAnnotation alloc] init];
                        annotation.busIdentifier = [busPosition objectForKey:@"id"];
                        annotation.color = [selectedRoute.color darkerColor:0.5];
                        
                        BOOL found = NO;
                        for (int x = 0; x < [busAnnotations count]; x++) {
                            BusAnnotation *busAnnotation = [busAnnotations objectAtIndex:x];
                            if ([busAnnotation isEqual:annotation]) {
                                [busAnnotations removeObject:busAnnotation];
                                annotation = busAnnotation;
                                found = YES;
                                break;
                            }
                        }
                        
                        annotation.heading = [[busPosition objectForKey:@"heading"] intValue];
                        
                        if (annotation.coordinate.latitude != [[busPosition objectForKey:@"lat"] doubleValue] || annotation.coordinate.longitude != [[busPosition objectForKey:@"lon"] doubleValue]) {
                            [UIView animateWithDuration:1 animations:^{
                                [annotation updateHeading];
                                [annotation setCoordinate:CLLocationCoordinate2DMake([[busPosition objectForKey:@"lat"] doubleValue], [[busPosition objectForKey:@"lon"] doubleValue])];
                            }];
                        }
                        
                        if (!found && [selectedRoute.tag isEqualToString:[busPosition objectForKey:@"routeTag"]])
                            [self.mapView addAnnotation:annotation];
                    }
                    
                    for (BusAnnotation *annotation in busAnnotations)
                        [self.mapView removeAnnotation:annotation];
                }
            }
            lastLocationUpdate = newLocationUpdate;
        }
        else if ([handler.task isEqualToString:@"vehiclePredictions"]) {
            long long newPredictionUpdate = [[[[dictionary objectForKey:@"body"] objectForKey:@"keyForNextTime"] objectForKey:@"value"] longLongValue];
            if (newPredictionUpdate != lastPredictionUpdate) {
                NSArray *predictions = [[dictionary objectForKey:@"body"] objectForKey:@"predictions"];
                if (predictions) {
                    if (![predictions isKindOfClass:[NSArray class]])
                        predictions = [NSArray arrayWithObject:predictions];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@",[BusStopAnnotation class]];
                    NSMutableArray *busStopAnnotations = [[self.mapView.annotations filteredArrayUsingPredicate:predicate] mutableCopy];
                    
                    for (NSDictionary *busStop in predictions) {
                        NSArray *predictionData = [[busStop objectForKey:@"direction"] objectForKey:@"prediction"];
                        NSArray *predictions;
                        if (predictionData) {
                            if (![predictionData isKindOfClass:[NSArray class]])
                                predictionData = [NSArray arrayWithObject:predictionData];
                            
#warning why not just do else if condition?
                            if ([predictionData count] >= 3)
                                predictions = [predictionData subarrayWithRange:NSMakeRange(0, 3)];
                            else if ([predictionData count] > 0)
                                predictions = [predictionData subarrayWithRange:NSMakeRange(0, [predictionData count])];
                        }
                        
                        for (int x = 0; x < [busStopAnnotations count]; x++) {
                            BusStopAnnotation *busStopAnnotation = [busStopAnnotations objectAtIndex:x];
                            if ([busStopAnnotation.stopTag isEqualToString:[busStop objectForKey:@"stopTag"]]) {
                                if (predictions) {
                                    NSMutableString *subtitle = [NSMutableString stringWithFormat:@"Next: "];
                                    for (int x = 0; x < [predictions count]; x++) {
                                        NSDictionary *prediction = [predictions objectAtIndex:x];
                                        [subtitle appendFormat:(x == [predictions count]-1) ? @"%@" : @"%@, ", [prediction objectForKey:@"minutes"]];
                                    }
                                    busStopAnnotation.subtitle = ([predictions count] > 0) ? subtitle : @"No Predictions";
                                }
                                else
                                    busStopAnnotation.subtitle = @"No Predictions";
                                
                                [busStopAnnotations removeObject:busStopAnnotation];
                                break;
                            }
                        }
                    }
                }
            }
            lastPredictionUpdate = newPredictionUpdate;
        }
    }
    else
        [self handleError:handler code:4923 message:@"Error Parsing Data"];
}

- (void)handleError:(RequestHandler *)handler code:(NSInteger)code message:(NSString *)message {
    [self.busRouteControlView.activityIndicator stopAnimating];
    self.busRouteControlView.errorLabel.hidden = NO;
    self.busRouteControlView.busRouteControl.hidden = YES;
    
    UIColor *tintColor = [UIColor appTintColor];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateVehicleLocations)];
    refreshButton.tintColor = (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [UIColor whiteColor] : tintColor;
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    if (code == 1008 || code == 1009)
        self.busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"No Internet Connection (-%i)",code];
    else if (code == 400)
        self.busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Bad Request (-%i)",code];
    else if (code == 404)
        self.busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Resource Error (-%i)",code];
    else if (code == 500)
        self.busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Internal Server Error (-%i)",code];
    else if (code == 503)
        self.busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Timed Out (-%i)",code];
    else
        self.busRouteControlView.errorLabel.text = [NSString stringWithFormat:@"Error Connecting (-%i)",code];
}

- (void)updateVehicleLocations {
    if (selectedRoute) {
        GBRequestHandler *locationHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"vehicleLocations"];
        [locationHandler positionForBus:selectedRoute.tag];
        
        GBRequestHandler *predictionHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"vehiclePredictions"];
        [predictionHandler predictionsForBus:selectedRoute.tag];
    }
    else {
        GBRequestHandler *requestHandler = [[GBRequestHandler alloc] initWithDelegate:self task:@"routeConfig"];
        [self.busRouteControlView.activityIndicator startAnimating];
        self.busRouteControlView.errorLabel.hidden = YES;
        [requestHandler routeConfig];
    }
}

- (void)didChangeBusRoute {
    if (self.busRouteControlView.busRouteControl.selectedSegmentIndex > -1)
        [[NSUserDefaults standardUserDefaults] setInteger:self.busRouteControlView.busRouteControl.selectedSegmentIndex forKey:GBUserDefaultsKeySelectedRoute];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    selectedRoute = [routes objectAtIndex:self.busRouteControlView.busRouteControl.selectedSegmentIndex];
    [UIView animateWithDuration:.4 animations:^{
        if (IS_IPAD && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            [self.mapView setRegion:selectedRoute.region];
        else
            [self.mapView setRegion:[self.mapView regionThatFits:selectedRoute.region]];
    }];
    
    [self updateVehicleLocations];
    
    for (NSDictionary *path in selectedRoute.paths) {
        NSArray *points = [path objectForKey:@"point"];
        CLLocationCoordinate2D coordinates[[points count]];
        for (int y = 0; y < [points count]; y++) {
            NSDictionary *point = [points objectAtIndex:y];
            coordinates[y] = CLLocationCoordinate2DMake([[point objectForKey:@"lat"] floatValue],[[point objectForKey:@"lon"] floatValue]);
        }
        BusRouteLine *polygon = [BusRouteLine polylineWithCoordinates:coordinates count:[points count]];
        polygon.color = selectedRoute.color;
        [self.mapView addOverlay:polygon];
    }
    
    for (NSDictionary *stop in selectedRoute.stops) {
        BusStopAnnotation *stopPin = [[BusStopAnnotation alloc] init];
        stopPin.title = [stop objectForKey:@"title"];
        stopPin.subtitle = @"No Predictions";
        stopPin.tag = selectedRoute.tag;
        stopPin.stopTag = [stop objectForKey:@"tag"];
        stopPin.color = selectedRoute.color;
        [stopPin setCoordinate:CLLocationCoordinate2DMake([[stop objectForKey:@"lat"] doubleValue], [[stop objectForKey:@"lon"] doubleValue])];
        [self.mapView addAnnotation:stopPin];
    }
}

- (void)orientationChanged:(NSNotification *)notification {
    [self performSelector:@selector(fixRegion) withObject:nil afterDelay:1];
}

- (void)fixRegion {
    [UIView animateWithDuration:.4 animations:^{
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            [self.mapView setRegion:selectedRoute.region];
        else
            [self.mapView setRegion:[self.mapView regionThatFits:selectedRoute.region]];
    }];
}

@end
