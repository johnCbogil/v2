//
//  Representative.m
//  Voices
//
//  Created by Ben Rosenfeld on 9/18/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "Representative.h"

@implementation Representative


-(void) generateDistrictName{
    if (![self.title isEqual:@"Governor"]) {
        if (self.stateName) {
            self.districtFullName = [NSString stringWithFormat:@"%@ ",self.stateName ];
        }
        else if (self.stateCode){
            self.districtFullName = [NSString stringWithFormat:@"%@ ",[self.stateCode uppercaseString]];
        }
        if(self.districtNumber){
            self.districtFullName = [self.districtFullName stringByAppendingString:[NSString stringWithFormat:@"District %@",self.districtNumber]];
        }
    }
}

- (void)initWithData:(NSDictionary *)data {
    
}

@end
