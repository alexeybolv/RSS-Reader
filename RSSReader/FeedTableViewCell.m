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
    self.feedTitle.text = incomingEntity.feedTitle;
}

@end
