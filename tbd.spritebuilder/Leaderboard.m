//
//  Leaderboard.m
//  Assimilators
//
//  Created by Shinsaku Uesugi on 8/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Leaderboard.h"

@implementation Leaderboard {
    NSString *_playerName;
    CCTextField *_textfield;
    CCScrollView *_leaderboard;
}

- (void)onEnter {
    [super onEnter];

    [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
}

- (void)addName {
    _playerName = _textfield.string;
    [MGWU submitHighScore:[[MGWU objectForKey:@"highscore"]intValue] byPlayer:_playerName forLeaderboard:@"defaultLeaderboard"];
    [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
}

- (void)receivedScores:(NSDictionary*)scores
{
    [_leaderboard.contentNode removeAllChildren];
    NSLog(@"%@",scores);
    float spacing = 0;
    int rankCount = 1;
    for (NSDictionary *dict in [scores objectForKey:@"all"]) {
        CCLabelTTF *rank = [[CCLabelTTF alloc]init];
        rank.string = [NSString stringWithFormat:@"%i", rankCount];
        rank.positionType = CCPositionTypeNormalized;
        rank.position = ccp(0.05, 0.95 - spacing);
        [self setFont:rank];
        [_leaderboard.contentNode addChild:rank];
        
        CCLabelTTF *name = [[CCLabelTTF alloc]init];
        name.string = [dict objectForKey:@"name"];
        name.positionType = CCPositionTypeNormalized;
        name.position = ccp(0.3, 0.95 - spacing);
         [self setFont:name];
        [_leaderboard.contentNode addChild:name];
        
        CCLabelTTF *score = [[CCLabelTTF alloc]init];
        score.string = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"score"]intValue]];
        score.positionType = CCPositionTypeNormalized;
        score.position = ccp(0.9, 0.95 - spacing);
        [self setFont:score];
        [_leaderboard.contentNode addChild:score];
        
        spacing += 0.07;
        rankCount++;
    }
}

- (void)setFont:(CCLabelTTF *)label {
    label.fontName = @"font/Montserrat-Regular.ttf";
    label.fontColor = [CCColor blackColor];
    label.fontSize = 18;
}

- (void)back {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Recap"];
    CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.5];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}

@end
