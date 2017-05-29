//
//  ContactsView.h
//  Voices
//
//  Created by David Weissler on 5/29/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Representative;

NS_ASSUME_NONNULL_BEGIN

@interface ContactsView : UIView

@property (nonatomic, copy, nullable) void (^callButtonTappedBlock)(void);
@property (nonatomic, copy, nullable) void (^emailButtonTappedBlock)(void);
@property (nonatomic, copy, nullable) void (^tweetButtonTappedBlock)(void);


- (void)configureWithRepresentative:(Representative *)representative;

@end

NS_ASSUME_NONNULL_END
