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

@interface LandscapeLayer()
/** Updates the positions for all landscapes based on a delta in the X position, where a value
 *  greater than 0 means the landscapes are moving towards the right and a value less than
 *  0 means the landscapes are moving towards the left
 *  @param dx the delta in the x coordinate
 */
- (void)updateLandscapePositionsWithDelta:(CGFloat)dx;
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
        
        // Configure panning gesture recognition
        self.isTouchEnabled= YES;
        mPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        mPanGestureRecognizer.delegate = self;
        [self addGestureRecognizer:mPanGestureRecognizer];
        
        // Configure landscape sprites
        mLandscapeForegroundArray = [[CCArray alloc] initWithCapacity:kLandscapeCount];
        mLandscapeBackgroundArray = [[CCArray alloc] initWithCapacity:kLandscapeCount];
        
        for (int i = 0; i < kLandscapeCount; i++)
        {
            CCSprite *landscapeForegroundSprite = [[CCSprite alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"LandscapeForeground%dTest.png", i+1]];
            landscapeForegroundSprite.position = ccp((i * landscapeForegroundSprite.boundingBox.size.width),
                                                     landscapeForegroundSprite.boundingBox.size.height);
            landscapeForegroundSprite.anchorPoint = ccp(0,1);
            [mLandscapeForegroundArray addObject:landscapeForegroundSprite];
            [sceneDelegate.landscapeBatchNode addChild:landscapeForegroundSprite];
            // Store the landscape sprite width so we don't have to constantly delve properties
            if (mLandscapeSpriteWidth == 0)
            {
                mLandscapeSpriteWidth = landscapeForegroundSprite.boundingBox.size.width;
            }
            
            CCSprite *landscapeBackgroundSprite = [[CCSprite alloc] initWithSpriteFrameName:[NSString stringWithFormat:@"LandscapeBackground%dTest.png", i+1]];
            landscapeBackgroundSprite.position = ccp((i * landscapeForegroundSprite.boundingBox.size.width),
                                                     (landscapeForegroundSprite.boundingBox.size.height + landscapeBackgroundSprite.boundingBox.size.height));
            landscapeBackgroundSprite.anchorPoint = ccp(0,1);
            [mLandscapeBackgroundArray addObject:landscapeBackgroundSprite];
            [sceneDelegate.landscapeBatchNode addChild:landscapeBackgroundSprite];
        }
        
        [self scheduleUpdate];
    }
    return self;
}

#pragma mark - Game Loop Update
- (void)update:(ccTime)deltaTime
{
    // Update position
    mVelocityStep = (mVelocity * deltaTime);
    if (fabsf(mVelocityStep) >= 1)
    {
        [self updateLandscapePositionsWithDelta:mVelocityStep];
        if (mVelocityStep > 1)
        {
            mVelocityStep -= floorf(mVelocityStep);
        }
        if (mVelocityStep < -1)
        {
            mVelocityStep += floorf(mVelocityStep);
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

- (void)updateLandscapePositionsWithDelta:(CGFloat)dx
{
    dx = (dx > 0) ? floorf(dx) : floorf(dx);
    
    for (int i = 0; i < kLandscapeCount; i++)
    {
        CCSprite *foregroundLandscape = (CCSprite *)[mLandscapeForegroundArray objectAtIndex:i];
        CCSprite *backgroundLandscape = (CCSprite *)[mLandscapeBackgroundArray objectAtIndex:i];
        
        foregroundLandscape.position = ccp((foregroundLandscape.position.x + dx), foregroundLandscape.position.y);
        backgroundLandscape.position = ccp((backgroundLandscape.position.x + (dx / 2)), backgroundLandscape.position.y);
    }
    
    for (int i = 0; i < kLandscapeCount; i++)
    {
        CCSprite *foregroundLandscape = (CCSprite *)[mLandscapeForegroundArray objectAtIndex:i];
        CCSprite *backgroundLandscape = (CCSprite *)[mLandscapeBackgroundArray objectAtIndex:i];
        
        [self updateParallaxEffectForLandscapeSprite:foregroundLandscape
                                             atIndex:i
                                           fromArray:mLandscapeForegroundArray
                                           withDelta:dx];
        [self updateParallaxEffectForLandscapeSprite:backgroundLandscape
                                             atIndex:i
                                           fromArray:mLandscapeBackgroundArray
                                           withDelta:dx];
    }
}

- (void)updateParallaxEffectForLandscapeSprite:(CCSprite *)sprite atIndex:(int)i fromArray:(CCArray *)array withDelta:(CGFloat)dx
{
    if (dx > 0) // We're moving towards the right
    {
        if (sprite.position.x >= mScreenSize.width) // Landscape moving offscreen towards right
        {
            // Set x to the x of the i+1 neighbor minus sprite width
            int n = (i+1 == kLandscapeCount) ? 0 : (i + 1);
            CCSprite *neighborLandscape = (CCSprite *)[array objectAtIndex:n];
            sprite.position = ccp(ceilf(neighborLandscape.position.x - mLandscapeSpriteWidth), floorf(sprite.position.y));
        }
    }
    else if (dx < 0) // We're moving towards the left
    {
        if ((sprite.position.x + mLandscapeSpriteWidth) <= 0) // Landscape moving offscreen towards left
        {
            // Set x to the x of the i-1 neighbor plus sprite width
            int n = (i-1 < 0) ? (kLandscapeCount-1) : i-1;
            CCSprite *neighborLandscape = (CCSprite *)[array objectAtIndex:n];
            sprite.position = ccp(floorf(neighborLandscape.position.x + mLandscapeSpriteWidth), floorf(sprite.position.y));
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
        [self updateLandscapePositionsWithDelta:translation.x];
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
    
    return YES;
}

@end
