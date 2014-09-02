//
//  Username.m
//  Assimilators
//
//  Created by Shinsaku Uesugi on 9/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Username.h"

@implementation Username {
    CCTextField *_textfield;
    NSString *_playerName;
    
    CCButton *_removeButton;
    
    BOOL _sameName;
}

- (void)onEnter {
    [super onEnter];
    
    _sameName = false;
    
    if (![[MGWU objectForKey:@"hasusername"]boolValue]) {
        _removeButton.visible = false;
    }
}

- (void)add {
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    
    _playerName = _textfield.string;
    
    // Trim the white spaces from _playerName. If player only enters space for their name, then this will return empty string
    NSString *nameWithoutContent = [_playerName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // If player doesn't enter anything
    if (_playerName.length == 0) {
        [MGWU showMessage:@"Enter Something!" withImage:nil];
    }
    // If trimmed string is empty (player enter only white spaces)
    else if (nameWithoutContent.length == 0) {
        [MGWU showMessage:@"No Username With Only Spaces!" withImage:nil];
    }
    // If player enter name that is too long
    else if (_playerName.length > 18) {
        [MGWU showMessage:@"Keep Your Username Under 18 Letters Including Space!" withImage:nil];
    }
    
    // Player must get score above 0
    else if ([[MGWU objectForKey:@"highscore"]intValue] == 0) {
        [MGWU showMessage:@"Get Score Above 0 To Submit!" withImage:nil];
    }
    
    else {
        // Check for no same name
        for (NSString *name in [MGWU objectForKey:@"namearray"]) {
            if ([[name uppercaseString] isEqualToString:[_playerName uppercaseString]]) {
                [MGWU showMessage:@"That Username Already Exists!" withImage:nil];
                _sameName = true;
            }
        }
        // Passed all validation
        if (!_sameName) {
            [MGWU setObject:_playerName forKey:@"username"];
            
            NSNumber *username = [NSNumber numberWithBool:true];
            [MGWU setObject:username forKey:@"hasusername"];
            
            CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.15f scale:0.f];
            [self runAction:scaleDown];
            [self removeFromParent];
            
            [gameState setBool:false forKey:@"changeusername"];
        }
    }
}

- (void)remove {
    NSUserDefaults *gameState = [NSUserDefaults standardUserDefaults];
    [gameState setBool:false forKey:@"changeusername"];
    CCActionScaleTo *scaleDown = [CCActionScaleTo actionWithDuration:0.15f scale:0.f];
    [self runAction:scaleDown];
    [self performSelector:@selector(removeFromParent) withObject:self afterDelay:0.15f];
}

@end
