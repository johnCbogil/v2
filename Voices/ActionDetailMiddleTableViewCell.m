//
//  ActionDetailMiddleTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailMiddleTableViewCell.h"
#import "ActionsContainerView.h"

@interface ActionDetailMiddleTableViewCell()

@property (weak, nonatomic) IBOutlet ActionsContainerView *actionsContainerView;

@end

@implementation ActionDetailMiddleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.actionsContainerView.callButtonTappedBlock = ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentCaller" object:nil];
    };
    
    self.actionsContainerView.emailButtonTappedBlock = ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentEmailComposer" object:nil];
    };
    
    self.actionsContainerView.tweetButtonTappedBlock = ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposerInActionDetail" object:nil];
    };
}

@end
