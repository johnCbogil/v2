//
//  RepDetailTableViewCell.h
//  Voices
//
//  Created by John Bogil on 10/21/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contactTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contactTypeImageView;

@end
