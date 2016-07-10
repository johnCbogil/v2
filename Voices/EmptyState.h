//
//  EmptyState.h
//  Voices
//
//  Created by John Bogil on 7/9/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EmptyState : UIView

- (instancetype)init;
- (void)updateLabels:(NSString *)top bottom:(NSString *)bottom;

@end
