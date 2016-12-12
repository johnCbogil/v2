//
//  ScriptManager.h
//  Voices
//
//  Created by Bogil, John on 12/9/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"

@interface ScriptManager : NSObject

+ (ScriptManager *) sharedInstance;

@property (strong, nonatomic) Action *lastAction;


@end
