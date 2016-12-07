//
//  VCollectionViewLayout.m
//  Voices
//
//  Created by perrin cloutier on 12/6/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "VCollectionViewLayout.h"

@implementation VCollectionViewLayout

- (void)awakeFromNib {
    //This sets up all the sizes for me and the scroll direction.
    [super awakeFromNib];
    
    self.itemSize = CGSizeMake(75.0, 75.0);
    self.minimumInteritemSpacing = 10.0;
    self.minimumLineSpacing = 10.0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalOffset = proposedContentOffset.x + 5;
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemOffset = layoutAttributes.frame.origin.x;
        if (ABS(itemOffset - horizontalOffset) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemOffset - horizontalOffset;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}
@end
