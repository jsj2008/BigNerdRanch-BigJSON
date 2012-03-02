//
//  BNRSecondViewController.h
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRCommitsViewController : UIViewController<UITableViewDataSource>
@property(nonatomic, weak) IBOutlet UITableView *commitTable;
@end
