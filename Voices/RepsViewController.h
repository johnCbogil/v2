//
//  RepsViewController.h
//  Voices
//
//  Created by Bogil, John on 1/22/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CallKit/CXCallObserver.h>
#import <CallKit/CXCall.h>


@interface RepsViewController : UIViewController<CXCallObserverDelegate>
@property (assign, nonatomic) NSInteger index;
@end
