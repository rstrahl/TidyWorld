//
//  RandomUtil.h
//  TidyTime
//
//  Created by Rudi Strahl on 2012-08-25.
//
//

#import <Foundation/Foundation.h>


#define ARC4RANDOM_MAX      0x100000000

@interface RandomUtil : NSObject

/// Get a random value for true or false (YES or NO)
+ (BOOL)getYesOrNo;
/// Get a random float value between 0 and 1
+ (float)getRandom0and1;
/// Get a random float value between min and max
+ (double)getRandomMin:(double)min max:(double)max;


@end
