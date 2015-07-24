//
//  ViewController.m
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "ViewController.h"
#import "LocationService.h"
#import "CongressAPI.h"
#import "OpenStatesAPI.h"
#import "InfluenceExplorerAPI.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[LocationService sharedInstance] startUpdatingLocation];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentLocation"]) {
        CongressAPI *congressRequest = [CongressAPI alloc];
        OpenStatesAPI *openStatesRequest = [OpenStatesAPI alloc];
        [congressRequest determineCongressmen:[LocationService sharedInstance].currentLocation];
        [openStatesRequest determineStateLegislators:[LocationService sharedInstance].currentLocation];
//        InfluenceExplorer *influenceExplorerRequest = [InfluenceExplorer alloc];
//        [influenceExplorerRequest idLookup:@"H001034"];
//        [influenceExplorerRequest determineTopContributors:@"640f37395b854e06857289077e8bea8a"];
//        [influenceExplorerRequest determineTopIndustries:@"640f37395b854e06857289077e8bea8a"];
    }
}
@end
