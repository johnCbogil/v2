//
//  ScriptManager.m
//  Voices
//
//  Created by Bogil, John on 12/9/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ScriptManager.h"

@implementation ScriptManager


+ (ScriptManager *) sharedInstance {
    static ScriptManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.script = self.lastAction.script;
    }
    return self;
}


@end
