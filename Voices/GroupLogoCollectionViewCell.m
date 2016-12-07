//
//  GroupCollectionViewCell.m
//  Voices
//
//  Created by perrin cloutier on 12/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupLogoCollectionViewCell.h"
#import "UIColor+voicesColor.h"
@interface GroupLogoCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (strong, nonatomic) IBOutlet UILabel *groupName;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *policyPositionsRef;
@property (nonatomic, weak) id delegate;

@end

@implementation GroupLogoCollectionViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    [self setLabels];
 }


- (void)initWithGroup:(Group *)group {
    
    self.groupName.text = group.name;
    [self setGroupImageFromURL:group.groupImageURL];
}


- (void)setLabels {
    
    // Group Name Label
    self.groupName.font = [UIFont voicesFontWithSize:21];
    self.groupName.minimumScaleFactor = 0.75;
    self.groupName.text = self.group.name;
    
    // Follow Group Button
    self.followGroupButton.titleLabel.font = [UIFont voicesFontWithSize:19];
    [self.followGroupButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
    self.followGroupButton.layer.cornerRadius = kButtonCornerRadius;
    
    // Group Logo
    self.groupImageView.backgroundColor = [UIColor clearColor];
}


- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImageView.contentMode = UIViewContentModeScaleToFill;
    self.groupImageView.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageView.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Group image success");
        self.groupImageView.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Group image failure");
    }];
}


- (IBAction)followGroupButtonDidPress:(UICollectionViewCell *)cell {
    
    // Implementation in GroupDetailCollectionViewController
    [self.followGroupDelegate followGroupButtonDidPress:self];
}


@end
