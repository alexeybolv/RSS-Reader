//
//  FeedTableViewCell.m
//  RSSReader
//
//  Created by Алексей on 05.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import "FeedTableViewCell.h"

@implementation FeedTableViewCell

-(void) setInternalFields:(Feed *)incomingEntity{
    self.textView.text = incomingEntity.feedTitle;
    self.leftLabel.text = incomingEntity.feedDateString;
    self.feedImageView.image = [UIImage imageNamed:@"123.jpg"];
}

@end
