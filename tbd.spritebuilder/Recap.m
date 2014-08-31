//
//  Recap.m
//  Assimilators
//
//  Created by Shinsaku Uesugi on 8/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Recap.h"
#import "MainScene.h"

// Recap class: pretty much similar to mainscene with minor tweaks

@implementation Recap {
    CCNodeColor *_bg;
    
    CCSprite *_ball1;
    CCSprite *_ball2;
    
    CCSprite *_center;
    
    float _time;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highscoreLabel;
}

- (void)onEnter {
    [super onEnter];
    
    _scoreLabel.string = [NSString stringWithFormat:@"%i",[[MGWU objectForKey:@"score"]intValue]];
    _highscoreLabel.string = [NSString stringWithFormat:@"%i",[[MGWU objectForKey:@"highscore"]intValue]];
    
    state1 = @"red";
    state2 = @"blue";
}

- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] presentScene:gameplayScene];
}

- (void)update:(CCTime)delta {
    _time += delta;
    if (_time > 0.5) {
        if ([state1 isEqualToString:@"red"]) {
            state1 = @"blue";
            [_ball1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/blue.png"]];
            
            state2 = @"green";
            [_ball2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/green.png"]];
        } else if ([state1 isEqualToString:@"blue"]) {
            state1 = @"green";
            [_ball1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/green.png"]];
            
            state2 = @"red";
            [_ball2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/red.png"]];
        } else {
            state1 = @"red";
            [_ball1 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/red.png"]];
            
            state2 = @"blue";
            [_ball2 setSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"image/blue.png"]];
        }
        _time = 0;
    }
}

- (void)leaderboard {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Leaderboard"];
    CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.5];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}

@end
