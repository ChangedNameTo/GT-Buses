//
//  UIViewController+GBMailComposer.h
//  GT-Buses
//
//  Created by Alex Perez on 8/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

@import Foundation;
@import MessageUI;

@interface UIViewController (GBMailComposer) <MFMailComposeViewControllerDelegate>

- (void)showSupportMailComposer;

@end
