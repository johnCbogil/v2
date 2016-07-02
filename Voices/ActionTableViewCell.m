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
@property (weak, nonatomic) IBOutlet UIButton *learnMoreButton;


@end

@implementation ActionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)initWithAction:(Action *)action {
    self.groupNameLabel.text = action.groupName;
    self.actionTitleTextView.text = action.title;
    self.actionSubjectLabel.text = @"Subject";
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:action.groupImageURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: @"MissingRepMale"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Action image success");
        self.groupImage.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Action image failure");
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)learnMoreButtonDidPress:(id)sender {
}


@end
