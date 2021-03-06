//
//  UIViewController+MailComposer.m
//  GT-Buses
//
//  Created by Alex Perez on 8/14/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "UIViewController+MailComposer.h"

#import "GBConstants.h"
#import "GBSupportEmail.h"

// TODO: [Bug] Dismissing mail composer changes status bar style on iOS 6 and below

@implementation UIViewController (MailComposer)

- (void)showSupportMailComposer {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
        composeController.mailComposeDelegate = self;
        
        [composeController setSubject:[GBSupportEmail subject]];
        [composeController setToRecipients:[NSArray arrayWithObject:[GBSupportEmail recipients]]];
        [composeController setMessageBody:[GBSupportEmail body] isHTML:NO];
        
        [self presentViewController:composeController animated:YES completion:^{
            if IS_IPAD [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    } else {
        NSString *emailString = FORMAT(@"mailto:%@?subject=%@&body=%@", [GBSupportEmail recipients], [GBSupportEmail subject], [GBSupportEmail body]);
        emailString = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
    }
}

@end
