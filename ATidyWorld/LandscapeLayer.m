//
//  LandscapeLayer.m
//  ATidyWorld
//
//  Created by Rudi Strahl on 2013-02-22.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "LandscapeLayer.h"
#import "SummerBaseLayer.h"
#import "Constants.h"
#import "CCNode+SFGestureRecognizers.h"
#import "ColorConverter.h"
#import "SummerBaseLayer.h"

@interface LandscapeLayer()
// Weather Effects-------------------------------------------------------------
/** Updates the positions for all landscapes based on a delta in the X position, where a value
 *  greater than 0 means the landscapes are moving towards the right and a value less than
 *  0 means the landscapes are moving towards the left
 *  @param dx the delta in the x coordinate
 */
- (void)updateLandscapePositionsWithForegroundDelta:(CGFloat)dx backgroundDelta:(CGFloat)bdx;
/** Updates the parallax effect for a given landscape based on the direction of the delta
 *  @param sprite the landscape sprite being adjusted
 *  @param i the index of that sprite within its container array
 *  @param array the container array holding the landscape sprite
 *  @param dx the delta in the x coordinate as experienced by the update positions method
 */
- (void)updateParallaxEffectForLandscapeSprite:(CCSprite *)sprite atIndex:(int)i fromArray:(CCArray *)array withDelta:(CGFloat)dx;

@end

@implementation LandscapeLayer

@synthesize sceneDelegate = mSceneDelegate,
            overcast = mOvercast;

- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate
{
    if (self = [super init])
    {
        self.sceneDelegate = sceneDelegate;
        mScreenSize = [[CCDirector sharedDirector] winSize];
        mVelocity = 0;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:SPRITESHEET_LANDSCAPE_PLIST];
        mLandscapeBatchNode = [[CCSpriteBatchNode alloc] initWithFile:SPRITESHEET_LANDSCAPE_IMAGE capacity:13];
        [self addChild:mLandscapeBatchNode];
        
        // Configure panning gesture recognition
        mPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        mPanGestureRecognizer.delegate = self;
//        mPanGestureRecognizer.cancelsTouchesInView = NO;
//        mPanGestureRecognizer.delaysTouchesEnded = NO;
        [self addGestureRecognizer:mPanGestureRecognizer];
        self.isTouchEnabled = YES;
        
        // Configure landscape sprites
        mLandscapeForegroundArray = [[CCArray alloc] initWithCapacity:kLandscapeForegroundCount];
        mLandscapeBackgroundArray = [[CCArray alloc] initWithCapacity:kLandscapeBackgroundCount];
        mLandscapeUndergroundArray = [[CCArray alloc] initWithCapacity:(mScreenSize.width / 64)+1];

        CCSprite *foregroundSprite = [[CCSprite alloc] initWithSpriteFrameName:@"LandscapeForeground1.png"];
        
        CGFloat undergroundHeight = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) ? 90 : 55;
        
        for (int i = 0; i < kLandscapeBackgroundCount; i++)
        {
            CCSprite *landscapeBackgroundSprite = [[CCSprite alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"LandscapeBackground%d.png", i+1]];
            landscapeBackgroundSprite.position = ccp((i * landscapeBackgroundSprite.boundingBox.size.width),
                                                     (undergroundHeight + (foregroundSprite.boundingBox.size.height * 0.4) + landscapeBackgroundSprite.boundingBox.size.height));
            landscapeBackgroundSprite.anchorPoint = ccp(0,1);
            [mLandscapeBackgroundArray addObject:landscapeBackgroundSprite];
            [mLandscapeBatchNode addChild:landscapeBackgroundSprite];
        }
        
        for (int i = 0; i < kLandscapeForegroundCount; i++)
        {
            CCSprite *landscapeForegroundSprite = [[CCSprite alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"LandscapeForeground%d.png", i+1]];
            landscapeForegroundSprite.position = ccp((i * landscapeForegroundSprite.boundingBox.size.width),
                                                     undergroundHeight + landscapeForegroundSprite.boundingBox.size.height);
            landscapeForegroundSprite.anchorPoint = ccp(0,1);
            [mLandscapeForegroundArray addObject:landscapeForegroundSprite];
            [mLandscapeBatchNode addChild:landscapeForegroundSprite];
            mLandscapeSpriteWidth = landscapeForegroundSprite.boundingBox.size.width;
        }
        
        for (int i = 0; i < (mScreenSize.width/64)+1; i++)
        {
            CCSprite *undergroundSprite = [[CCSprite alloc] initWithSpriteFrameName:@"LandscapeUnderground.png"];
            undergroundSprite.position = ccp((i * undergroundSprite.boundingBox.size.width),
                                             undergroundHeight);
            undergroundSprite.anchorPoint = ccp(0,1);
            [mLandscapeUndergroundArray addObject:undergroundSprite];
            [mLandscapeBatchNode addChild:undergroundSprite];
        }
        
        [self scheduleUpdate];
    }
    return self;
}

#pragma mark - Game Loop Update
- (void)update:(ccTime)deltaTime
{
    if (mVelocity != 0)
    {
        // Update position
        mVelocityStep += (mVelocity * deltaTime);
        mBackgroundVelocityStep += (mVelocity * deltaTime) / 2;
        if (fabsf(mVelocityStep) >= 1)
        {
            [self updateLandscapePositionsWithForegroundDelta:mVelocityStep backgroundDelta:mBackgroundVelocityStep];
            mVelocityStep = (mVelocityStep > 0) ? mVelocityStep - floorf(mVelocityStep) : mVelocityStep - ceilf(mVelocityStep);
    //        mVelocityStep -= floorf(mVelocityStep);
            if (fabsf(mBackgroundVelocityStep) >= 1)
            {
                mBackgroundVelocityStep = (mBackgroundVelocityStep > 0) ? mBackgroundVelocityStep - floorf(mBackgroundVelocityStep) : mBackgroundVelocityStep - ceilf(mBackgroundVelocityStep);
    //            mBackgroundVelocityStep -= floorf(mBackgroundVelocityStep);
            }
        }
    }
    
    // Update weather effect - lightning illumination
    if (mLightningDecayRate > 0)
    {
        mLastLightningTint -= (mLightningDecayRate * deltaTime);
        if (mLastLightningTint < 0)
        {
            mLastLightningTint = 0;
            [self setLandscapeIllumination:mLastDaylightTint];
        }
        else
        {
            [self setLandscapeIllumination:mLastLightningTint];
        }
    }
}

- (void)updateLandscapePositionsWithForegroundDelta:(CGFloat)dx backgroundDelta:(CGFloat)bdx
{
    dx = (dx > 0) ? floorf(dx) : ceilf(dx);
    bdx = (bdx > 0)? floorf(bdx) : ceilf(bdx);
    
    for (CCSprite *foregroundLandscape in mLandscapeForegroundArray)
    {
        foregroundLandscape.position = ccp((foregroundLandscape.position.x + dx), foregroundLandscape.position.y);
    }
    for (CCSprite *undergroundLandscape in mLandscapeUndergroundArray)
    {
        undergroundLandscape.position = ccp((undergroundLandscape.position.x + dx), undergroundLandscape.position.y);
    }
    for (CCSprite *backgroundLandscape in mLandscapeBackgroundArray)
    {
        backgroundLandscape.position = ccp((backgroundLandscape.position.x + bdx), backgroundLandscape.position.y);
    }
    
    for (int i = 0; i < kLandscapeForegroundCount; i++)
    {
        CCSprite *foregroundLandscape = (CCSprite *)[mLandscapeForegroundArray objectAtIndex:i];

        
        [self updateParallaxEffectForLandscapeSprite:foregroundLandscape
                                             atIndex:i
                                           fromArray:mLandscapeForegroundArray
                                           withDelta:dx];
    }
    for (int i = 0; i < mLandscapeUndergroundArray.count; i++)
    {
        CCSprite *undergroundLandscape = (CCSprite *)[mLandscapeUndergroundArray objectAtIndex:i];
        [self updateParallaxEffectForLandscapeSprite:undergroundLandscape
                                             atIndex:i
                                           fromArray:mLandscapeUndergroundArray
                                           withDelta:dx];
    }
    
    for (int i = 0; i < kLandscapeBackgroundCount; i++)
    {
            CCSprite *backgroundLandscape = (CCSprite *)[mLandscapeBackgroundArray objectAtIndex:i];
            [self updateParallaxEffectForLandscapeSprite:backgroundLandscape
                                                 atIndex:i
                                               fromArray:mLandscapeBackgroundArray
                                               withDelta:bdx];
    }
}

- (void)updateParallaxEffectForLandscapeSprite:(CCSprite *)sprite atIndex:(int)i fromArray:(CCArray *)array withDelta:(CGFloat)dx
{
    CGFloat spriteWidth = sprite.boundingBox.size.width;
    if (dx > 0) // We're moving towards the right
    {
        if (sprite.position.x >= mScreenSize.width) // Landscape moving offscreen towards right
        {
            // Set x to the x of the i+1 neighbor minus sprite width
            int n = (i+1 == array.count) ? 0 : (i + 1);
            CCSprite *neighborLandscape = (CCSprite *)[array objectAtIndex:n];
            sprite.position = ccp(ceilf(neighborLandscape.position.x - spriteWidth), floorf(sprite.position.y));
        }
    }
    else if (dx < 0) // We're moving towards the left
    {
        if ((sprite.position.x + spriteWidth) <= 0) // Landscape moving offscreen towards left
        {
            // Set x to the x of the i-1 neighbor plus sprite width
            int n = (i-1 < 0) ? (array.count-1) : i-1;
            CCSprite *neighborLandscape = (CCSprite *)[array objectAtIndex:n];
            sprite.position = ccp(floorf(neighborLandscape.position.x + spriteWidth), floorf(sprite.position.y));
        }
    }
}

#pragma mark - Day/Night Cycle
- (void)updateDaylightTint:(int)tintValue
{
    mLastDaylightTint = tintValue;
    [self setLandscapeIllumination:mLastDaylightTint];
}

- (void)setLandscapeIllumination:(int)tintValue
{
    float h = 0, s = 0, v = 0;
    int r = 0, g = 0, b = 0;
    if (tintValue < mLastDaylightTint)
    {
        tintValue = mLastDaylightTint;
    }
    v = (float)tintValue / 255;
    v = (v < kMinLandscapeNightTintValue) ? kMinLandscapeNightTintValue : v;
    if (mOvercast)
    {
        if (mLastLightningTint > 0)
        {
            v = (mLastLightningTint/2 > kMaxOvercastTintValue) ? v : kMaxOvercastTintValue;
        }
        else
        {
            v = (v > kMaxLandscapeOvercastTintValue) ? kMaxLandscapeOvercastTintValue : v;
        }
        
    }
    hsv_to_rgb(h, s, v, &r, &g, &b);
    
    for (CCSprite *landscapeSprite in mLandscapeUndergroundArray)
    {
        landscapeSprite.color = ccc3(r, g, b);
    }
    for (CCSprite *landscapeSprite in mLandscapeForegroundArray)
    {
        landscapeSprite.color = ccc3(r, g, b);
    }
    for (CCSprite *landscapeSprite in mLandscapeBackgroundArray)
    {
        landscapeSprite.color = ccc3(r, g, b);
    }
}

#pragma mark - Weather Effects
- (void)cloudWillFireLightningEffectWithDecayRate:(int)lightningDecayRate
{
    // set the decay rate, and let the update method do the rest
    mLastLightningTint = 255;
    mLightningDecayRate = lightningDecayRate;
}

#pragma mark - Gesture Recognition
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mVelocity = 0;
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan ||
        panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
        translation.y *= -1;
        [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
//        DLog(@" %f %f", translation.x, translation.x/2);
        [self updateLandscapePositionsWithForegroundDelta:translation.x backgroundDelta:translation.x/2];
        mVelocity = 0;
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        mVelocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view].x;
        if (fabsf(mVelocity) < 50)
        {
            mVelocity = 0;
        }
    }
}

#pragma mark - GestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //! For swipe gesture recognizer we want it to be executed only if it occurs on the main layer, not any of the subnodes ( main layer is higher in hierarchy than children so it will be receiving touch by default )
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        CGPoint pt = [touch locationInView:touch.view];
        pt = [[CCDirector sharedDirector] convertToGL:pt];
        
        for (CCNode *child in self.children) {
            if ([child isNodeInTreeTouched:pt]) {
                return NO;
            }
        }
    }
    
    if ([touch.view isKindOfClass:[UISlider class]])
    {
        return NO;
    }
    
    return YES;
}

@end
