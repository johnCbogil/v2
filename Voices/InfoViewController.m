//
//  InfoViewController.h
//  Voices
//
//  Created by John Bogil on 12/26/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "InfoViewController.h"
#import "InfoTableViewCell.h"
#import <STPopup/STPopup.h>

@interface InfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InfoViewController

- (instancetype)init {
    if (self = [super init]) {

        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"InfoTableViewCell" bundle:nil]forCellReuseIdentifier:@"InfoTableViewCell"];
    
    self.title = @"Pro Tips";
    self.contentSizeInPopup = CGSizeMake(self.view.frame.size.width * .85, self.view.frame.size.height * .65);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    InfoTableViewCell *infoTableViewCell = [[InfoTableViewCell alloc]init];
    infoTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"InfoTableViewCell"];
    
    NSMutableAttributedString *attributedString;
    
    if (indexPath.row == 0) {
        infoTableViewCell.titleLabel.text = @"Why Call";
        
        attributedString = [[NSMutableAttributedString alloc] initWithString:kWhyCall];
    

    }
    else if (indexPath.row == 1) {
        infoTableViewCell.titleLabel.text = @"What to Say";
        attributedString = [[NSMutableAttributedString alloc] initWithString:kGenericScript];
        
    }
    else if (indexPath.row == 2) {
        infoTableViewCell.titleLabel.text = @"What to Expect";
        attributedString = [[NSMutableAttributedString alloc] initWithString:kWhatToExpect];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:7.5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    infoTableViewCell.descriptionLabel.attributedText = attributedString;

    
    return infoTableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
