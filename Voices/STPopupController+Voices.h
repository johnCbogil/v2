//
//  STPopupController+Voices.h
//  Voices
//
//  Created by Daniel Nomura on 2/3/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <STPopup/STPopup.h>
@class STPopupController;
@interface STPopupController (Voices)
- (void)dn_configureForVoicesWithStyle:(STPopupStyle) style;
+ (STPopupController *)dn_popupControllerWithNibNamed:(NSString *) name withStyle:(STPopupStyle) style;
+ (STPopupController *) dn_popupControllerWithViewController:(UIViewController *)rootViewController withStyle:(STPopupStyle)style;

@end
