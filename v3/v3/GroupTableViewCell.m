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

@property (weak, nonatomic) IBOutlet UIImageView *advocacyGroupLogo;
@property (weak, nonatomic) IBOutlet UILabel *advocacyGroupName;
@property (weak, nonatomic) IBOutlet UILabel *advocacyGroupType;
@property (weak, nonatomic) IBOutlet UILabel *advocacyGroupDescription;

@end

@implementation GroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.advocacyGroupLogo.contentMode = UIViewContentModeScaleToFill;
    self.advocacyGroupLogo.layer.cornerRadius = 5;
    self.advocacyGroupLogo.clipsToBounds = YES;
    [self setFont];
}

- (void)initWithData:(id) data {
    self.advocacyGroupName.text = [data valueForKey:@"Name"];
    self.advocacyGroupType.text = [data valueForKey:@"Type"];
    self.advocacyGroupDescription.text = [data valueForKey:@"Description"];
    [self setImageFromPhotoURL:[NSURL URLWithString:[data valueForKey:@"PhotoURL"]]];
}

- (void)setImageFromPhotoURL:(NSURL *)photoURL{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.advocacyGroupLogo setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"MissingRep"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        self.advocacyGroupLogo.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Federal image failure");
    }];
}

- (void)setFont {
    self.advocacyGroupName.font = [UIFont voicesFontWithSize:24];
    [self.advocacyGroupName sizeToFit];
    self.advocacyGroupType.font = [UIFont voicesFontWithSize:18];
    self.advocacyGroupDescription.font = [UIFont voicesFontWithSize:15];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
