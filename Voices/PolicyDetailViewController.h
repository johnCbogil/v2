//
//  PolicyDetailViewController.h
//  Voices
//
//  Created by Bogil, John on 7/7/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Firebase;

@interface PolicyDetailViewController : UIViewController

@property (strong, nonatomic) FIRDatabaseReference *policyRef;

@end
