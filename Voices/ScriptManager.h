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
@property (strong, nonatomic) NSString *script;
@property (strong, nonatomic) NSString *twitterScript;
@property (strong, nonatomic) NSString *emailScript;

@end
