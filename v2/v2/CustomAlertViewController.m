//
//  CustomAlertViewController.m
//  v2
//
//  Created by John Bogil on 11/9/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "CustomAlertViewController.h"
#import <STPopup/STPopup.h>
#import "UIFont+voicesFont.h"
@interface CustomAlertViewController()

@end


@implementation CustomAlertViewController
- (instancetype)init
{
    if (self = [super init]) {
        self.contentSizeInPopup = CGSizeMake(200, 200);
        //self.landscapeContentSizeInPopup = CGSizeMake(100, 100);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Add views here
    // self.view.frame.size == self.contentSizeInPopup in portrait
    // self.view.frame.size == self.landscapeContentSizeInPopup in landscape
    self.contentSizeInPopup = CGSizeMake(200, 200);
    self.messageLabel.text = self.messageText;
    self.messageLabel.font = [UIFont voicesFontWithSize:18];
    self.title = self.titleText;
}
@end