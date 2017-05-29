//
//  ContactsView.m
//  Voices
//
//  Created by David Weissler on 5/29/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ContactsView.h"

#import "ReportingManager.h"
#import "Representative.h"
#import "ScriptManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactsView()

@property (nonatomic) UIButton *callButton;
@property (nonatomic) UIButton *emailButton;
@property (nonatomic) UIButton *tweetButton;
@property (nonatomic) Representative *representative;

@end

@implementation ContactsView

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.callButton = [[UIButton alloc] init];
    self.emailButton = [[UIButton alloc] init];
    self.tweetButton = [[UIButton alloc] init];
    
    [self.callButton setBackgroundImage:[UIImage imageNamed:@"Phone Filled" ] forState:UIControlStateNormal];
    [self.emailButton setBackgroundImage:[UIImage imageNamed:@"Message Filled" ] forState:UIControlStateNormal];
    [self.tweetButton setBackgroundImage:[UIImage imageNamed:@"Twitter Filled" ] forState:UIControlStateNormal];
    
    [self.callButton sizeToFit];
    [self.emailButton sizeToFit];
    [self.tweetButton sizeToFit];
    
    [self addSubview:self.callButton];
    [self addSubview:self.emailButton];
    [self addSubview:self.tweetButton];
    
    self.callButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.tweetButton.tintColor = [UIColor voicesOrange];
    
    [self.callButton addTarget:self action:@selector(callButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.emailButton addTarget:self action:@selector(emailButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.tweetButton addTarget:self action:@selector(tweetButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentWidth = self.frame.size.width;
    CGFloat totalButtonWidth = (CGRectGetWidth(self.callButton.frame)
                                + CGRectGetWidth(self.emailButton.frame)
                                + CGRectGetWidth(self.tweetButton.frame));
    CGFloat totalFreeSpace = contentWidth - totalButtonWidth;
    CGFloat buttonPadding = totalFreeSpace/4.f;
    
    CGRect callFrame = self.callButton.frame;
    callFrame.origin.x = buttonPadding;
    self.callButton.frame = callFrame;

    CGRect emailFrame = self.emailButton.frame;
    emailFrame.origin.x = self.callButton.frame.origin.x + self.callButton.frame.size.width + buttonPadding;
    self.emailButton.frame = emailFrame;

    CGRect tweetFrame = self.tweetButton.frame;
    tweetFrame.origin.x = self.emailButton.frame.origin.x + self.emailButton.frame.size.width + buttonPadding;
    self.tweetButton.frame = tweetFrame;
}

- (void)configureWithRepresentative:(Representative *)representative {
    self.representative = representative;
}

#pragma mark - User Actions

- (void)callButtonDidPress:(id)sender {
    if (self.callButtonTappedBlock) {
        self.callButtonTappedBlock();
        return;
    }
    
    if ([self.representative.phone isKindOfClass:[NSString class]] && self.representative.phone.length > 0) {
        NSString *confirmCallMessage;
        if (self.representative.nickname != nil && ![self.representative.nickname isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.representative.nickname];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@, do you know what to say?", self.representative.firstName, self.representative.lastName];
        }
        
        UIAlertController *confirmCallAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@ %@", self.representative.title,self.representative.firstName, self.representative.lastName]  message:confirmCallMessage preferredStyle:UIAlertControllerStyleAlert];
        //button0
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
        }]];
        //button1
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [[ReportingManager sharedInstance] reportEvent:kCALL_EVENT eventFocus:self.representative.fullName eventData:[ScriptManager sharedInstance].lastAction.key];
            NSURL* callUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.representative.phone]];
            if ([[UIApplication sharedApplication] canOpenURL:callUrl]) {
                [[UIApplication sharedApplication] openURL:callUrl];
            }
            else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This representative hasn't given us their phone number." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
            }
        }]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:confirmCallAlertController animated:YES completion:nil];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This legislator hasn't given us their phone number, try tweeting at them instead." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)emailButtonDidPress:(id)sender {
    if (self.emailButtonTappedBlock) {
        self.emailButtonTappedBlock();
        return;
    }

    if (self.representative.bioguide.length > 0) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:kRepContactFormsJSON ofType:@"json"];
        NSData *contactFormsJSON = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:nil];
        NSDictionary *contactFormsDict = [NSJSONSerialization JSONObjectWithData:contactFormsJSON options:NSJSONReadingAllowFragments error:nil];
        
        NSString *contactFormURLString = [contactFormsDict valueForKey:self.representative.bioguide];
        if (contactFormURLString.length == 0) {
            [self showEmailAlert];
            return;
        }
        NSURL *contactFormURL = [NSURL URLWithString:contactFormURLString];
        
        NSString *title = self.representative.title;
        NSString *name = self.representative.fullName;
        NSString *fullName = @"";
        if (title.length > 0 && name.length > 0) {
            fullName = [NSString stringWithFormat:@"%@ %@", title, name];
        }
        else if (name.length > 0) {
            fullName = name;
        }
        else if (title.length > 0) {
            fullName = title;
        }
        NSDictionary *notiDict = @{@"contactFormURL" : contactFormURL,
                                   @"fullName": fullName};
        [[NSNotificationCenter defaultCenter]postNotificationName:@"presentWebView" object:notiDict];
    }
    else if(self.representative.email && ![self.representative.email isKindOfClass:[NSNull class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.representative.email];
    }
    else {
        [self showEmailAlert];
    }
}

- (void)showEmailAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This legislator hasn't given us their email address, try calling instead." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Good idea" style:UIAlertActionStyleDefault handler:nil]];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)tweetButtonDidPress:(id)sender {
    if (self.tweetButtonTappedBlock) {
        self.tweetButtonTappedBlock();
        return;
    }
    
    NSURL *tURL = [NSURL URLWithString:@"twitter://"];
    if ( [[UIApplication sharedApplication] canOpenURL:tURL] ) {
        if (self.representative.twitter) {
            NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:self.representative.twitter, @"accountName", nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"presentTweetComposer" object:nil userInfo:userInfo];
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This legislator hasn't given us their Twitter handle, try calling instead." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Good idea" style:UIAlertActionStyleDefault handler:nil]];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
        }
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"Please install Twitter first." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

@end

NS_ASSUME_NONNULL_END
