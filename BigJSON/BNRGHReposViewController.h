//
//  BNRGHReposViewController.h
//  BigJSON
//
//  Created by sam_smith5 on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRGHReposViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIButton *loginButton;
@property(nonatomic, strong) NSArray *repositories;

-(IBAction)login:(id)sender;

@end
