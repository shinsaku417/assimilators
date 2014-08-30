//
//  GamePlay.m
//  tbd
//
//  Created by Shinsaku Uesugi on 8/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GamePlay.h"

@implementation GamePlay {
    CCPhysicsNode *_physicsNode;
    
    int _scrollSpeed;
    
    CCNodeColor *_center;
    
    CCNodeColor *_bg1;
    CCNodeColor *_bg2;
    
    CCSprite *_ball1;
    CCSprite *_ball2;
    
    NSMutableArray *_bars;
    
    NSString *_state1;
    NSString *_state2;
    
    BOOL _gameOver;
}

- (void)didLoadFromCCB {
    self.userInteractionEnabled = true;
    _physicsNode.collisionDelegate = self;
}

- (void)onEnter {
    [super onEnter];
    
    _bars = [NSMutableArray array];
    
    _scrollSpeed = 80;
    
    _state1 = @"red";
    _state2 = @"blue";
    
    _gameOver = false;
    
    _center = [CCNodeColor nodeWithColor:[CCColor blackColor]];
    _center.opacity = 0.5;
    _center.positionType = CCPositionTypeNormalized;
    _center.position = ccp(0.5,0.5);
    _center.anchorPoint = ccp(0.5,0.5);
    _center.contentSizeType = CCSizeTypeNormalized;
    _center.contentSize = CGSizeMake(self.contentSize.width * 0.02, self.contentSize.height);
    [_physicsNode addChild:_center z:3];
    
    [self schedule:@selector(spawnBarLeft) interval:3.f];
    [self schedule:@selector(spawnBarRight) interval:2.5f];
}

- (void)update:(CCTime)delta {
    if (!_gameOver) {
        CGPoint bg1Pos = _bg1.positionInPoints;
        CGPoint bg2Pos = _bg2.positionInPoints;
        bg1Pos.y += _scrollSpeed * delta;
        bg2Pos.y += _scrollSpeed * delta;
        
        if (bg1Pos.y > ([CCDirector sharedDirector].viewSize.height))
        {
            bg1Pos.y -= 2*[CCDirector sharedDirector].viewSize.height;
        }
        if (bg2Pos.y > ([CCDirector sharedDirector].viewSize.height))
        {
            bg2Pos.y -= 2*[CCDirector sharedDirector].viewSize.height;
        }
        
        _bg1.positionInPoints = ccp(bg1Pos.x, bg1Pos.y);
        _bg2.positionInPoints = ccp(bg2Pos.x, bg2Pos.y);
        
        for (CCSprite *bar in _bars) {
            bar.positionInPoints = ccp(bar.positionInPoints.x, bar.positionInPoints.y + _scrollSpeed * delta);
            if (bar.positionInPoints.y > self.contentSizeInPoints.height + 20) {
                [bar removeFromParent];
            }
        }
    }
}

- (void)spawnBarLeft {
    CCSprite *bar = [self generateBar:bar];
    bar.anchorPoint = ccp(1,0.5);
    [_physicsNode addChild:bar z:-1];
    bar.position = ccp(self.contentSize.width / 2 - _center.contentSize.width / 2,-0.1);
    [_bars addObject:bar];
}

- (void)spawnBarRight {
    CCSprite *bar = [self generateBar:bar];
    bar.anchorPoint = ccp(0,0.5);
    bar.position = ccp(self.contentSize.width / 2 + _center.contentSize.width / 2,-0.1);
    [_physicsNode addChild:bar z:-1];
    [_bars addObject:bar];
}

- (CCSprite *)generateBar:(CCSprite *)bar {
    int rng = arc4random() % 3;
    switch (rng) {
        case 0:
            bar = (CCSprite *)[CCBReader load:@"redbar"];
            break;
        case 1:
            bar = (CCSprite *)[CCBReader load:@"bluebar"];
            break;
            
        default:
            bar = (CCSprite *)[CCBReader load:@"greenbar"];
    }
    bar.positionType = CCPositionTypeNormalized;
    bar.scaleY = 1.5;
    return bar;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x < self.contentSizeInPoints.width / 2 - _center.contentSizeInPoints.width / 2) {
        _state1 = [self changeColor:_ball1 andState:_state1];
    } else if (touchLocation.x > self.contentSizeInPoints.width / 2 + _center.contentSizeInPoints.width / 2) {
        _state2 = [self changeColor:_ball2 andState:_state2];
    }
}

- (NSString *)changeColor:(CCSprite *)ball andState:(NSString *)state{
    if ([state isEqualToString:@"red"]) {
        state = @"blue";
        [ball setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/blue.png"]];
    }
    
    else if ([state isEqualToString:@"blue"]) {
        state = @"green";
        [ball setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/green.png"]];
    }
    
    else if ([state isEqualToString:@"green"]) {
        state = @"red";
        [ball setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/red.png"]];
    }
    
    return state;
}

- (void)timer {
    
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball1:(CCSprite *)ball redbar:(CCSprite *)bar {
    if (![_state1 isEqualToString:@"red"]) {
        [self recap];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball1:(CCSprite *)ball bluebar:(CCSprite *)bar {
    if (![_state1 isEqualToString:@"blue"]) {
        [self recap];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball1:(CCSprite *)ball greenbar:(CCSprite *)bar {
    if (![_state1 isEqualToString:@"green"]) {
        [self recap];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball2:(CCSprite *)ball redbar:(CCSprite *)bar {
    if (![_state2 isEqualToString:@"red"]) {
        [self recap];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball2:(CCSprite *)ball bluebar:(CCSprite *)bar {
    if (![_state2 isEqualToString:@"blue"]) {
        [self recap];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball2:(CCSprite *)ball greenbar:(CCSprite *)bar {
    if (![_state2 isEqualToString:@"green"]) {
        [self recap];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (void)recap {
    _gameOver = true;
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}


@end
