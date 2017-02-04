//
//  STPopupController+Voices.m
//  Voices
//
//  Created by Daniel Nomura on 2/3/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "STPopupController+Voices.h"

@implementation STPopupController (Voices)
- (void)dn_configureForVoicesWithStyle:(STPopupStyle) style {
    self.containerView.layer.cornerRadius = 10;
    self.style = style;
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    self.transitionStyle = STPopupTransitionStyleFade;
        [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[STPopupNavigationBar class]]] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];    
}

+ (STPopupController *)dn_popupControllerWithNibNamed:(NSString *) name withStyle:(STPopupStyle) style {
    UIViewController *rootViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:name owner:self options:nil] objectAtIndex:0];
    STPopupController *popupController = [STPopupController dn_popupControllerWithViewController:rootViewController withStyle:style];
    return popupController;
}

+ (STPopupController *) dn_popupControllerWithViewController:(UIViewController *)rootViewController withStyle:(STPopupStyle)style {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:rootViewController];
    [popupController dn_configureForVoicesWithStyle:style];
    return popupController;
}


@end
