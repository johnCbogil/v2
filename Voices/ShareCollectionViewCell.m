//
//  ShareCollectionViewCell.m
//  Voices
//
//  Created by Daniel Nomura on 2/2/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ShareCollectionViewCell.h"
#import "VoicesConstants.h"

@interface ShareCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIView *waitingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ShareCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = kShareCollectionViewCellRadius;
    self.activityIndicator.hidesWhenStopped = YES;
}

- (IBAction)didPressAppIcon:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    self.waitingView.hidden = NO;
    [self.delegate shareCollectionViewCell:self didPressApp:self.app];
}

- (void)showWaitingView {

}
- (void)hideWaitingView {
    self.waitingView.hidden = YES;
    [self.activityIndicator stopAnimating];
}

@end
