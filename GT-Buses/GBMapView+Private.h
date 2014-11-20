//
//  GBMapView+Private.h
//  GT-Buses
//
//  Created by Alex Perez on 11/19/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;

@interface GBMapView (Private) <GBTintColorDelegate>

- (void)resetBackend;
- (void)toggleParty;
- (void)updateStops;

@end
