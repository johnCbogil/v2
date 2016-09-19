//
//  RepresentativeDetailViewController.h
//  Voices
//
//  Created by Ben Rosenfeld on 8/25/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FederalRepresentative.h"
#import "StateRepresentative.h"
#import "NYCRepresentative.h"
#import "UIImageView+AFNetworking.h"


@interface RepresentativeDetailViewController : UIViewController <UIAlertViewDelegate>


@property (strong, nonatomic) Representative *representative;


@property (weak, nonatomic) IBOutlet UIImageView *repImageView;

@property (weak, nonatomic) IBOutlet UILabel *nextElection;

@property (weak, nonatomic) IBOutlet UILabel *repTitle;

@property (weak, nonatomic) IBOutlet UILabel *repName;

@property (weak, nonatomic) IBOutlet UILabel *repPartyDistrict;

@property (weak, nonatomic) IBOutlet UIView *contactRepContainter;

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;


-(void)fillInData; 



- (IBAction)didPressCallButton:(id)sender;

- (IBAction)didPressEmailButton:(id)sender;

- (IBAction)didPressTweetButton:(id)sender;



@end
