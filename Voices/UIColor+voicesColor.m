//
//  UIColor+voicesColor.m
//  Voices
//
//  Created by John Bogil on 11/1/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "UIColor+voicesColor.h"

@implementation UIColor (voicesColor)

//rgb(252,146,37)
+ (UIColor *)voicesOrange {
   // return [UIColor colorWithRed:252.0/255.0 green:146.0/255.0 blue:37.0/255.0 alpha:1];
    return [[UIColor orangeColor]colorWithAlphaComponent:.95];
}

+ (UIColor *)voicesBlack {
    return  [UIColor blackColor];
}

+ (UIColor *)voicesGray {
    return [[UIColor blackColor]colorWithAlphaComponent:0.5];
}

+ (UIColor *)voicesBlue {
    // 26, 140, 255 -- pantone
    return [UIColor colorWithRed:(26.0/255.0) green:(140.0/255.0) blue:(255.0/255.0) alpha:1];
}

+ (UIColor *)voicesLightBlue {
    // 117,201,235 -- prisma
    return [UIColor colorWithRed:(117/255.0) green:(201/255.0) blue:(235/255.0) alpha:1];
}

@end
