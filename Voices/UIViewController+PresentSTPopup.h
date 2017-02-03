//
//  UIViewController+PresentSTPopup.h
//  Voices
//
//  Created by Daniel Nomura on 2/3/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STPopup.h>

@interface UIViewController (PresentSTPopup)
- (void)setupAndPresentSTPopupControllerWithNibNamed:(NSString *) name inViewController:(UIViewController *)viewController;
- (void)dn_configurePopupControllerForVoices:(STPopupController *) popupController;
@end
