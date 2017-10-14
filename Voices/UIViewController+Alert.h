//
//  UIViewController+Alert.h
//  Voices
//
//  Created by David Weissler on 10/14/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Action;
@class Group;

@interface UIViewController (Alert)

- (void)presentThankYouAlertForGroup:(Group *)group andAction:(Action *)action;

@end
