//
//  CustomPageControl.m
//  Voices
//
//  Created by Bogil, John on 8/15/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.activeImage = [UIImage imageNamed:@"active_dot.png"];
        self.inactiveImage = [UIImage imageNamed:@"inactive_dot.png"];
    }
    return self;
}

-(void)updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, 14, 14.5);
        if (i == self.currentPage)
            dot.image = self.activeImage;
        else
            dot.image = self.inactiveImage;
    }
}

-(void)setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

@end
