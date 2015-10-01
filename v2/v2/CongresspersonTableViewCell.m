//
//  CongresspersonTableViewCell.m
//  v2
//
//  Created by John Bogil on 9/14/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "CongresspersonTableViewCell.h"
@interface CongresspersonTableViewCell() <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *callButton;

@end

@implementation CongresspersonTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = self.photo.frame.size.width / 2;
    
    self.photo.clipsToBounds = YES;
    
    // ADD SHADOW
    self.shadowView.backgroundColor = [UIColor clearColor];
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0,2.5);
    self.shadowView.layer.shadowOpacity = 0.5;
    self.shadowView.layer.shadowRadius = 3.0;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:100.0].CGPath;
    [self.shadowView addSubview:self.photo];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)callButtonDidPress:(id)sender {
    
    UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:@"Senator XYZ" message:@"You're about to call Senator XYZ, do you know what to say?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [confirmCallAlert show];
    confirmCallAlert.delegate = self;
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        NSLog(@"No");
    }
    else if (buttonIndex == 1) {
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:5164589308"]];
        if([[UIApplication sharedApplication] canOpenURL:callUrl])
        {
            [[UIApplication sharedApplication] openURL:callUrl];
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//
//
//
//    return self;
//}
@end