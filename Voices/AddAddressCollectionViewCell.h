//
//  AddAddressCollectionViewCell.h
//  Voices
//
//  Created by John Bogil on 5/6/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddAddressCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *addAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
@property (weak, nonatomic) IBOutlet UIButton *addAddressButton;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;

@end
