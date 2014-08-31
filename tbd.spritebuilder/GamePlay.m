//
//  GamePlay.m
//  tbd
//
//  Created by Shinsaku Uesugi on 8/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "MainScene.h"
#import <AudioToolbox/AudioServices.h>

@implementation GamePlay {
    CCPhysicsNode *_physicsNode;
    
    int _scrollSpeed;
    
    // Bar in the center that separates 2 sides
    CCNodeColor *_center;
    
    // Two same backgrounds to loop
    CCNodeColor *_bg1;
    CCNodeColor *_bg2;
    
    CCSprite *_ball1;
    CCSprite *_ball2;
    
    // Keeps bars in an array, and remove any unused bars in the update method
    NSMutableArray *_bars;
    
    // States of balls: red, blue, or green
    NSString *_state1;
    NSString *_state2;
    
    // Stops game when you lose
    BOOL _gameOver;
    
    // Score system
    int _score;
    CCLabelTTF *_scoreLabel;
}

- (void)didLoadFromCCB {
    // Enable multitouch
    self.userInteractionEnabled = true;
    self.multipleTouchEnabled = true;
    
    // Enable collision
    _physicsNode.collisionDelegate = self;
}

- (void)onEnter {
    [super onEnter];
    
    _bars = [NSMutableArray array];
    
    _scrollSpeed = 150;
    
    // Initial state = states set in the MainScene
    _state1 = state1;
    _state2 = state2;
    if ([_state1 isEqualToString:@"red"]) {
        [_ball1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/red.png"]];
        [_ball2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/blue.png"]];
    } else if ([_state1 isEqualToString:@"blue"]) {
        [_ball1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/blue.png"]];
        [_ball2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/green.png"]];
    } else {
        [_ball1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/green.png"]];
        [_ball2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/red.png"]];
    }
    
    
    _gameOver = false;
    
    // Add center bar
    _center = [CCNodeColor nodeWithColor:[CCColor blackColor]];
    _center.positionType = CCPositionTypeNormalized;
    _center.position = ccp(0.5,0.5);
    _center.anchorPoint = ccp(0.5,0.5);
    _center.contentSizeType = CCSizeTypeNormalized;
    _center.contentSize = CGSizeMake(self.contentSize.width * 0.02, self.contentSize.height);
    [_physicsNode addChild:_center z:-1];
    
    // Randomly spawn initial bar at left or right
    int initial = arc4random() % 2;
    if (initial == 0) {
        [self spawnBarLeft];
    } else {
        [self spawnBarRight];
    }
    
    // 8 Patterns of delay, all adds up to 3s total
    int rngDelay = arc4random() % 8;
    float delay1;
    float delay2;
    switch (rngDelay) {
        case 0:
            delay1 = 1.3;
            delay2 = 1.7;
            break;
        case 1:
            delay1 = 1.35;
            delay2 = 1.65;
            break;
        case 2:
            delay1 = 1.4;
            delay2 = 1.6;
            break;
        case 3:
            delay1 = 1.45;
            delay2 = 1.55;
            break;
        case 4:
            delay1 = 1.55;
            delay2 = 1.45;
            break;
        case 5:
            delay1 = 1.6;
            delay2 = 1.4;
            break;
        case 6:
            delay1 = 1.65;
            delay2 = 1.35;
            break;
        default:
            delay1 = 1.7;
            delay2 = 1.3;

    }
    
    // Schedule spawn based on delay
    [self schedule:@selector(spawnBarLeft) interval:delay1];
    [self schedule:@selector(spawnBarRight) interval:delay2];
    
    // Start timer
    [self schedule:@selector(timer) interval:1.0f];
}

- (void)update:(CCTime)delta {
    // If not gameover...
    if (!_gameOver) {
        // Get position of backgrounds
        CGPoint bg1Pos = _bg1.positionInPoints;
        CGPoint bg2Pos = _bg2.positionInPoints;
        
        // Add scrollspeed * delta to background positions
        bg1Pos.y += _scrollSpeed * delta;
        bg2Pos.y += _scrollSpeed * delta;
        
        // If background goes beyond the screen, loop it to create infinite scroll
        if (bg1Pos.y > self.contentSizeInPoints.height)
        {
            bg1Pos.y -= 2*self.contentSizeInPoints.height;
        }
        if (bg2Pos.y > self.contentSizeInPoints.height)
        {
            bg2Pos.y -= 2*self.contentSizeInPoints.height;
        }
        
        // Set the positions of backgrounds
        _bg1.positionInPoints = ccp(bg1Pos.x, bg1Pos.y);
        _bg2.positionInPoints = ccp(bg2Pos.x, bg2Pos.y);
        
        // Remove bars that went beyond the screen to eliminate memory issues
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
    bar.position = ccp(self.contentSize.width / 2 - _center.contentSize.width / 2,-0.001);
    [_bars addObject:bar];
}

- (void)spawnBarRight {
    CCSprite *bar = [self generateBar:bar];
    bar.anchorPoint = ccp(0,0.5);
    bar.position = ccp(self.contentSize.width / 2 + _center.contentSize.width / 2,-0.001);
    [_physicsNode addChild:bar z:-1];
    [_bars addObject:bar];
}

// Generate bars of random colors
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

// Check which side is touch on, and change color of the square accordingly
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x < self.contentSizeInPoints.width / 2 - _center.contentSizeInPoints.width / 2) {
        _state1 = [self changeColor:_ball1 andState:_state1];
        [self playAudio];
    } else if (touchLocation.x > self.contentSizeInPoints.width / 2 + _center.contentSizeInPoints.width / 2) {
        _state2 = [self changeColor:_ball2 andState:_state2];
        [self playAudio];
    }
}

// Change color and state of the squares
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

// Add score, update score, and increase scrollspeed by 2.5px
- (void)timer {
    _score++;
    _scoreLabel.string = [NSString stringWithFormat:@"%i", _score];
    _scrollSpeed += 2.5;
}

// Collisions:
// Collision between square and bar of same color: Make bar a sensor so square will go through without collision
// Collision between square and bar of different color: Stop scrolling, make square a sensor so it won't bounce off of bar. Then present recap screen
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball1:(CCSprite *)ball redbar:(CCSprite *)bar {
    if (![_state1 isEqualToString:@"red"]) {
        [self recap:bar andStop:ball andParticle:_state1];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball1:(CCSprite *)ball bluebar:(CCSprite *)bar {
    if (![_state1 isEqualToString:@"blue"]) {
        [self recap:bar andStop:ball andParticle:_state1];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball1:(CCSprite *)ball greenbar:(CCSprite *)bar {
    if (![_state1 isEqualToString:@"green"]) {
        [self recap:bar andStop:ball andParticle:_state1];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball2:(CCSprite *)ball redbar:(CCSprite *)bar {
    if (![_state2 isEqualToString:@"red"]) {
        [self recap:bar andStop:ball andParticle:_state2];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball2:(CCSprite *)ball bluebar:(CCSprite *)bar {
    if (![_state2 isEqualToString:@"blue"]) {
        [self recap:bar andStop:ball andParticle:_state2];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball2:(CCSprite *)ball greenbar:(CCSprite *)bar {
    if (![_state2 isEqualToString:@"green"]) {
        [self recap:bar andStop:ball andParticle:_state2];
    } else {
        bar.physicsBody.sensor = true;
    }
    
    return TRUE;
}

- (void)recap:(CCSprite *)bar andStop:(CCSprite *)ball andParticle:(NSString *)state {
    // Cause vibration: Make sure to have audio framework
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    // Set score and highscore if applicable
    NSNumber *score = [NSNumber numberWithInteger:_score];
    [MGWU setObject:score forKey:@"score"];
    if ([[MGWU objectForKey:@"score"]intValue] > [[MGWU objectForKey:@"highscore"]intValue]) {
        [MGWU setObject:[MGWU objectForKey:@"score"] forKey:@"highscore"];
    }
    
    // Disable touch
    self.userInteractionEnabled = false;
    
    // Add particle effect
    CCParticleSystem *particle = (CCParticleSystem *)[CCBReader load:@"Particle"];
    if ([state isEqualToString:@"blue"]) {
        particle.startColor = [CCColor blueColor];
        particle.endColor = [CCColor blueColor];
    } else if ([state isEqualToString:@"green"]) {
        particle.startColor = [CCColor greenColor];
        particle.endColor = [CCColor greenColor];
    }
    particle.positionType = CCPositionTypeNormalized;
    particle.position = ball.position;
    [self addChild:particle];
    [ball removeFromParent];
    
    // Blink the bar that caused death
    CCActionBlink *blink = [CCActionBlink actionWithDuration:1.5f blinks:3];
    [bar runAction:blink];
    
    // Stop scrolling by setting this true
    _gameOver = true;
    
    // Unschedule any methods
    [self unschedule:@selector(timer)];
    [self unschedule:@selector(spawnBarLeft)];
    [self unschedule:@selector(spawnBarRight)];
    
    // After bar blink finishes, go to the next scene = recap
    [self performSelector:@selector(newScene) withObject:self afterDelay:1.5f];
}

- (void)playAudio {
    [self playSound:@"click" :@"wav"];
}

- (void)playSound :(NSString *)fName :(NSString *) ext{
    SystemSoundID audioEffect;
    NSString *path = [[NSBundle mainBundle] pathForResource : fName ofType :ext];
    if ([[NSFileManager defaultManager] fileExistsAtPath : path]) {
        NSURL *pathURL = [NSURL fileURLWithPath: path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
    }
    else {
        NSLog(@"error, file not found: %@", path);
    }
}

- (void)newScene {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Recap"];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.5];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}


@end
