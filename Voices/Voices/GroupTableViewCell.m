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

@interface GroupTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupLogo;
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *groupType;
@property (weak, nonatomic) IBOutlet UILabel *groupDescription;

@end

@implementation GroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.groupLogo.contentMode = UIViewContentModeScaleToFill;
    self.groupLogo.layer.cornerRadius = 5;
    self.groupLogo.clipsToBounds = YES;
    [self setFont];
}

- (void)initWithData:(id) data {
    self.groupName.text = [data valueForKey:@"Name"];
    self.groupType.text = [data valueForKey:@"Type"];
    self.groupDescription.text = [data valueForKey:@"Description"];
    [self setImageFromPhotoURL:[NSURL URLWithString:[data valueForKey:@"PhotoURL"]]];
}

- (void)setImageFromPhotoURL:(NSURL *)photoURL{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupLogo setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"MissingRepMale"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.groupLogo.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Federal image failure");
    }];
}

- (void)setFont {
    self.groupName.font = [UIFont voicesFontWithSize:24];
    [self.groupName sizeToFit];
    self.groupType.font = [UIFont voicesFontWithSize:18];
    self.groupDescription.font = [UIFont voicesFontWithSize:15];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
