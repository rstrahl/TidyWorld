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

@protocol CloudDelegate <NSObject>

- (void)cloudWillFireLightningEffectWithDecayRate:(int)lightningEffectDecay;

@end

@interface Cloud : NSObject
{
    @private
    float               mVelocity;              //< The speed of movement
    float               mLightningDecayRate;    //< The rate of alpha-decay for the cloud glow image
    float               mStrikeDelay;           //< The delay after the last lightning strike
    uint                mStrikeCounter;         //< Number of current lightning strikes to be processed
    BOOL                mMoving;                //< Flag indicating if cloud is considered moving
    SpriteDirection     mDirection;             //< Direction of movement
    CCSprite            *mCloudBase;            //< Base cloud sprite
    CCSprite            *mCloudHighlight;       //< Highlight cloud sprite
    CCSprite            *mCloudLightning;       //< Lightning glow cloud sprite
    CCSprite            *mLightningBolt;        //< Lightning bolt entity
    CGPoint             mPosition;              //< Position of the cloud entity
    BOOL                mLightningFiring;       //< Flag indicating if cloud is currently animating lightning
    id                  __unsafe_unretained mCloudDelegate;
}

@property (nonatomic, assign, getter = isMoving) BOOL moving;
@property (nonatomic, strong) CCSprite *cloudBase;
@property (nonatomic, strong) CCSprite *cloudHighlight;
@property (nonatomic, strong) CCSprite *cloudLightning;
@property (nonatomic, strong) CCSprite *lightningBolt;
@property (nonatomic, assign) id cloudDelegate;

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
