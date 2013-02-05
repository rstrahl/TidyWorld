//
//  Alarm.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-05.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSNumber * hasProblem;
@property (nonatomic, retain) NSNumber * repeat;
@property (nonatomic, retain) NSNumber * snooze;
@property (nonatomic, retain) NSString * sound_id;
@property (nonatomic, retain) NSString * sound_name;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * time_snooze;
@property (nonatomic, retain) NSString * title;

@end
