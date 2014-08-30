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
}

- (void)onEnter {
    [super onEnter];
    [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
}

- (void)addName {
    _playerName = _textfield.string;
    [MGWU submitHighScore:[[MGWU objectForKey:@"highscore"]intValue] byPlayer:_playerName forLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
}

- (void)receivedScores:(NSDictionary*)scores
{
    NSLog(@"%@", scores);
}

@end
