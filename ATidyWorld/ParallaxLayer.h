//
//  ParallaxLayer.h
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-03-04.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SummerBaseLayer.h"

/** Layer containing a parallaxing fog effect.
 *
 */
@interface ParallaxLayer : CCLayer
{
    CCArray         *mParallaxSpriteArray;          //< Array of sprites
    int             mSpriteCount;                   //< Number of sprites contained in array
    CGSize          mSpriteSize;                    //< Size of sprite
    CGFloat         mVelocity;                      //< The horizontal velocity applied to sprites
    CGFloat         mVelocityStep;                  //< The actual change in position applied to sprite.position
    CGSize          mScreenSize;                    //< The size of the screen
    SummerBaseLayer *mSceneDelegate;                //< The scene delegate reference
}

@property (nonatomic, strong) SummerBaseLayer *sceneDelegate;

- (id)initWithSpriteBatchNode:(CCSpriteBatchNode *)batchNode;

@end
