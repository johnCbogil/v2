//
//  IssueSurveyViewController.m
//  Voices
//
//  Created by Andy Wu on 3/28/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "IssueSurveyViewController.h"

@interface IssueSurveyViewController ()

@end

@implementation IssueSurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.webView.delegate = self;
    NSURL * url = [NSURL URLWithString:self.urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
