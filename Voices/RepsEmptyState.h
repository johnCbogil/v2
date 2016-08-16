//
//  RepsEmptyState.h
//  Voices
//
//  Created by Bogil, John on 8/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepsEmptyState : UIView

- (instancetype)init;
- (void)updateLabels:(NSString *)top bottom:(NSString *)bottom;
- (void)updateImage;

@end
