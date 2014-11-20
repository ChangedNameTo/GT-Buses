//
//  GBBuilding.m
//  GT-Buses
//
//  Created by Alex Perez on 11/20/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBBuilding.h"

@implementation NSDictionary (GBBuilding)

- (GBBuilding *)toBuilding {
    GBBuilding *building = [[GBBuilding alloc] initWithName:self[@"name"] buildingID:self[@"buildingID"]];
    building.address = self[@"address"];
    building.imageURL = self[@"imageURL"];
    building.phone = self[@"phone"];
    building.lat = [self[@"lat"] doubleValue];
    building.lon = [self[@"lon"] doubleValue];
    return building;
}

@end

@implementation GBBuilding

- (instancetype)initWithName:(NSString *)name buildingID:(NSString *)buildingID {
    self = [super init];
    if (self) {
        _name = name;
        _buildingID = buildingID;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GBBuilding Name: %@, ID: %@>", _name, _buildingID];
}

@end
