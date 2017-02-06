//
//  ShareCollectionViewCell.h
//  Voices
//
//  Created by Daniel Nomura on 2/2/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareCollectionViewController.h"

@class ShareCollectionViewCell;
@protocol ShareCollectionViewCellDelegate <NSObject>
- (void)shareCollectionViewCell:(ShareCollectionViewCell *)sender didPressApp:(SocialMediaApp)app;
@end

@interface ShareCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *appIconButton;
@property (weak, nonatomic) id <ShareCollectionViewCellDelegate> delegate;
@property (nonatomic) SocialMediaApp app;
- (void)hideWaitingView;
@end


