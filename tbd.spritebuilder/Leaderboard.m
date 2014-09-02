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
    
    CCNodeColor *_bg1;
    CCNodeColor *_bg2;
    CCNodeColor *_bg3;
    CCNodeColor *_bg4;
    
    CCButton *_backButton;
    CCButton *_changeButton;
}

- (void)didLoadFromCCb {
    _leaderboard.delegate = self;
}

- (void)onEnter {
    [super onEnter];
    
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    [gameState setBool:false forKey:@"changeusername"];
    
    // If a player has never set an username
    if (![[MGWU objectForKey:@"hasusername"]boolValue]) {
        [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
        [self changeUsername];
    }
    // A player set a username before:
    // Check if current highscore is greater than previous highscore (to play clapping sound if so)
    // Submit the highscore
    // Set the previous username
    else {
        [MGWU getHighScoresForLeaderboard:@"defaultLeaderboard" withCallback:@selector(checkHighscore:) onTarget:self];
        [MGWU submitHighScore:[[MGWU objectForKey:@"highscore"]intValue] byPlayer:[MGWU objectForKey:@"username"] forLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
        [gameState setObject:[MGWU objectForKey:@"username"] forKey:@"nameonleaderboard"];
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
        if (spacing < 0.99) {
            // Set rank
            CCLabelTTF *rank = [[CCLabelTTF alloc]init];
            rank.string = [NSString stringWithFormat:@"%i", rankCount];
            rank.positionType = CCPositionTypeNormalized;
            rank.position = ccp(0.05, 0.99 - spacing);
            [self setFont:rank];
            [_leaderboard.contentNode addChild:rank];
            
            // Set name
            CCLabelTTF *name = [[CCLabelTTF alloc]init];
            name.string = [dict objectForKey:@"name"];
            name.positionType = CCPositionTypeNormalized;
            name.position = ccp(0.5, 0.99 - spacing);
            name.anchorPoint = ccp(0.5,0.5);
            [self setFont:name];
            [_leaderboard.contentNode addChild:name];
            
            // Set score
            CCLabelTTF *score = [[CCLabelTTF alloc]init];
            score.string = [NSString stringWithFormat:@"%i", [[dict objectForKey:@"score"]intValue]];
            score.positionType = CCPositionTypeNormalized;
            score.position = ccp(0.95, 0.99 - spacing);
            [self setFont:score];
            [_leaderboard.contentNode addChild:score];
            
            // Add spacing and rankCount then go to next dictionary
            spacing += 0.02;
            rankCount++;
        }
    }
}

// Compare previous highscore (score on leaderboard) with current highscore
// If current highscore is higher, then play clapping sound
- (void)checkHighscore:(NSDictionary *)scores {
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    if ([[MGWU objectForKey:@"highscore"]intValue] > [gameState integerForKey:@"scorebefore"]) {
        [self playSound:@"clap" :@"wav"];
        [gameState setInteger:[[MGWU objectForKey:@"highscore"]intValue] forKey:@"scorebefore"];
    }
}

// Set fonts of CCLabelTTF
- (void)setFont:(CCLabelTTF *)label {
    label.fontName = @"font/Montserrat-Regular.ttf";
    label.fontColor = [CCColor blackColor];
    label.fontSize = 15;
}

// Go back to the main or recap screen
- (void)back {
    [self playSound:@"button" :@"wav"];
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    if ([gameState boolForKey:@"frommain"]) {
        CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
        CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.5];
        [[CCDirector sharedDirector] presentScene:mainScene withTransition:transition];
    } else {
        CCScene *recapScene = [CCBReader loadAsScene:@"Recap"];
        CCTransition *transition = [CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.5];
        [[CCDirector sharedDirector] presentScene:recapScene withTransition:transition];
    }
}

- (void)changeUsername {
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    [gameState setBool:true forKey:@"changeusername"];
    CCNode *username = [CCBReader load:@"Username" owner:self];
    username.positionType = CCPositionTypeNormalized;
    username.position = ccp(0.5,0.5);
    username.scale = 0;
    [self addChild:username];
    CCActionScaleTo *scaleUp = [CCActionScaleTo actionWithDuration:0.15f scale:1.f];
    [username runAction:scaleUp];
}

- (void)update:(CCTime)delta {
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    // If a player is changing username
    if ([gameState boolForKey:@"changeusername"]) {
        _bg1.opacity = 0.75;
        _bg2.opacity = 0.75;
        _bg3.opacity = 0.75;
        _bg4.opacity = 0.75;
        _changeButton.enabled = false;
    }
    // If a player is not changing username
    else {
        _bg1.opacity = 1;
        _bg2.opacity = 1;
        _bg3.opacity = 1;
        _bg4.opacity = 1;
        _changeButton.enabled = true;
    }
    
    // If player adds a username for the first time, update the leaderboard to show it up
    // Also add clapping soud, set previous username, and set previous highscore for next
    if ([MGWU objectForKey:@"hasusername"] && ![gameState boolForKey:@"firsttime"]) {
        [gameState setBool:true forKey:@"firsttime"];
        [MGWU submitHighScore:[[MGWU objectForKey:@"highscore"]intValue] byPlayer:[MGWU objectForKey:@"username"] forLeaderboard:@"defaultLeaderboard" withCallback:@selector(receivedScores:) onTarget:self];
        [self playSound:@"clap" :@"wav"];
        [gameState setObject:[MGWU objectForKey:@"username"] forKey:@"nameonleaderboard"];
        [gameState setInteger:[[MGWU objectForKey:@"highscore"]intValue] forKey:@"scorebefore"];
    }
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
