//
//  Route.m
//  GT-Buses
//
//  Created by Alex Perez on 1/29/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBRoute.h"

#import "GBColors.h"

float const kMapRegionPadding = 0.0005f;

@interface GBRoute ()

+ (MKCoordinateRegion)regionForPaths:(NSArray *)paths;

@end

@implementation NSDictionary (Route)

- (GBRoute *)toRoute {
    NSString *lowercaseTitle = self[@"tag"];
    NSString *title = [NSString stringWithFormat:@"%@%@", [[lowercaseTitle substringToIndex:1] uppercaseString], [lowercaseTitle substringFromIndex:1]];
    
    GBRoute *route = [[GBRoute alloc] initWithTitle:title tag:lowercaseTitle];
    route.paths = self[@"path"];
    route.region = [GBRoute regionForPaths:route.paths];
    route.stops = self[@"stop"];
    route.color = [UIColor colorWithHexString:self[@"color"]];
    
    return route;
}

@end

@implementation GBRoute

- (instancetype)initWithTitle:(NSString *)title tag:(NSString *)tag {
    self = [super init];
    if (self) {
        self.title = title;
        self.tag = tag;
    }
    return self;
}

+ (MKCoordinateRegion)regionForPaths:(NSArray *)paths {
    float minLat = FLT_MAX;
    float minLon = -FLT_MAX;
    float maxLat = 0;
    float maxLon = 0;
    
    // Loop through all paths and find the min lat/lon and max lat/lon
    for (NSDictionary *path in paths) {
        NSArray *points = path[@"point"];
        for (NSDictionary *point in points) {
            float lat = [point[@"lat"] floatValue];
            float lon = [point[@"lon"] floatValue];
            
            minLat = fminf(minLat, lat);
            minLon = fmaxf(minLon, lon);
            
            maxLat = fmaxf(maxLat, lat);
            maxLon = fminf(maxLon, lon);
        }
    }
    
    CLLocationCoordinate2D coordinateMin = CLLocationCoordinate2DMake(minLat, minLon);
    CLLocationCoordinate2D coordinateMax = CLLocationCoordinate2DMake(maxLat, maxLon);
    
    MKMapPoint lowerLeft = MKMapPointForCoordinate(coordinateMin);
    MKMapPoint upperRight = MKMapPointForCoordinate(coordinateMax);
    
    MKMapRect mapRect = MKMapRectMake(lowerLeft.x, lowerLeft.y, upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y);
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    region.span.latitudeDelta = maxLat - minLat + kMapRegionPadding;
    region.span.longitudeDelta = minLon - maxLon + kMapRegionPadding;
    
    return region;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Title: %@, Tag: %@>", self.title, self.tag];
}

@end