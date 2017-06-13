//
//  NewActionDetailTopTableViewCell.m
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailTopTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface NewActionDetailTopTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UIButton *groupImageButton;
@property (nonatomic)BOOL isDescriptionExpanded;
@property (weak, nonatomic) IBOutlet UILabel *takeActionLabel;

@end

@implementation NewActionDetailTopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self configureActionTitleLabel];
    [self configureExpandButton];
    self.takeActionLabel.text = @"Take Action";
    self.takeActionLabel.font = [UIFont voicesBoldFontWithSize:19];
    self.descriptionTextView.textContainer.maximumNumberOfLines = 3;
}

- (void)initWithAction:(Action *)action andGroup:(Group *)group {
    
    [self fetchGroupLogoForImageURL:group.groupImageURL];
    [self configureDescriptionTextViewWithText:action.body];
    self.actionTitleLabel.text = action.title;
}

- (void)configureActionTitleLabel {
    
    self.actionTitleLabel.backgroundColor = [UIColor whiteColor];
    self.actionTitleLabel.font = [UIFont voicesBoldFontWithSize:19];
    self.actionTitleLabel.numberOfLines = 0;
}

- (void)configureExpandButton {
    
    self.expandButton.backgroundColor = [UIColor whiteColor];
    [self.expandButton setImage:[UIImage imageNamed:@"downArrow2"] forState:UIControlStateNormal];
    [self.expandButton setTitle:nil forState:UIControlStateNormal];
    self.expandButton.tintColor = [UIColor voicesOrange];
}

- (void)configureDescriptionTextViewWithText:(NSString *)text {
    
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    self.descriptionTextView.text = text;
    self.descriptionTextView.font = [UIFont voicesFontWithSize:17];
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.descriptionTextView.scrollEnabled = NO;
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
        [UIView animateWithDuration:.25 animations:^{
            [self.groupImageButton setBackgroundImage:image forState:UIControlStateNormal];
        }];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        [UIView animateWithDuration:.25 animations:^{
            [self.groupImageButton setBackgroundImage:[UIImage imageNamed:kGroupDefaultImage] forState:UIControlStateNormal];
        }];
    }];
}

- (IBAction)expandButtonDidPress:(id)sender {
    
    if(self.isDescriptionExpanded == false){
        [self expandTextView];
    }else{
        [self contractTextView];
    }
    [self.delegate expandActionDescription:self];
}

- (void)expandTextView {
    self.isDescriptionExpanded = true;
    [self maxLines];
    [self.expandButton setImage:[UIImage imageNamed:@"upArrow2"] forState:UIControlStateNormal];
}

- (void)contractTextView {
    self.isDescriptionExpanded = false;
    [self maxLines];
    [self.expandButton setImage:[UIImage imageNamed:@"downArrow2"] forState:UIControlStateNormal];
}

- (void)maxLines {
    if(self.isDescriptionExpanded == false){
        self.descriptionTextView.textContainer.maximumNumberOfLines = 3;
    }else{
        self.descriptionTextView.textContainer.maximumNumberOfLines = 0;
    }
}

- (IBAction)groupImageButtonDidPress:(id)sender {
}

@end
