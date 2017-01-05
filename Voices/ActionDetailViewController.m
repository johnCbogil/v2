//
//  ActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 7/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "GroupDetailViewController.h"
#import "ScriptManager.h"


@interface ActionDetailViewController()

@property (weak, nonatomic) IBOutlet UIButton *groupImageButton;
//@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *takeActionButton;
@property (weak, nonatomic) IBOutlet UITextView *actionBodyTextView;

@end

@implementation ActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.groupNameLabel.text = self.action.groupName;
    self.actionSubjectLabel.text = self.action.subject;
    self.actionTitleLabel.text = self.action.title;
    self.actionBodyTextView.text = self.action.body;
    self.actionBodyTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.actionBodyTextView.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    self.title = @"TAKE ACTION";
    [self.takeActionButton setTitle:@"Contact My Representatives" forState:UIControlStateNormal];
    self.takeActionButton.layer.cornerRadius = kButtonCornerRadius;
    
    // TODO: IF THERE IS NO SELF.GROUP.GROUPIMAGEURL, THEN FETCH FROM FB
    
    [self setGroupImageFromURL:self.group.groupImageURL];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    [self setFont];
}

- (void)viewDidLayoutSubviews {
    [self.actionBodyTextView setContentOffset:CGPointZero animated:NO];
}

- (void)setFont {
    self.groupNameLabel.font = [UIFont voicesFontWithSize:24];
    self.groupNameLabel.minimumScaleFactor = 0.75;
    [self.groupNameLabel sizeToFit];
    
    self.actionSubjectLabel.font = [UIFont voicesMediumFontWithSize:17];
    self.actionTitleLabel.font = [UIFont voicesMediumFontWithSize:19];
    self.takeActionButton.titleLabel.font = [UIFont voicesFontWithSize:21];
    self.actionBodyTextView.font = [UIFont voicesFontWithSize:19];
}

- (void)setGroupImageFromURL:(NSURL *)url {
    
    self.groupImageButton.imageView.contentMode = UIViewContentModeScaleToFill;
    self.groupImageButton.imageView.layer.cornerRadius = kButtonCornerRadius;
    self.groupImageButton.imageView.clipsToBounds = YES;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    
    [self.groupImageButton.imageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed: kGroupDefaultImage] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image) {
        NSLog(@"Action image success");
        
        [UIView animateWithDuration:.25 animations:^{
            [self.groupImageButton setBackgroundImage:image forState:UIControlStateNormal];
        }];

        
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
        NSLog(@"Action image failure");
    }];
}

- (IBAction)takeActionButtonDidPress:(id)sender {
    
    [ScriptManager sharedInstance].lastAction = self.action;
    
    self.tabBarController.selectedIndex = 0;
    NSNumber *level = [NSNumber numberWithInt:self.action.level];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"actionPageJump" object:level];
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    ActionWebViewController *webVC = [[ActionWebViewController alloc]init];
    webVC.linkURL = URL;
    [self.navigationController pushViewController:webVC animated:YES];
    return NO;
}

- (IBAction)groupImagePressed:(id)sender {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButtonItem];
    
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
    groupDetailViewController.group = self.group;
    [self.navigationController pushViewController:groupDetailViewController animated:YES];
}
@end
