//
//  ShareCollectionViewCell.m
//  Voices
//
//  Created by Daniel Nomura on 2/2/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ShareCollectionViewCell.h"
#import "VoicesConstants.h"

@implementation ShareCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = kShareCollectionViewCellRadius;
}

@end
