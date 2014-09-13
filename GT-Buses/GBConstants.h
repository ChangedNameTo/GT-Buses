//
//  GBConstants.h
//  GT-Buses
//
//  Created by Alex Perez on 7/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

extern NSString * const GBFontDefault;

extern NSString * const GBUserDefaultsFilePath;
extern NSString * const GBUserDefaultsKeySelectedRoute;

extern float const kSideWidth;
extern float const kSideWidthiPad;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define FORMAT(format,...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
