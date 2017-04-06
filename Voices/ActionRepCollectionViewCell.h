//
//  ActionRepCollectionViewCell.h
//  Voices
//
//  Created by Bogil, John on 2/15/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Representative.h"

@interface ActionRepCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)setupWithRepresentative:(Representative *)rep;
- (void)configureAsSelected:(BOOL)selected;

@end

