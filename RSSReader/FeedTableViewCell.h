//
//  FeedTableViewCell.h
//  RSSReader
//
//  Created by Алексей on 05.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface FeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *feedTitle;
-(void) setInternalFields:(Feed *)incomingEntity;

@end
