//
//  GBRequestHandler.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "RequestHandler.h"

extern NSString *const GBRequestAgencyTask;
extern NSString *const GBRequestRouteConfigTask;
extern NSString *const GBRequestVehicleLocationsTask;
extern NSString *const GBRequestVehiclePredictionsTask;
extern NSString *const GBRequestMultiPredictionsTask;
extern NSString *const GBRequestMessagesTask;
extern NSString *const GBRequestScheduleTask;
extern NSString *const GBRequestBuildingsTask;

@class GBRoute;
@interface GBRequestHandler : RequestHandler

- (void)agencyList;
- (void)routeConfig;
- (void)locationsForRoute:(GBRoute *)route;
- (void)predictionsForRoute:(GBRoute *)route;
- (void)multiPredictionsForStops:(NSString *)parameterList;
- (void)messages;
- (void)buildings;

+ (NSString *)errorMessageForCode:(NSInteger)code;
+ (BOOL)isNextBusError:(NSDictionary *)dictionary;

extern NSString *const GBRequestErrorDomain;

enum {
    GBRequestParseError = 2923,
    GBRequestNextbusError = 2943,
    GBRequestNextbusInvalidAgencyError = 2963,
};

@end
