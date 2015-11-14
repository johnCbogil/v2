//
//  CustomAlertDelegate.h
//  v2
//
//  Created by John Bogil on 11/14/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomAlertDelegate <NSObject>
- (void)presentCustomAlertWithMessage:(NSString *)message andTitle:(NSString*)title;
@end

@interface CustomAlertDelegate : NSObject

@end
