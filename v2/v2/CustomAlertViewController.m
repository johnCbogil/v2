//
//  CustomAlertViewController.m
//  v2
//
//  Created by John Bogil on 11/9/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "CustomAlertViewController.h"
#import <STPopup/STPopup.h>

@implementation CustomAlertViewController
- (instancetype)init
{
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(100, 100);
        self.landscapeContentSizeInPopup = CGSizeMake(100, 100);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Add views here
    // self.view.frame.size == self.contentSizeInPopup in portrait
    // self.view.frame.size == self.landscapeContentSizeInPopup in landscape
    self.contentSizeInPopup = CGSizeMake(100, 100);
}

@end
