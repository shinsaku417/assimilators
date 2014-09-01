//
//  Leaderboard.m
//  Assimilators
//
//  Created by Shinsaku Uesugi on 8/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Leaderboard.h"
#import <AudioToolbox/AudioServices.h>

@implementation Leaderboard {
    NSString *_playerName;
    CCTextField *_textfield;
    CCScrollView *_leaderboard;
    
    NSString *_myName;
}

- (void)onEnter {
    [super onEnter];

    [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
}

// If name of the player is too long, send them notification
// If length is fine, then add player's highscore
- (void)addName {
    _playerName = _textfield.string;
    if (_playerName.length > 18) {
        [MGWU showMessage:@"Keep Your Name Under 18 Letters Including Space!" withImage:nil];
    } else {
        _myName = [[MGWU getMyHighScoreForLeaderboard:@"defaultLeaderboard"] objectForKey:@"name"];
        [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(checkHighscore:) onTarget:self];
        [MGWU submitHighScore:[[MGWU objectForKey:@"highscore"]intValue] byPlayer:_playerName forLeaderboard:@"defaultLeaderboard"];
        [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
    }
}

- (void)checkHighscore:(NSDictionary *)scores {
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    if (![gameState boolForKey:@"notfirst"]) {
        [gameState setBool:true forKey:@"notfirst"];
        [self playSound:@"clap" :@"wav"];
    } else {
        for (NSDictionary *dict in [scores objectForKey:@"all"]) {
            if ([[dict objectForKey:@"name"] isEqualToString:_playerName]) {
                if ([[MGWU objectForKey:@"highscore"]intValue] > [[dict objectForKey:@"score"]intValue]) {
                    [self playSound:@"clap" :@"wav"];
                }
            }
        }
    }
}

- (void)receivedScores:(NSDictionary*)scores
{
    // Remove all of labels first to cause any overwriting issues
    [_leaderboard.contentNode removeAllChildren];
    
    // Spacing between highscores
    float spacing = 0;
    // Keeps track of which rank we are on
    int rankCount = 1;
    for (NSDictionary *dict in [scores objectForKey:@"all"]) {
        // Set rank
        CCLabelTTF *rank = [[CCLabelTTF alloc]init];
        rank.string = [NSString stringWithFormat:@"%i", rankCount];
        rank.positionType = CCPositionTypeNormalized;
        rank.position = ccp(0.05, 0.95 - spacing);
        [self setFont:rank];
        [_leaderboard.contentNode addChild:rank];
        
        // Set name
        CCLabelTTF *name = [[CCLabelTTF alloc]init];
        name.string = [dict objectForKey:@"name"];
        name.positionType = CCPositionTypeNormalized;
        name.position = ccp(0.475, 0.95 - spacing);
         [self setFont:name];
        [_leaderboard.contentNode addChild:name];
        
        // Set score
        CCLabelTTF *score = [[CCLabelTTF alloc]init];
        score.string = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"score"]intValue]];
        score.positionType = CCPositionTypeNormalized;
        score.position = ccp(0.9, 0.95 - spacing);
        [self setFont:score];
        [_leaderboard.contentNode addChild:score];
        
        // Add spacing and rankCount then go to next dictionary
        spacing += 0.07;
        rankCount++;
    }
}

// Set fonts of CCLabelTTF
- (void)setFont:(CCLabelTTF *)label {
    label.fontName = @"font/Montserrat-Regular.ttf";
    label.fontColor = [CCColor blackColor];
    label.fontSize = 18;
}

// Go back to the recap screen
- (void)back {
    [self playSound:@"button" :@"wav"];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Recap"];
    CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.5];
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
