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

@interface LandscapeLayer()
- (void)updateLandscapePositionsWithDelta:(CGFloat)dx;
- (void)updateParallaxEffectForLandscapeSprite:(CCSprite *)sprite atIndex:(int)i fromArray:(CCArray *)array withDelta:(CGFloat)dx;
@end

const uint kSwipeDeltaAverageSampleNumber = 10;

@implementation LandscapeLayer

@synthesize sceneDelegate = mSceneDelegate;

- (id)initWithSceneDelegate:(SummerBaseLayer *)sceneDelegate
{
    if (self = [super init])
    {
        self.sceneDelegate = sceneDelegate;
        mScreenSize = [[CCDirector sharedDirector] winSize];
        mVelocity = 0;
        mLastPosition = CGPointMake(0, 0);
        
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
    mVelocityStep = (mVelocity * deltaTime);
    if (fabsf(mVelocityStep) < 1)
    {
        return;
    }
    else
    {
        [self updateLandscapePositionsWithDelta:mVelocityStep];
        if (mVelocityStep > 1)
        {
            mVelocityStep -= floorf(mVelocityStep);
        }
        if (mVelocityStep < -1)
        {
            mVelocityStep += ceilf(mVelocityStep);
        }
    }
}

- (void)updateLandscapePositionsWithDelta:(CGFloat)dx
{
    dx = (dx > 0) ? floorf(dx) : ceilf(dx);
    
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
            sprite.position = ccp(floorf(neighborLandscape.position.x - mLandscapeSpriteWidth), floorf(sprite.position.y));
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
        mLastPosition = translation;
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
    return YES;
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
