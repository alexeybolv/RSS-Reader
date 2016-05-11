//
//  FeedDetailViewController.h
//  RSSReader
//
//  Created by Алексей on 08.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface FeedDetailViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *feedDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *feedImageView;

- (void) receiveFeedEntity:(Feed *)incomingFeedEntity;

@end
