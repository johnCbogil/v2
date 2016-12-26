//
//  NewInfoViewController.m
//  Voices
//
//  Created by John Bogil on 12/26/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NewInfoViewController.h"
#import "InfoTableViewCell.h"
#import <STPopup/STPopup.h>

@interface NewInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewInfoViewController

// TODO: MOVE TEXT TO CONSTANTS


- (instancetype)init {
    if (self = [super init]) {
   //     self.contentSizeInPopup = CGSizeMake(300, 315);
        
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
    if (indexPath.row == 0) {
        infoTableViewCell.titleLabel.text = @"Why Call";
        infoTableViewCell.descriptionLabel.text = @"Calling your representatives is the most effective way to get government to listen to you, according to political staffers. Calls are taken more seriously and have a greater impact than emails or written letters.";

    }
    else if (indexPath.row == 1) {
        infoTableViewCell.titleLabel.text = @"What to Say";
        infoTableViewCell.descriptionLabel.text = kGenericScript;
        
    }
    else if (indexPath.row == 2) {
        infoTableViewCell.titleLabel.text = @"What to Expect";
        infoTableViewCell.descriptionLabel.text = @"You will likely talk to an intern or staffer dedicated to constituent services. They will take down your name, opinion and relay that information to your representative. Many offices tally the number of constituents that call to support or oppose various issues.";
    }
    
    return infoTableViewCell;
}

//- (IBAction)closeWindowButtonDidPress:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}




@end
