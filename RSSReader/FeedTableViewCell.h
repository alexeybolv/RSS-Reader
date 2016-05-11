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

@property (strong,nonatomic) Feed *localFeedEntity;

@property (weak, nonatomic) IBOutlet UILabel *feedDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *feedImageView;
@property (weak, nonatomic) IBOutlet UITextView *feedTitleTextView;


-(void) setInternalFields:(Feed *)incomingEntity;

@end
