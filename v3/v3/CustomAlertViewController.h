//
//  CustomAlertViewController.h
//  v2
//
//  Created by John Bogil on 11/9/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) NSString *messageText;
@property (strong, nonatomic) NSString *titleText;
@end