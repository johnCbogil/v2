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
#import "UIColor+voicesColor.h"
#import "VoicesConstants.h"

@interface ActionDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *takeActionButton;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoLabel;
@property (weak, nonatomic) IBOutlet UITextView *actionBodyTextView;

@end

@implementation ActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.groupNameLabel.text = self.action.groupName;
    self.actionSubjectLabel.text = self.action.subject;
    self.actionTitleLabel.text = self.action.title;
    self.actionBodyTextView.text = self.action.body;
    
    
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"TAKE ACTION";
    
    [self.takeActionButton setTitle:@"Contact My Representatives" forState:UIControlStateNormal];
    self.takeActionButton.layer.cornerRadius = kButtonCornerRadius;
    
    [self setGroupImageFromURL:self.action.groupImageURL];
    
    [self setFont];
}

- (void)viewDidLayoutSubviews {
    [self.actionBodyTextView setContentOffset:CGPointZero animated:NO];
}

- (void)setFont {
    self.groupNameLabel.font = [UIFont voicesFontWithSize:19];
    self.groupNameLabel.minimumScaleFactor = 0.75;
    [self.groupNameLabel sizeToFit];
    
    self.actionSubjectLabel.font = [UIFont voicesFontWithSize:17];
    self.actionTitleLabel.font = [UIFont voicesBoldFontWithSize:19];
    self.takeActionButton.titleLabel.font = [UIFont voicesFontWithSize:21];
    self.moreInfoLabel.font = [UIFont voicesBoldFontWithSize:17];
    self.actionBodyTextView.font = [UIFont voicesFontWithSize:19];
}
- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImage.contentMode = UIViewContentModeScaleToFill;
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
    self.groupImage.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
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
