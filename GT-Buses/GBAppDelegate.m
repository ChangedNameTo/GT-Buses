//
//  GBAppDelegate.m
//  GT-Buses
//
//  Created by Alex Perez on 2/4/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBAppDelegate.h"

#import "GBRootViewController.h"
#import "GBUserInterface.h"
#import "GBConstants.h"
#import "GBWindow.h"
#import "GBConfig.h"
#import "GBRequestConfig.h"
#import "NSUserDefaults+SharedDefaults.h"

@implementation GBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // over 100 routes: actransit, ttc, lametro, mbta

    [GBConfig sharedInstance].agency = GBGeorgiaTechAgency;
    
    self.viewController = [[GBRootViewController alloc] init];
    self.viewController.searchEnabled = YES;
    
#if !DEFAULT_IMAGE
    self.viewController.title = NSLocalizedString(@"TITLE", @"Main Title");
#endif
    
    GBNavigationController *navController = [[GBNavigationController alloc] initWithRootViewController:self.viewController];
    
    self.window = [[GBWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (ROTATION_ENABLED) {
        // Don't allow rotation when settings is open since it interferes with the root view controller scale transform
        GBWindow *gbwindow = (GBWindow *)window;
        if (gbwindow.settingsVisible) {
            UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            return UIInterfaceOrientationIsLandscape(statusBarOrientation) ? UIInterfaceOrientationMaskLandscape : (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
        }
        
        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
