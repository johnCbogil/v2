//
//  StoryboardPlaceHolderViewController.m
//  v3
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "StoryboardPlaceHolderViewController.h"

@interface StoryboardPlaceHolderViewController ()
@property (nonatomic, strong) UIViewController *storyboardViewController;
@end

@implementation StoryboardPlaceHolderViewController

- (Class)class { return [self.storyboardViewController class]; }

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)storyboardViewController {
    if(_storyboardViewController == nil)
    {
        UIStoryboard *storyboard = nil;
        NSString *identifier = self.restorationIdentifier;
        
        if(identifier)
        {
            @try {
                storyboard = [UIStoryboard storyboardWithName:identifier bundle:nil];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception (%@): Unable to load the Storyboard titled '%@'.", exception, identifier);
            }
        }
        _storyboardViewController = [storyboard instantiateInitialViewController];
    }
    return _storyboardViewController;
}

- (UINavigationItem *)navigationItem {
    return self.storyboardViewController.navigationItem ?: [super navigationItem];
}

- (void)loadView {
    [super loadView];
    
    if(self.storyboardViewController && self.navigationController)
    {
        NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
        
        if(index != NSNotFound)
        {
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [viewControllers replaceObjectAtIndex:index withObject:self.storyboardViewController];
            [self.navigationController setViewControllers:viewControllers animated:NO];
        }
    }
}

- (UIView *)view { return self.storyboardViewController.view; }

@end