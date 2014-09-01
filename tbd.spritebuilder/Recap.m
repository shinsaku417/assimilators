//
//  Recap.m
//  Assimilators
//
//  Created by Shinsaku Uesugi on 8/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Recap.h"
#import "MainScene.h"
#import <AudioToolbox/AudioServices.h>

// Recap class: pretty much similar to mainscene with minor tweaks

@implementation Recap {
    CCNodeColor *_bg;
    
    CCSprite *_ball1;
    CCSprite *_ball2;
    
    CCSprite *_center;
    
    float _time;
    
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highscoreLabel;
    CCSprite *_star;
}

- (void)onEnter {
    [super onEnter];
    
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    if ([gameState boolForKey:@"gothighscore"] && ![gameState boolForKey:@"leftrecap"]) {
        [self playSound:@"highscore" :@"mp3"];
        _star.visible = true;
        CCActionBlink *blink = [CCActionBlink actionWithDuration:2.f blinks:3.f];
        [_star runAction:blink];
    } else if ([gameState boolForKey:@"gothighscore"]) {
        _star.visible = true;
    }
    
    _scoreLabel.string = [NSString stringWithFormat:@"%i",[[MGWU objectForKey:@"score"]intValue]];
    _highscoreLabel.string = [NSString stringWithFormat:@"%i",[[MGWU objectForKey:@"highscore"]intValue]];
    
    state1 = @"red";
    state2 = @"blue";
}

- (void)play {
    [self playSound:@"button" :@"wav"];
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
    [self playSound:@"button" :@"wav"];
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    [gameState setBool:true forKey:@"leftrecap"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Leaderboard"];
    CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.5];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
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

@end
