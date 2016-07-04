//
//  GroupTableViewCell.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIFont+voicesFont.h"
#import "VoicesConstants.h"

@interface GroupTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupType;

@end

@implementation GroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.groupImage.contentMode = UIViewContentModeScaleToFill;
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
    self.groupImage.clipsToBounds = YES;
    [self setFont];
}

- (void)initWithGroup:(Group *)group {
    self.groupName.text = group.name;
    self.groupType.text = group.groupType;
    [self setImageFromPhotoURL:group.groupImageURL];
}

- (void)setImageFromPhotoURL:(NSURL *)photoURL{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"MissingRepMale"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.groupImage.image = image;
        NSLog(@"Group image success");

    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Group image failure");
    }];
    
    self.groupImage.layer.cornerRadius = kButtonCornerRadius;
}

- (void)setFont {
//    self.groupName.font = [UIFont voicesFontWithSize:24];
//    [self.groupName sizeToFit];
//    self.groupType.font = [UIFont voicesFontWithSize:18];
//    self.groupDescription.font = [UIFont voicesFontWithSize:15];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
