//
//  ActionWebViewController.m
//  Voices
//
//  Created by Jesse Sahli on 10/21/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "ActionWebViewController.h"

@interface ActionWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURL *linkURL;
@end

@implementation ActionWebViewController
- (instancetype)initWithURL:(NSURL *) url {
    if (self != nil) {
        self.linkURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TAKE ACTION";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupWebView];
    [self createActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    self.webView.delegate = self;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.linkURL];
    [self.webView loadRequest:urlRequest];
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [NSLayoutConstraint activateConstraints:@[topConstraint, bottomConstraint, leftConstraint, rightConstraint]];
}

- (void)createActivityIndicator {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.color = [UIColor grayColor];
    self.activityIndicatorView.center = self.view.center;
    [self.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.hidden = NO;
    [self toggleActivityIndicatorOn];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [NSLayoutConstraint activateConstraints:@[verticalConstraint, horizontalConstraint]];
}

- (void)toggleActivityIndicatorOn {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView.hidden = YES;
        [self.activityIndicatorView stopAnimating];
    });
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //Check here if still webview is loding the content
    if (webView.isLoading) {
        return;
    }
    
    [self toggleActivityIndicatorOff];

}

@end
