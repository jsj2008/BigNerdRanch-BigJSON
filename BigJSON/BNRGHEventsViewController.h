//
//  BNRFirstViewController.h
//  BigJSON
//
//  Created by sam_smith5 on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRGHEventsViewController : UIViewController <UITableViewDataSource, UIScrollViewDelegate>
@property(nonatomic, weak) IBOutlet UITableView *eventTable;
@end
