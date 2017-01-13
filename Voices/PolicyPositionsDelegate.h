//
//  PolicyPositionsDelegate.h
//  Voices
//
//  Created by perrin cloutier on 1/13/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PolicyPositionsDelegate <NSObject>


@required

- (void)presentPolicyDetailViewController:(NSIndexPath *)indexPath;

@end

 
