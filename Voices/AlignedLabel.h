//
//  AlignedLabel.h
//  Voices
//
//  Created by John Bogil on 7/29/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface AlignedLabel : UILabel

@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;

@end