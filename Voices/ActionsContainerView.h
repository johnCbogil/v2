//
//  ActionsContainerView.h
//  Voices
//
//  Created by David Weissler on 5/29/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Representative;

NS_ASSUME_NONNULL_BEGIN

@interface ActionsContainerView : UIView

@property (nonatomic, copy, nullable) void (^callButtonTappedBlock)(void);
@property (nonatomic, copy, nullable) void (^emailButtonTappedBlock)(void);
@property (nonatomic, copy, nullable) void (^tweetButtonTappedBlock)(void);
@property (strong, nonatomic) IBOutlet UIView *contentView;


- (void)configureWithRepresentative:(Representative *)representative;

@end

NS_ASSUME_NONNULL_END
