//
//  Cloud.h
//  TidyTime
//
//  Created by Rudi Strahl on 2012-08-25.
//
//

#import "cocos2d.h"

typedef enum
{
    SpriteDirectionNone,
    SpriteDirectionUp,
    SpriteDirectionDown,
    SpriteDirectionLeft,
    SpriteDirectionRight
} SpriteDirection;

@class Lightning;

@interface Cloud : NSObject
{
    @private
    float               mVelocity;          //< The speed of movement
    float               mLightningDecayRate;    //< The rate of alpha-decay for the cloud glow image
    float               mStrikeDelay;       //< The delay after the last lightning strike
    uint                mStrikeCounter;     //< Number of current lightning strikes to be processed
    BOOL                mMoving;            //< Flag indicating if cloud is considered moving
    SpriteDirection     mDirection;         //< Direction of movement
    CCSprite            *mCloudBase;        //< Base cloud sprite
    CCSprite            *mCloudHighlight;   //< Highlight cloud sprite
    CCSprite            *mCloudLightning;   //< Lightning glow cloud sprite
    CCSprite            *mLightningBolt;    //< Lightning bolt entity
    CGPoint             mPosition;
    BOOL                mLightningFiring;   //< Flag indicating if cloud is currently animating lightning
}

@property (nonatomic, assign, getter = isMoving) BOOL moving;
@property (nonatomic, strong) CCSprite *cloudBase;
@property (nonatomic, strong) CCSprite *cloudHighlight;
@property (nonatomic, strong) CCSprite *cloudLightning;
@property (nonatomic, strong) CCSprite *lightningBolt;

- (id)initWithTextureID:(uint)textureID batchNode:(CCSpriteBatchNode *)node;
- (id)initWithTextureID:(uint)textureID speed:(float)speed scale:(float)scale batchNode:(CCSpriteBatchNode *)node;
+ (id)cloudWithTextureID:(uint)textureID batchNode:(CCSpriteBatchNode *)node;
+ (id)cloudWithTextureID:(uint)textureID speed:(float)speed scale:(float)scale batchNode:(CCSpriteBatchNode *)node;

- (CGPoint)getPosition;
- (void)setPosition:(CGPoint)position;

- (void)update:(ccTime)deltaTime;
- (void)updatePosition:(float)passedTime;

/// Fires the lightning animation sequence
- (void)fireLightningAnimationWithBolt:(BOOL)withBolt;

@end
