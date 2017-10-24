//
//  VoicesUtilities.m
//  Voices
//
//  Created by John Bogil on 5/11/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "VoicesUtilities.h"

@implementation VoicesUtilities

+ (NSString *)getRandomEmoji {
    
    NSMutableArray *array = @[].mutableCopy;
    NSString *listOfEmojis = @"👩🏻‍💼👨🏻‍💼👩🏾‍⚖️👨🏻‍⚖️👩🏾‍💼👨🏼‍💼👩🏽‍⚖️👨🏼‍⚖️👩🏼‍💼👨🏽‍💼👩🏽‍💼👨🏽‍⚖️👩🏼‍⚖️👨🏾‍💼👩🏻‍⚖️👨🏾‍⚖️";
    listOfEmojis = [listOfEmojis stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [listOfEmojis enumerateSubstringsInRange:NSMakeRange(0, listOfEmojis.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        [array addObject:substring];
    }];
    
    NSUInteger randomIndex = arc4random() % [array count];
    return array[randomIndex];
}

+ (BOOL)isInDebugMode {
#if DEBUG
    return YES;
#else
    return NO;
#endif
}

@end
