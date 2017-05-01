//
//  ActionRepCollectionViewCell.m
//  Voices
//
//  Created by Bogil, John on 2/15/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionRepCollectionViewCell.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

@interface ActionRepCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) Representative *representative;

@end

@implementation ActionRepCollectionViewCell

- (void)setupWithRepresentative:(Representative *)rep {
    
    self.representative = rep;
    [self fetchRepImages];
    self.layer.cornerRadius = kButtonCornerRadius;
}

- (void)configureAsSelected:(BOOL)selected {
    if (selected) {
        self.layer.borderColor = [UIColor greenColor].CGColor;
        self.layer.borderWidth = 3.f;
    }
    else {
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 2.f;
    }
}

- (void)prepareForReuse {
    [self configureAsSelected:NO];
}

- (void)fetchRepImages {
    
    self.image.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *placeholderImage;
    if ([self.representative.gender isEqualToString:@"M"]) {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageMale];
    }
    else {
        placeholderImage = [UIImage imageNamed:kRepDefaultImageFemale];
    }
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.representative.photoURL
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.image setImageWithURLRequest:imageRequest placeholderImage:placeholderImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        
        self.image.alpha = 0;
        [UIView animateWithDuration:.25 animations:^{
            self.image.image = image;
            self.image.alpha = 1.0;
        }];
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
    }];
}

@end
