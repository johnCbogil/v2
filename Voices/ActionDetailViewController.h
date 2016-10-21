//
//  ActionDetailViewController.h
//  Voices
//
//  Created by John Bogil on 7/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "ActionWebViewController.h"

@interface ActionDetailViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Action *action;

@end
