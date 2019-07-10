//
//  KeyboardButton.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/24/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "KeyboardButton.h"

@implementation KeyboardButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self addTarget:self action:@selector(buttonHighlight) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(buttonNormal) forControlEvents:UIControlEventTouchUpOutside];
}

-(void)buttonHighlight{
    self.backgroundColor = [UIColor darkGrayColor];
}

-(void)buttonNormal{
    self.backgroundColor = [UIColor grayColor];
    
}

-(void)typing{
    
    if (self.titleLabel.text.length!=0){
        if (_numberPad.text.length<6){
            [_numberPad insertText:self.titleLabel.text];
        }
        
        
    }
    else{
        UITextRange *range = _numberPad.selectedTextRange;
        NSString* cursor =[NSString stringWithFormat:@"%@", range.end];
        cursor = [[cursor substringFromIndex:cursor.length-3] substringToIndex:1];
        UITextPosition* startPosition =[_numberPad beginningOfDocument];
        UITextRange *textRange = [_numberPad textRangeFromPosition:[_numberPad positionFromPosition:startPosition offset:[cursor integerValue]-1] toPosition:[_numberPad positionFromPosition:startPosition offset:[cursor integerValue]] ];
        [_numberPad replaceRange:textRange withText:@""];
        
    }
   
}


@end
