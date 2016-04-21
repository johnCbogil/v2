//
//  TabBarViewController.m
//  Voices
//
//  Created by John Bogil on 4/17/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "TabBarViewController.h"
#import "UIColor+voicesOrange.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    for(UITabBarItem * tabBarItem in self.tabBar.items){
//        tabBarItem.title = @"";
//        tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//    }
    
    [UITabBar appearance].tintColor = [UIColor voicesOrange];
}

@end
