//
//  ActionDetailViewController.m
//  Voices
//
//  Created by John Bogil on 6/10/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailViewController.h"
#import "AddAddressViewController.h"
#import "ActionDetailTopTableViewCell.h"
#import "RepTableViewCell.h"
#import "ActionDetailEmptyRepTableViewCell.h"
#import "ActionDetailMenuItemTableViewCell.h"
#import "RepsManager.h"
#import "WebViewController.h"
#import "GroupDetailViewController.h"
#import "ActionDetailFooterTableViewCell.h"
#import "ActionDetailReminderViewController.h"
#import "Representative.h"

@interface ActionDetailViewController () <UITableViewDelegate, UITableViewDataSource, ExpandActionDescriptionDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listOfReps;
@property (strong, nonatomic) NSArray *listOfMenuItems;
@property (nonatomic) NSInteger indexPathRowToExpand;

@end

@implementation ActionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self configureDatasource];
    
    self.listOfMenuItems = @[@"Why it's important",@"What to say (Call Script)",@"Share action..."];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureObservers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"presentActionReminderViewController" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"presentAddAddressViewControllerFromActionDetail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"endFetchingReps" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"presentGroupDetailViewController" object:nil];
}

- (void)configureObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentReminderViewController) name:@"presentActionReminderViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAddAddressViewController) name:@"presentAddAddressViewControllerFromActionDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewFromNotification) name:@"endFetchingReps" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentGroupDetailViewController) name:@"presentGroupDetailViewController" object:nil];
}

- (void)configureDatasource {
    
    if ([self.action.actionType isEqualToString:@"singleRep"]) {
        
        Representative *rep = [[Representative alloc]initWithData:self.action.representativeDict];
        self.listOfReps = @[rep];
    }
    else {
        
        if (self.action.level == 0) {
            self.listOfReps = [RepsManager sharedInstance].fedReps;
        }
        else if (self.action.level == 1) {
            self.listOfReps = [RepsManager sharedInstance].stateReps;
        }
        else if (self.action.level == 2) {
            self.listOfReps = [RepsManager sharedInstance].localReps;
        }
    }
}

- (void)configureTableView {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName: kActionDetailTopTableViewCell bundle:nil]forCellReuseIdentifier: kActionDetailTopTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName: kRepTableViewCell bundle:nil]forCellReuseIdentifier:kRepTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName: kActionDetailEmptyRepTableViewCell bundle:nil]forCellReuseIdentifier: kActionDetailEmptyRepTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName: kActionDetailMenuItemTableViewCell bundle:nil]forCellReuseIdentifier: kActionDetailMenuItemTableViewCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionDetailFooterTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionDetailFooterTableViewCell"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.estimatedRowHeight = 300.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)reloadTableViewFromNotification {
    
    [self configureDatasource];
    [self.tableView reloadData];
}

- (void)expandActionDescription:(ActionDetailTopTableViewCell *)sender {
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.listOfReps.count) {
        return self.listOfReps.count + self.listOfMenuItems.count + 2;
    }
    else {
        return self.listOfReps.count + self.listOfMenuItems.count + 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ActionDetailTopTableViewCell *cell = (ActionDetailTopTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kActionDetailTopTableViewCell forIndexPath:indexPath];
        [cell initWithAction:self.action andGroup:self.group];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
        
        ActionDetailMenuItemTableViewCell *cell = (ActionDetailMenuItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kActionDetailMenuItemTableViewCell forIndexPath:indexPath];
        cell.itemTitle.numberOfLines = 0;
        cell.itemTitle.delegate = self;
        if (self.indexPathRowToExpand == indexPath.row) {
            
            cell.openCloseMenuItemImageView.image = [UIImage imageNamed:@"Minus"];
            if (indexPath.row == 1) {
                cell.itemTitle.text = self.action.body;
            }
            else if (indexPath.row == 2) {
                cell.itemTitle.text = self.action.script;
            }
        }
        else {
            if (indexPath.row == 3) {
                cell.openCloseMenuItemImageView.image = [UIImage imageNamed:@"shareIcon"];
            }
            else {
                cell.openCloseMenuItemImageView.image = [UIImage imageNamed:@"AddGroup"];
            }
            cell.itemTitle.text = self.listOfMenuItems[indexPath.row-1];
        }
        return cell;
    }
    else if (indexPath.row == 4) {
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.textLabel.font = [UIFont voicesBoldFontWithSize:21];
            cell.textLabel.text = @"Contact Reps";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        return cell;
    }
    else {
        if (self.listOfReps.count) {
            RepTableViewCell *cell = (RepTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRepTableViewCell forIndexPath:indexPath];
            [cell initWithRep:self.listOfReps[indexPath.row - 5]];
            return cell;
        }
        else {
            ActionDetailEmptyRepTableViewCell *cell = (ActionDetailEmptyRepTableViewCell *)[tableView dequeueReusableCellWithIdentifier: kActionDetailEmptyRepTableViewCell forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        }
    }
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.indexPathRowToExpand == indexPath.row) {
        self.indexPathRowToExpand = 0;
    }
    else if (indexPath.row == 1 || indexPath.row == 2) {
        self.indexPathRowToExpand = indexPath.row;
    }
    else if (indexPath.row == 3) {
        NSString *shareString = [NSString stringWithFormat:@"Hey, please help me support %@. %@.\n\n https://tryvoices.com/%@", self.group.name, self.action.title,self.group.key];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString]applicationActivities:nil];
        [self.navigationController presentViewController:activityViewController
                                                animated:YES
                                              completion:^{
                                              }];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.listOfReps.count && indexPath.row > 0) {
        return 140.0f;
    }
    else {
        return 300.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    ActionDetailFooterTableViewCell *cell = (ActionDetailFooterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionDetailFooterTableViewCell"];
    cell.action = self.action;
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ActionDetailFooterTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // have to wrap the cell in a view bc the cell disappears when rep cells are selected.
    UIView *view = [[UIView alloc] init];
    [view addSubview:cell];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 75.0f;
}

- (void)presentAddAddressViewController {
    
    NSLog(@"PRESENTING ADDRESSVC");
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    AddAddressViewController *addAddressViewController = (AddAddressViewController *)[repsSB instantiateViewControllerWithIdentifier:@"AddAddressViewController"];
    addAddressViewController.title = @"Add Home Address";
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:addAddressViewController animated:YES];
}

- (void)presentGroupDetailViewController {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    backButtonItem.tintColor = [UIColor voicesOrange];
    [self.navigationItem setBackBarButtonItem:backButtonItem];

    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[takeActionSB instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
    groupDetailViewController.group = self.group;
    [self.navigationController pushViewController:groupDetailViewController animated:YES];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    [self presentWebViewController:url];
}

- (void)presentWebViewController:(NSURL *)url {
    
    UIStoryboard *repsSB = [UIStoryboard storyboardWithName:@"Reps" bundle: nil];
    WebViewController *webViewController = (WebViewController *)[repsSB instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = url;
    webViewController.title = @"TAKE ACTION";
    self.navigationItem.title = @"";
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)presentReminderViewController {
    
    UIStoryboard *takeActionSB = [UIStoryboard storyboardWithName:@"TakeAction" bundle: nil];
    ActionDetailReminderViewController *reminderVC = (ActionDetailReminderViewController *)[takeActionSB instantiateViewControllerWithIdentifier:@"ActionDetailReminderViewController"];
    reminderVC.title = @"Remind Me";
    self.navigationItem.title = @"";
//    [self presentViewController:reminderVC animated:YES completion:nil];
    [self.navigationController pushViewController:reminderVC animated:YES];
}

@end
