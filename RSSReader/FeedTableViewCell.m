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
    self.feedTitleTextView.text = [self newTitleWithoutTagFromString:incomingEntity.feedTitle];
    self.feedDateLabel.text = [self shortDateToStringFromDate:incomingEntity.feedDate];
    self.feedImageView.image = [UIImage imageWithData:incomingEntity.feedImageData];
    self.localFeedEntity = incomingEntity;
}

-(NSString *) newTitleWithoutTagFromString:(NSString *)myStr
{
    NSRange range = [myStr rangeOfString:@"&nbsp;"];
    if (range.length>0){
        NSMutableString *newString = [[NSMutableString alloc]initWithFormat:@"%@",myStr];
        [newString deleteCharactersInRange:NSMakeRange(range.location,range.length)];
        myStr = (NSString *)newString;
    }
    return myStr;
}

-(NSString *) shortDateToStringFromDate:(NSDate *)feedDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
    NSString *feedStringDate = [dateFormatter stringFromDate:feedDate];
    return feedStringDate;
}

@end
