//
//  ActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 7/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesOrange.h"
#import "VoicesConstants.h"

@interface ActionDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *takeActionButton;
@property (weak, nonatomic) IBOutlet UITextView *actionBodyTextView;



@end

@implementation ActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.groupNameLabel.text = self.action.groupName;
    self.actionDateLabel.text = @"4/7/16";
    self.actionSubjectLabel.text = self.action.subject;
    self.actionTitleLabel.text = self.action.title;
    self.actionBodyTextView.text = self.action.body;
    
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"TAKE ACTION";
    
    [self.takeActionButton setTitle:@"Contact My Representatives" forState:UIControlStateNormal];
    self.takeActionButton.layer.cornerRadius = kButtonCornerRadius;
    
    [self setGroupImageFromURL:self.action.groupImageURL];
}

- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImage.contentMode = UIViewContentModeScaleToFill;
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
    self.groupImage.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: @"MissingRepMale"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Action image success");
        self.groupImage.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Action image failure");
    }];
}

- (IBAction)takeActionButtonDidPress:(id)sender {
    self.tabBarController.selectedIndex = 0;
}

@end
