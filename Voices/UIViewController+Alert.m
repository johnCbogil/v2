//
//  UIViewController+Alert.m
//  Voices
//
//  Created by David Weissler on 10/14/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "UIViewController+Alert.h"

#import "Action.h"
#import "Group.h"

@implementation UIViewController (Alert)

- (void)presentThankYouAlertForGroup:(Group *)group andAction:(Action *)action {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Action Completed!"
                                                                             message:@"Thank you! Now share this action with others, change happens when many people act together."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"Share..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull alert) {
        
        NSString *shareString = [NSString stringWithFormat:@"Hey, please help me support %@. %@.\n\n https://tryvoices.com/%@", group.name, action.title, group.key];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString]applicationActivities:nil];
        [self.navigationController presentViewController:activityViewController
                                                animated:YES
                                              completion:^{ }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:shareAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
