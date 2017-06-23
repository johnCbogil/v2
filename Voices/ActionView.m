//
//  ActionView
//  Voices
//
//  Created by David Weissler on 5/29/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionView.h"

#import "ReportingManager.h"
#import "Representative.h"
#import "ScriptManager.h"
#import "STPopupController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActionView()

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;

@property (nonatomic) Representative *representative;

@end

@implementation ActionView

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
    
    [[NSBundle mainBundle]loadNibNamed:@"ActionView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
    self.backgroundColor = [UIColor whiteColor];
    
    [self configureButtons];
}

- (void)configureButtons {
    
    self.callButton.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.tweetButton.tintColor = [UIColor voicesOrange];
}

- (void)configureWithRepresentative:(Representative *)representative {
    self.representative = representative;
}

#pragma mark - User Actions
- (IBAction)callButtonDidPress:(id)sender {
    
    if (self.callButtonTappedBlock) {
        self.callButtonTappedBlock();
        return;
    }
    if (self.representative.phone.length) {
        NSString *confirmCallMessage = @"Would you like to preview the call script or begin calling?";
        NSString *title;
        if (self.representative.nickname != nil && ![self.representative.nickname isEqual:[NSNull null]]) {
            title =  [NSString stringWithFormat:@"Call %@", self.representative.nickname];
        }
        else {
            title =  [NSString stringWithFormat:@"Call %@ %@", self.representative.firstName, self.representative.lastName];
        }
        
        UIAlertController *confirmCallAlertController = [UIAlertController alertControllerWithTitle:title  message:confirmCallMessage preferredStyle:UIAlertControllerStyleAlert];
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"Preview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"presentScriptView" object:nil];
            
        }]];
        [confirmCallAlertController addAction:[UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
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

        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:confirmCallAlertController animated:YES completion:^{
            [confirmCallAlertController.view.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(alertControllerBackgroundTapped)]];
        }];
    }
    else {
        
        NSString *message;
        if (self.representative) {
            message = @"This rep hasn't given us their phone number, try tweeting at them instead.";
        }
        else {
            message = @"Please select a rep first.";
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)alertControllerBackgroundTapped {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"closeAlertView" object:nil];
}

- (IBAction)emailButtonDidPress:(id)sender {
    
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This rep hasn't given us their email address, try calling instead." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Good idea" style:UIAlertActionStyleDefault handler:nil]];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)tweetButtonDidPress:(id)sender {
    
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops" message:@"This rep hasn't given us their Twitter handle, try calling instead." preferredStyle:UIAlertControllerStyleAlert];
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
