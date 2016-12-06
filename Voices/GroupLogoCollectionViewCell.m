//
//  GroupCollectionViewCell.m
//  Voices
//
//  Created by perrin cloutier on 12/5/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "GroupLogoCollectionViewCell.h"

@interface GroupLogoCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UIButton *followGroupButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *policyPositionsRef;
// properties to be recreated

//@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
//@property (weak, nonatomic) IBOutlet UILabel *groupTypeLabel;
//@property (weak, nonatomic) IBOutlet UIButton *followGroupButton;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UILabel *policyPositionsLabel;
//@property (weak, nonatomic) IBOutlet UITextView *groupDescriptionTextview;
//@property (weak, nonatomic) IBOutlet UIView *lineView;


@end

@implementation GroupLogoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.followGroupButton.layer.cornerRadius = kButtonCornerRadius;
    self.followGroupButton.titleLabel.font = [UIFont voicesFontWithSize:21];
    [self setGroupImageFromURL:self.group.groupImageURL];
    self.groupImageView.backgroundColor = [UIColor clearColor];
    [self observeFollowStatus];
    


}
- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImageView.contentMode = UIViewContentModeScaleToFill;
    self.groupImageView.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageView.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Action image success");
        self.groupImageView.image = image;
        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Action image failure");
    }];
}



- (void)observeFollowStatus {
    
//    [[[[self.usersRef child:self.currentUserID] child:@"groups"]child:self.group.key] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        
//        if (snapshot.value != [NSNull null]) {
//            
//            if ([self.followGroupButton.titleLabel.text isEqualToString:@"Following ▾"]) {
//                [self.followGroupButton setTitle:@"Follow This Group" forState:UIControlStateNormal];
//            }
//            else {
//                [self.followGroupButton setTitle:@"Following ▾" forState:UIControlStateNormal];
//            }
//        }
//    }];
    //TODO: still need to observe follow status
    self.followGroupButton.titleLabel.text = @"Follow";
    [self.followGroupButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
}



#pragma mark - Firebase methods

//TODO: should this be called in the view controller?

//- (IBAction)followGroupButtonDidPress:(id)sender {
//
//    // TODO: ASK FOR NOTI PERMISSION FROM STPOPUP BEFORE ASKING FOR PERMISSION
//    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
//
//
//    NSString *groupKey = self.group.key;
//
//    [[CurrentUser sharedInstance]followGroup:groupKey WithCompletion:^(BOOL isUserFollowingGroup) {
//
//        if (!isUserFollowingGroup) {
//
//            NSLog(@"User subscribed to %@", groupKey);
//        }
//        else {
//
//            UIAlertController *alert = [UIAlertController
//                                        alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
//                                        message:@"Would you like to stop supporting this group?"
//                                        preferredStyle:UIAlertControllerStyleActionSheet];
//
//            UIAlertAction *button0 = [UIAlertAction
//                                      actionWithTitle:@"Cancel"
//                                      style:UIAlertActionStyleCancel
//                                      handler:^(UIAlertAction * action)
//                                      {}];
//
//            UIAlertAction *button1 = [UIAlertAction
//                                      actionWithTitle:@"Unfollow"
//                                      style:UIAlertActionStyleDestructive
//                                      handler:^(UIAlertAction * action) {
//
//                                          // Remove group
//                                          [[CurrentUser sharedInstance]removeGroup:self.group];
//
//                                          // read the value once to see if group key exists
//                                          [[[[self.usersRef child:self.currentUserID] child:@"groups"]child:self.group.key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//                                              if (snapshot.value == [NSNull null]) {
//
//                                                  [self.followGroupButton setTitle:@"Follow This Group" forState:UIControlStateNormal];
//
//                                              }
//                                          } withCancelBlock:^(NSError * _Nonnull error) {
//                                              NSLog(@"%@", error.localizedDescription);
//                                          }];
//                                      }];
//
//            [alert addAction:button0];
//            [alert addAction:button1];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
//    } onError:^(NSError *error) {
//        NSLog(@"%@", error);
//    }];
//}




@end
