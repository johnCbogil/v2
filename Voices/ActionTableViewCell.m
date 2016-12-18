//
//  ActionTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/19/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface ActionTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *actionTitleTextView;
@property (weak, nonatomic) IBOutlet UILabel *actionSubjectLabel;
@property (nonatomic) Group *group;
@property (nonatomic) NSString *currentUserID;
@end

@implementation ActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.takeActionButton.tintColor = [UIColor voicesOrange];
    [self setFont];
    self.actionTitleTextView.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
    
    self.takeActionButton.tintColor = [UIColor whiteColor];
    self.takeActionButton.backgroundColor = [UIColor voicesOrange];
    self.takeActionButton.layer.cornerRadius = kButtonCornerRadius;
}

- (void)setFont {
    self.groupNameLabel.textColor = [UIColor voicesBlack];
    self.groupNameLabel.font = [UIFont voicesFontWithSize:19];
    
    self.actionSubjectLabel.textColor = [UIColor voicesBlack];
    self.actionSubjectLabel.font = [UIFont voicesMediumFontWithSize:19];
    
    self.actionTitleTextView.textColor = [UIColor voicesGray];
    self.actionTitleTextView.font = [UIFont voicesFontWithSize:19];
    
    self.takeActionButton.tintColor = [UIColor voicesOrange];
    self.takeActionButton.titleLabel.font = [UIFont voicesMediumFontWithSize:17];
}

- (void)viewDidLayoutSubviews {
    [self.actionTitleTextView setContentOffset:CGPointZero animated:NO];
}

- (void)initWithCurrentUserID:(NSString *)currentUserID andGroup:(Group *)group andAction:(Action *)action {
    
    self.group = group;
    self.currentUserID = currentUserID;
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
    
    [self.groupImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Action image success");
        
        [UIView animateWithDuration:.25 animations:^{
            self.groupImage.image = image;
        }];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Action image failure");
    }];
    
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
    self.groupImage.backgroundColor = [UIColor clearColor];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)takeActionButtonDidPress:(id)sender {
}


@end
