//
//  EditScansViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/25/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmployeeCell.h"
@interface EditScansViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>
@property NSMutableArray *scans;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
