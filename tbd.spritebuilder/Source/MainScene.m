//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene {
    CCNodeColor *_bg;
    
    CCSprite *_ball1;
    CCSprite *_ball2;
    
    CCSprite *_center;
    
    float _time;
}

- (void)onEnter {
    [super onEnter];
    
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

@end
