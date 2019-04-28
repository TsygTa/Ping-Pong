//
//  ViewController.m
//  Ping-Pong
//
//  Created by Tatiana Tsygankova on 23.04.2019.
//  Copyright © 2019 Tatiana Tsygankova. All rights reserved.
//

#import "GameViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define HALF_SCREEN_WIDTH SCREEN_WIDTH/2
#define HALF_SCREEN_HEIGHT SCREEN_HEIGHT/2
#define MAX_SCORE 6

typedef enum Winner{
    TopGamer = 1,
    BottomGamer = 2,
    EqualScore = 0
} Winner;

@interface GameViewController ()

@property (strong, nonatomic) UIImageView *paddleTop;
@property (strong, nonatomic) UIImageView *paddleBottom;
@property (strong, nonatomic) UIView *gridView;
@property (strong, nonatomic) UIView *ball;
@property (strong, nonatomic) UITouch *topTouch;
@property (strong, nonatomic) UITouch *bottomTouch;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) float dx;
@property (nonatomic) float dy;
@property (nonatomic) float speed;
@property (nonatomic) int scoreTopGamer;
@property (nonatomic) int scoreBottomGamer;
@property (strong, nonatomic) UILabel *scoreTop;
@property (strong, nonatomic) UILabel *scoreBottom;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
}

- (void)config {
    self.view.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:135.0/255.0 blue:191.0/255.0 alpha:1.0];
    
    _gridView = [[UIView alloc] initWithFrame:CGRectMake(0, HALF_SCREEN_HEIGHT-2, SCREEN_WIDTH, 4)];
    _gridView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_gridView];
    
    _paddleTop = [[UIImageView alloc]initWithFrame:CGRectMake(30, 40, 90, 60)];
    _paddleTop.image = [UIImage imageNamed:@"paddleTop"];
    _paddleTop.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_paddleTop];
    
    _paddleBottom = [[UIImageView alloc]initWithFrame:CGRectMake(30, SCREEN_HEIGHT-90, 90, 60)];
    _paddleBottom.image = [UIImage imageNamed:@"paddleBottom"];
    _paddleBottom.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_paddleBottom];
    
    
    _ball = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-10, self.view.center.y-10, 20, 20)];
    _ball.backgroundColor = [UIColor whiteColor];
    _ball.layer.cornerRadius = 10;
    _ball.hidden = YES;
    [self.view addSubview:_ball];
    
    _scoreTop = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70, HALF_SCREEN_HEIGHT-70, 50, 50)];
    _scoreTop.textColor = [UIColor whiteColor];
    _scoreTop.text = @"0";
    _scoreTop.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightLight];
    _scoreTop.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_scoreTop];
    
    _scoreBottom = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70, HALF_SCREEN_HEIGHT+20, 50, 50)];
    _scoreBottom.textColor = [UIColor whiteColor];
    _scoreBottom.text = @"0";
    _scoreBottom.font = [UIFont systemFontOfSize:40.0 weight:UIFontWeightLight];
    _scoreBottom.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_scoreBottom];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        if(self.bottomTouch == nil && point.y > HALF_SCREEN_HEIGHT) {
            self.bottomTouch = touch;
            self.paddleBottom.center = CGPointMake(point.x, point.y);
        }
//        else if(self.topTouch == nil && point.y < HALF_SCREEN_HEIGHT) {
//            self.topTouch = touch;
//            self.paddleTop.center = CGPointMake(point.x, point.y);
//        }
    }
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
//        if(touch == self.topTouch) {
//            if(point.y > HALF_SCREEN_HEIGHT) {
//                self.paddleTop.center = CGPointMake(point.x, HALF_SCREEN_HEIGHT);
//                return;
//            }
//            self.paddleTop.center = point;
//        } else
        if (touch == self.bottomTouch) {
            if(touch == self.bottomTouch) {
                if(point.y < HALF_SCREEN_HEIGHT) {
                    self.paddleBottom.center = CGPointMake(point.x, HALF_SCREEN_HEIGHT);
                    return;
                }
                self.paddleBottom.center = point;
            }
        }
    }
}
    
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
//        if(touch == self.topTouch) {
//            self.topTouch = nil;
//        } else
        if(touch == self.bottomTouch) {
            self.bottomTouch = nil;
        }
    }
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void) stop {
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.ball.hidden = YES;
}

- (Winner) gameOver {
    if(self.scoreTopGamer >= MAX_SCORE) return TopGamer;
    if(self.scoreBottomGamer >= MAX_SCORE) return BottomGamer;
    return EqualScore;
}

- (void) reset {
    if((arc4random() % 2) == 0) {
        self.dx = -1;
    } else {
        self.dx = 1;
    }
    
    if(self.dy != 0) {
        self.dy = - self.dy;
    } else if((arc4random() % 2) == 0) {
        self.dy = - 1;
    } else {
        self.dy = 1;
    }
    self.ball.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);
    self.speed = 2;
}

- (void) newGame {
    [self reset];
    self.scoreTopGamer = 0;
    self.scoreTop.text = @"0";
    self.scoreBottomGamer = 0;
    self.scoreBottom.text = @"0";
    
    [self displayMessage:@"Готовы к игре?"];
}

- (BOOL) checkCollision: (CGRect) rect X:(float)x Y:(float)y {
    if(CGRectIntersectsRect(self.ball.frame, rect)) {
        if(x != 0) self.dx = x;
        if(y != 0) self.dy = y;
        return YES;
    }
    return NO;
}

- (void) increaseSpeed {
    self.speed += 0.5;
    if(self.speed > 10) self.speed = 10;
}

- (BOOL) goal {
    if(self.ball.center.y < 0 || self.ball.center.y >= SCREEN_HEIGHT) {
        self.ball.center.y < 0?  ++self.scoreBottomGamer : ++self.scoreTopGamer;
        self.scoreTop.text = [NSString stringWithFormat:@"%d",self.scoreTopGamer];
        self.scoreBottom.text = [NSString stringWithFormat:@"%d",self.scoreBottomGamer];
        
        int isGameOver = [self gameOver];
        if(isGameOver) {
            [self displayMessage:[NSString stringWithFormat:@"Игрок %i выиграл", isGameOver]];
        } else {
            [self reset];
        }
        return YES;
    }
    return NO;
}

- (void) animate {
    
    self.ball.center = CGPointMake(self.ball.center.x + self.dx * self.speed, self.ball.center.y + self.dy * self.speed);
    
    int paddelDx = self.ball.center.x - self.paddleTop.center.x;
    
    self.paddleTop.center = CGPointMake(self.paddleTop.center.x + paddelDx * 0.1, self.paddleTop.center.y);
    [self checkCollision:CGRectMake(0,0,20,SCREEN_HEIGHT) X:fabs(self.dx) Y:0];
    [self checkCollision:CGRectMake(SCREEN_WIDTH,0,20,SCREEN_HEIGHT) X:-fabs(self.dx) Y:0];
    
    if([self checkCollision:self.paddleTop.frame X:(self.ball.center.x-self.paddleTop.center.x)/32.0 Y:1])
    {
        [self increaseSpeed];
    }
    
    if([self checkCollision:self.paddleBottom.frame X:(self.ball.center.x-self.paddleBottom.center.x)/32.0 Y:-1])
    {
        [self increaseSpeed];
    }
    [self goal];
}

- (void) start {
    self.ball.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);
    if(!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES];
    }
    self.ball.hidden = NO;
}

- (void) displayMessage:(NSString *) massege {
    [self stop];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ping Pong" message:massege preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if( [self gameOver]) {
            [self newGame];
            return;
        }
        [self reset];
        [self start];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    
    [self newGame];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
}

@end
