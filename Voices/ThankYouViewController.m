//
//  ThankYouViewController.m
//  Voices
//
//  Created by Daniel Nomura on 1/27/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ThankYouViewController.h"
#import <STPopup/STPopup.h>

@interface ThankYouViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeWindowButton;

@end

@implementation ThankYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Thank you!";
    self.contentSizeInPopup = CGSizeMake(300, 315);

    
    
}


@end
