//
//  ActionDetailTopTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailTopTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "GroupDetailViewController.h"

@implementation ActionDetailTopTableViewCell

// TODO: PRESSING BUTTON SHOULD BRING YOU TO GROUP

- (void)initWithAction:(Action *)action andGroup:(Group *)group {
    self.currentGroup = group;
    [self fetchGroupLogoForImageURL:group.groupImageURL];
    [self configureActionTitleLabelForText:action.title];
    self.delegate = nil;
}

- (void)configureActionTitleLabelForText:(NSString *)text {
    self.actionTitleLabel.numberOfLines = 0;
    self.actionTitleLabel.text = text;
    self.actionTitleLabel.font = [UIFont voicesFontWithSize:25];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.groupImageButton setTitle:nil forState:UIControlStateNormal];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)fetchGroupLogoForImageURL:(NSURL *)url {
    
    self.groupImageButton.backgroundColor = [UIColor clearColor];
    self.groupImageButton.imageView.contentMode = UIViewContentModeScaleToFill;
    self.groupImageButton.imageView.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageButton.imageView.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    [self.groupImageButton.imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Group image success");
        [UIView animateWithDuration:.25 animations:^{
            [self.groupImageButton setBackgroundImage:image forState:UIControlStateNormal];
        }];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        [UIView animateWithDuration:.25 animations:^{
            [self.groupImageButton setBackgroundImage:[UIImage imageNamed:kGroupDefaultImage] forState:UIControlStateNormal];
        }];
        NSLog(@"Action image failure");
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)groupImageButtonDidPress:(id)sender {
    [self.delegate delegateForCell:self];
}

@end
