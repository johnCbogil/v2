//
//  GroupTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupTableViewCell.h"
#import "Group.h"
#import "UIImageView+AFNetworking.h"

@interface GroupTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupType;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicatorImageView;

@end

@implementation GroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setFont];
}

- (void)setFont {
    self.groupName.font = [UIFont voicesFontWithSize:20];
    self.groupName.minimumScaleFactor = 0.75;
    self.groupType.textColor = [UIColor voicesBlack];
    self.groupType.font = [UIFont voicesFontWithSize:17];
    self.groupType.minimumScaleFactor = 0.75;
    self.groupType.textColor = [UIColor voicesGray];
    self.disclosureIndicatorImageView.tintColor = [UIColor voicesOrange];
}

- (void)initWithGroup:(Group *)group {
    self.groupName.text = group.name;
    self.groupType.text = group.groupType;
    [self setGroupImageFromURL:group.groupImageURL];
}

- (void)setGroupImageFromURL:(NSURL *)photoURL { 
    
    self.groupImage.contentMode = UIViewContentModeScaleToFill;
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
    self.groupImage.clipsToBounds = YES;

    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        
        [UIView animateWithDuration:.25 animations:^{
            self.groupImage.image = image;
        }];
        
        NSLog(@"Group image success");

    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Group image failure");
    }];
    self.groupImage.backgroundColor = [UIColor clearColor];
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
