//
//  GBRootViewController.h
//  GT-Buses
//
//  Created by Alex Perez on 9/24/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import UIKit;
@import Foundation;

@interface GBRootViewController : UIViewController
#warning move this to gbconfig?
@property (nonatomic, getter=isSearchEnabled) BOOL searchEnaled;

@end
