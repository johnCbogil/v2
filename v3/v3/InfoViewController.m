//
//  InfoViewController.m
//  v2
//
//  Created by John Bogil on 10/11/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "InfoViewController.h"
#import "UIColor+voicesOrange.h"
#import <STPopup/STPopup.h>

@interface InfoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeWindowButton;

@end

@implementation InfoViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Here's what to say";
        self.contentSizeInPopup = CGSizeMake(300, 315);
        //self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Add views here
    // self.view.frame.size == self.contentSizeInPopup in portrait
    // self.view.frame.size == self.landscapeContentSizeInPopup in landscape
    self.title = @"Here's what to say";
    self.contentSizeInPopup = CGSizeMake(300, 315);
    self.closeWindowButton.layer.cornerRadius = 5;
    self.closeWindowButton.backgroundColor = [UIColor voicesOrange];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeWindowButtonDidPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end