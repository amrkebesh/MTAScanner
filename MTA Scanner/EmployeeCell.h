//
//  EmployeeCell.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/25/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrainerListViewController.h"
#import "EditScansViewController.h"
@interface EmployeeCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *passNumber;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIButton *removeButton;
@property (strong, nonatomic) UIViewController *list;
@property (strong, nonatomic) NSMutableArray *employees;

@end
