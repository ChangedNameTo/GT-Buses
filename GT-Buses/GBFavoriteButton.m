//
//  GBFavoriteButton.m
//  GT-Buses
//
//  Created by Alex Perez on 11/12/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBFavoriteButton.h"

#import "GBBusStopAnnotation.h"
#import "GBStop.h"

@interface GBFavoriteButton ()

@property (nonatomic, strong) GBStop *stop;

@end

@implementation GBFavoriteButton

- (instancetype)initWithBusStopAnnotation:(GBBusStopAnnotation *)annotation {
    self = [super initWithFrame:CGRectMake(0, 0, 30, 30)];
    if (self) {
        _stop = annotation.stop;
        
        [self setFavorite:_stop.isFavorite];
        
        self.backgroundColor = [UIColor redColor];
        [self addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)toggleFavorite:(id)sender {
    // update image
    // update user defaults
    _stop.favorite = !_stop.favorite;
    [self setFavorite:_stop.favorite];
}

- (void)setFavorite:(BOOL)favorite {
    [self setTitle:(favorite) ? @"1" : @"0" forState:UIControlStateNormal];
}

@end
