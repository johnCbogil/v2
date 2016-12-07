//
//  VCollectionViewLayout.h
//  Voices
//
//  Created by perrin cloutier on 12/6/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic) UIEdgeInsets sectionInset;


@end
