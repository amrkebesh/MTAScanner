//
//  OfflineEditScansViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 9/7/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmployeeCell.h"
@interface OfflineEditScansViewController :  UIViewController  <UITableViewDelegate, UITableViewDataSource>
@property NSMutableArray *scans;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
