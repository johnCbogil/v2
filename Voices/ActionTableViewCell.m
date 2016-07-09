//
//  ActionTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesColor.h"
#import "VoicesConstants.h"

@interface ActionTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *actionTitleTextView;
@property (weak, nonatomic) IBOutlet UILabel *actionSubjectLabel;

@end

@implementation ActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.learnMoreButton.tintColor = [UIColor voicesOrange];
    [self setFont];
    self.actionTitleTextView.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
    
    self.learnMoreButton.tintColor = [UIColor whiteColor];
    self.learnMoreButton.backgroundColor = [UIColor voicesOrange];
    self.learnMoreButton.layer.cornerRadius = kButtonCornerRadius;
}

- (void)setFont {
    self.groupNameLabel.textColor = [UIColor voicesBlack];
    self.groupNameLabel.font = [UIFont voicesFontWithSize:19];
    
    self.actionSubjectLabel.textColor = [UIColor voicesBlack];
    self.actionSubjectLabel.font = [UIFont voicesBoldFontWithSize:19];
    
    self.actionTitleTextView.textColor = [UIColor voicesGray];
    self.actionTitleTextView.font = [UIFont voicesFontWithSize:19];
    
    self.learnMoreButton.tintColor = [UIColor voicesOrange];
    self.learnMoreButton.titleLabel.font = [UIFont voicesBoldFontWithSize:17];
}

- (void)viewDidLayoutSubviews {
    [self.actionTitleTextView setContentOffset:CGPointZero animated:NO];
}

- (void)initWithAction:(Action *)action {
    
    self.groupNameLabel.text = action.groupName;
    self.actionTitleTextView.text = action.title;
    self.actionSubjectLabel.text = action.subject;
    [self setGroupImageFromURL:action.groupImageURL];
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
    
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)learnMoreButtonDidPress:(id)sender {
}


@end
