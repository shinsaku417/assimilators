//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import <AudioToolbox/AudioServices.h>

@implementation MainScene {
    CCNodeColor *_bg;
    
    CCSprite *_ball1;
    CCSprite *_ball2;
    
    CCSprite *_center;
    
    float _time;
}

// Set the original state of the balls
- (void)onEnter {
    [super onEnter];
    
    state1 = @"red";
    state2 = @"blue";    
}

- (void)play {
    [self playSound:@"button" :@"wav"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] presentScene:gameplayScene];
}

- (void)runTutorial {
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    [gameState setBool:false forKey:@"tutorial"];
    [self play];
}

// Change color of balls every 0.5 secs so every starting state is different
- (void)update:(CCTime)delta {
    _time += delta;
    // Change sprites of balls and state: red => blue => green => red
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
        // Reset time
        _time = 0;
    }
}

- (void)leaderboard {
    [self playSound:@"button" :@"wav"];
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    [gameState setBool:true forKey:@"frommain"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Leaderboard"];
    CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.5];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}

- (void)twitter {
    
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
