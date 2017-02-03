//
//  UIViewController+PresentSTPopup.m
//  Voices
//
//  Created by Daniel Nomura on 2/3/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "UIViewController+PresentSTPopup.h"

@implementation UIViewController (PresentSTPopup)
- (void)setupAndPresentSTPopupControllerWithNibNamed:(NSString *) name inViewController:(UIViewController *)viewController  {
    UIViewController *infoViewController = (UIViewController *)[[[NSBundle mainBundle] loadNibNamed:name owner:viewController options:nil] objectAtIndex:0];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    [self dn_configurePopupControllerForVoices:popupController];
    [popupController presentInViewController:viewController];
}

- (void)dn_configurePopupControllerForVoices: (STPopupController *) popupController {
    popupController.containerView.layer.cornerRadius = 10;
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
//    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[STPopupNavigationBar class]]] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];

}

@end
