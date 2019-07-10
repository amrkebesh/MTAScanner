//
//  EmployeeCell.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/25/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "EmployeeCell.h"

@implementation EmployeeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)removeTrainer
{
    TrainerListViewController *trainerList = (TrainerListViewController *)_list;
    CGPoint buttonPosition = [self convertPoint:CGPointZero toView: trainerList.tableView];
    NSIndexPath *indexPath = [trainerList.tableView indexPathForRowAtPoint:buttonPosition];
    [trainerList.trainers removeObjectAtIndex:indexPath.row];
    [trainerList.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[NSUserDefaults standardUserDefaults] setObject:trainerList.trainers forKey:@"trainers"];

}

-(void)removeEmployee
{
    EditScansViewController *scansList = (EditScansViewController *)_list;
    CGPoint buttonPosition = [self convertPoint:CGPointZero toView: scansList.tableView];
    NSIndexPath *indexPath = [scansList.tableView indexPathForRowAtPoint:buttonPosition];
    [scansList.scans removeObjectAtIndex:indexPath.row];
    [scansList.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

@end
