//
//  UIFont+voicesFont.m
//  v3
//
//  Created by John Bogil on 11/1/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "UIFont+voicesFont.h"
#import "VoicesConstants.h"

@implementation UIFont (voicesFont)
+ (UIFont*)voicesFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:kAvenirNextRegular size:size];
}
@end
