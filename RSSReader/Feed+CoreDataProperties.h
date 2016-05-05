//
//  Feed+CoreDataProperties.h
//  RSSReader
//
//  Created by Алексей on 05.05.16.
//  Copyright © 2016 Alexey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Feed.h"

NS_ASSUME_NONNULL_BEGIN

@interface Feed (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *feedDate;
@property (nullable, nonatomic, retain) NSString *feedDescription;
@property (nullable, nonatomic, retain) NSData *feedImageData;
@property (nullable, nonatomic, retain) NSString *feedImageURL;
@property (nullable, nonatomic, retain) NSString *feedLink;
@property (nullable, nonatomic, retain) NSString *feedTitle;

@end

NS_ASSUME_NONNULL_END
