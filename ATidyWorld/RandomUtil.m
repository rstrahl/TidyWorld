//
//  RandomUtil.m
//  TidyTime
//
//  Created by Rudi Strahl on 2012-08-25.
//
//

#import "RandomUtil.h"

@implementation RandomUtil

+ (BOOL)getYesOrNo
{
    return arc4random_uniform(2);
}

+ (float)getRandom0and1
{
    return ((double)arc4random() / ARC4RANDOM_MAX);
}

+ (double)getRandomMin:(double)min max:(double)max
{
    float range = max - min;
    float val = ((float)arc4random() / ARC4RANDOM_MAX) * range + min;
    return val;
}
@end
