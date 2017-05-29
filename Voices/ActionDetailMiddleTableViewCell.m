//
//  ActionDetailMiddleTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailMiddleTableViewCell.h"

#import "ContactsView.h"

@interface ActionDetailMiddleTableViewCell()

@property (weak, nonatomic) IBOutlet ContactsView *contactsView;

@end

@implementation ActionDetailMiddleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contactsView.callButtonTappedBlock = ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentCaller" object:nil];
    };
    
    self.contactsView.emailButtonTappedBlock = ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentEmailComposer" object:nil];
    };
    
    self.contactsView.tweetButtonTappedBlock = ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposerInActionDetail" object:nil];
    };
}

@end
