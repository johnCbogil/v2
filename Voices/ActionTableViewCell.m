//
//  ActionTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "FirebaseManager.h"
@import Firebase;

@interface ActionTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *actionTitleTextView;
@property (weak, nonatomic) IBOutlet UILabel *actionSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *completionStateButton;
@property (nonatomic) Group *group;
@property (strong, nonatomic) Action *action;

@end

@implementation ActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self configureFont];
    [self configureActionButton];

    self.actionTitleTextView.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
}

- (void)configureCompletionStateButton {
    
    if (self.action.isCompleted) {
        self.completionStateButton.tintColor = [UIColor voicesGreen];
        [self.completionStateButton setImage:[UIImage imageNamed:@"checkMarkFilled"] forState:UIControlStateNormal];
    }
    else {
        self.completionStateButton.tintColor = [UIColor voicesLightGray];
        [self.completionStateButton setImage:[UIImage imageNamed:@"checkMark"] forState:UIControlStateNormal];
    }
}

- (void)configureDate:(int long)timestamp {
    
    NSDate *actionTimeStampDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateLabel.text = [dateFormatter stringFromDate:actionTimeStampDate];
}

- (void)configureActionButton {
    
    self.takeActionButton.tintColor = [UIColor whiteColor];
    self.takeActionButton.backgroundColor = [UIColor voicesOrange];
    self.takeActionButton.layer.cornerRadius = kButtonCornerRadius;
}

- (void)configureFont {
    
    self.dateLabel.font = [UIFont voicesFontWithSize:18];
    self.dateLabel.textColor = [UIColor voicesGray];

    self.groupNameLabel.textColor = [UIColor voicesBlack];
    self.groupNameLabel.font = [UIFont voicesFontWithSize:21];
    
    self.actionSubjectLabel.textColor = [UIColor voicesBlack];
    self.actionSubjectLabel.font = [UIFont voicesMediumFontWithSize:21];
    
    self.actionTitleTextView.textColor = [UIColor voicesGray];
    self.actionTitleTextView.font = [UIFont voicesFontWithSize:21];
    
    self.takeActionButton.tintColor = [UIColor voicesOrange];
    self.takeActionButton.titleLabel.font = [UIFont voicesMediumFontWithSize:17];
}

- (void)viewDidLayoutSubviews {
    [self.actionTitleTextView setContentOffset:CGPointZero animated:NO];
}

- (void)initWithGroup:(Group *)group andAction:(Action *)action {
    
    self.action = action;
    self.group = group;
    self.groupNameLabel.text = group.name;
    self.actionTitleTextView.text = action.title;
    self.actionSubjectLabel.text = action.subject;
    [self setGroupImageFromURL:self.group.groupImageURL];
    [self configureDate:action.timestamp];
    [self configureCompletionStateButton];
}

- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImage.contentMode = UIViewContentModeScaleToFill;
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
    self.groupImage.clipsToBounds = YES;

    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        
        [UIView animateWithDuration:.25 animations:^{
            self.groupImage.image = image;
        }];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
    }];
    
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
    self.groupImage.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)completionStateButtonDidPress:(id)sender {
    
    [[FirebaseManager sharedInstance]actionCompleteButtonPressed:self.action];
    
    if (self.action.isCompleted) {
        self.action.isCompleted = NO;
        self.completionStateButton.tintColor = [UIColor voicesLightGray];
        [self.completionStateButton setImage:[UIImage imageNamed:@"checkMark"] forState:UIControlStateNormal];
    }
    else {
        self.action.isCompleted = YES;
        [self.completionStateButton setImage:[UIImage imageNamed:@"checkMarkFilled"] forState:UIControlStateNormal];
        self.completionStateButton.tintColor = [UIColor voicesGreen];
        
        [FIRAnalytics logEventWithName:@"userCompletedAction"
                            parameters:@{ @"actionKey": self.action.key}];
        
        [self.delegate presentThankYouAlertForGroup:self.group andAction:self.action];
    }
}

@end
