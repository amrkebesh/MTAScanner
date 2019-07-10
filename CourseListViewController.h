//
//  CourseListViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/15/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseInfoViewController.h"

@interface CourseListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UIViewController* courseInfo;

@end
