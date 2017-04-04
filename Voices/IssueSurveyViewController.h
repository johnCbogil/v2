//
//  IssueSurveyViewController.h
//  Voices
//
//  Created by Andy Wu on 3/28/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueSurveyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *urlString;

@end
