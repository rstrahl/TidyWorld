//
//  Cloud.m
//  TidyTime
//
//  Created by Rudi Strahl on 2012-08-25.
//
//

#import "Cloud.h"
#import "RandomUtil.h"
#import "Constants.h"

@interface Cloud()
@end

@implementation Cloud

@synthesize moving = mMoving,
            cloudBase = mCloudBase,
            cloudHighlight = mCloudHighlight,
            cloudLightning = mCloudLightning,
            cloudDelegate = mCloudDelegate;

- (id)initWithTextureID:(uint)textureID batchNode:(CCSpriteBatchNode *)node
{
    if ((self = [super init]))
    {
        if (!(self = [self initWithTextureID:textureID speed:5.0 scale:1.0f batchNode:node])) return nil;
    }
    return self;
}

- (id)initWithTextureID:(uint)textureID speed:(float)speed scale:(float)scale batchNode:(CCSpriteBatchNode *)node
{
    if ((self = [super init]))
    {
        mMoving = YES;
        mDirection = SpriteDirectionLeft;
        mVelocity = speed;
        mLightningDecayRate = 255.0f;

        // Lightning sprite
        mLightningBolt = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"LightningBolt.png"]];
        CGPoint lightningAnchor = mLightningBolt.anchorPoint;
        lightningAnchor.y = 0.85;
        mLightningBolt.anchorPoint = lightningAnchor;
        mLightningBolt.position = kOffscreenSpritePoint;
        [mLightningBolt setVisible:NO];
        [node addChild:mLightningBolt];
        
        // Base cloud image
        mCloudBase = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Cloud%dBase.png", textureID]];
        [node addChild:mCloudBase];
        mCloudBase.opacity = 215;
        mCloudBase.position = kOffscreenSpritePoint;
        
        // Cloud highlight
        mCloudHighlight = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Cloud%dHighlight.png", textureID]];
        mCloudHighlight.opacity = 0;
        mCloudHighlight.position = kOffscreenSpritePoint;
        [node addChild:mCloudHighlight];
        
        // Lightning cloud image
        mCloudLightning = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"Cloud%dLightning.png", textureID]];
        mCloudLightning.opacity = 0;
        mCloudLightning.position = kOffscreenSpritePoint;
        [node addChild:mCloudLightning];
    }
    return self;
}

+ (id)cloudWithTextureID:(uint)textureID batchNode:(CCSpriteBatchNode *)node
{
    return [[Cloud alloc] initWithTextureID:textureID batchNode:node];
}

+ (id)cloudWithTextureID:(uint)textureID speed:(float)speed scale:(float)scale batchNode:(CCSpriteBatchNode *)node
{
    return [[Cloud alloc] initWithTextureID:textureID speed:speed scale:scale batchNode:node];
}

#pragma mark - Properties

- (CGPoint)getPosition
{
    return mPosition;
}

- (void)setPosition:(CGPoint)position
{
    mPosition = position;
    mCloudBase.position = mPosition;
    mCloudLightning.position = mPosition;
    mLightningBolt.position = mPosition;
}

#pragma mark - Sprite Movement
- (void)start
{
    self.moving = YES;
}

- (void)stop
{
    self.moving = NO;
}

- (void)updatePosition:(float)passedTime
{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGFloat y = mPosition.y;
    CGFloat x = mPosition.x;
    if (self.isMoving)
    {
        switch (mDirection) {
            case SpriteDirectionUp:
            {
                y -= mVelocity * passedTime;
                if (y < (0 - mCloudBase.boundingBox.size.height / 2))
                {
                    y = screenSize.height + (mCloudBase.boundingBox.size.height / 2);
                }
                break;
            }
            case SpriteDirectionDown:
            {
                y += mVelocity * passedTime;
                if (y > screenSize.height)
                {
                    y = 0 - (mCloudBase.boundingBox.size.height / 2);
                }
                break;
            }
            case SpriteDirectionLeft:
            {
                x -= mVelocity * passedTime;
                if (x < (0 - mCloudBase.boundingBox.size.width / 2))
                {
                    x = screenSize.width + (mCloudBase.boundingBox.size.width / 2);
                }
                break;
            }
            case SpriteDirectionRight:
            {
                x += mVelocity * passedTime;
                if (x > screenSize.width)
                {
                    x = 0 - (mCloudBase.boundingBox.size.width / 2);
                }
                break;
            }
            default:
                break;
        }
        mPosition = ccp(x,y);
        mCloudBase.position = mPosition;
        mCloudLightning.position = mPosition;
        mCloudHighlight.position = mPosition;
        mLightningBolt.position = mPosition;
    }
}

#pragma mark - Sprite Animations
- (void)update:(ccTime)deltaTime
{
    [self updatePosition:deltaTime];
    // Decay any present glow from lightning, otherwise process next strike
    if (mLightningFiring)
    {
        if (mCloudLightning.opacity > 0)
        {
            int opacityDecay = (mLightningDecayRate * deltaTime);
            mCloudLightning.opacity = (opacityDecay > mCloudLightning.opacity) ? 0 : mCloudLightning.opacity - opacityDecay;
            mLightningBolt.opacity = mCloudLightning.opacity;
        }
        else
        {
            if (mStrikeCounter > 0)
            {
                if (mStrikeDelay > 0)
                {
                    mStrikeDelay -= 10 * deltaTime;
                }
                else
                {
                    if ([RandomUtil getYesOrNo])
                    {
                        mStrikeDelay = [RandomUtil getRandom0and1];
                    }
                    mStrikeCounter--;
                    mLightningDecayRate = [RandomUtil getRandomMin:512 max:8096];
                    [self.cloudDelegate cloudWillFireLightningEffectWithDecayRate:mLightningDecayRate];
                    mCloudLightning.opacity = 255;
                    mLightningBolt.opacity = 255;
                }
            }
            else
            {
                mLightningFiring = NO;
            }
        }
    }
    else
    {
        if (mCloudLightning.opacity > 0 ||
            mCloudLightning.visible)
        {
            mStrikeCounter = 0;
            mStrikeDelay = 0;
            mCloudLightning.opacity = 0;
            [mCloudLightning setVisible:NO];
            mLightningBolt.opacity = 0;
            [mLightningBolt setVisible:NO];
        }
    }
}

- (void)fireLightningAnimationWithBolt:(BOOL)withBolt
{
    if (!mLightningFiring)
    {
        if (mStrikeCounter == 0)
        {
            mStrikeCounter = arc4random_uniform(4)+1;
            mLightningDecayRate = [RandomUtil getRandomMin:512 max:8096];
            [mCloudLightning setVisible:YES];
            mCloudLightning.opacity = 255;
            if (withBolt)
            {
                [mLightningBolt setVisible:YES];
                mLightningBolt.opacity = 255;
            }
            mLightningFiring = YES;
            [self.cloudDelegate cloudWillFireLightningEffectWithDecayRate:mLightningDecayRate];
        }
    }
}

@end
