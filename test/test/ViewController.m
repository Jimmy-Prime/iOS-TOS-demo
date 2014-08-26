
#import "ViewController.h"

@implementation ViewController
{
    CGFloat refX[6], refY[6];
    CGFloat l;
    CGPoint startPoint;
    UIView* selectedView;
    CGPoint startCenter;
    
    UIColor* color[5];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.multipleTouchEnabled = NO;
    self.view.tag = -1;
    for (UIView* obj in [self.view subviews]) {
        obj.tag = -1;
    }
	
    for (int i=0; i<6; i++) {
        refX[i] = 10 + 50 * i + 25;
        refY[i] = self.view.frame.size.height - 10 - 50 * i - 25;
    }
    
    color[0] = [UIColor redColor];
    color[1] = [UIColor cyanColor];
    color[2] = [UIColor yellowColor];
    color[3] = [UIColor greenColor];
    color[4] = [UIColor magentaColor];
    
    l = 22.5;
    for (int i=0; i<6; i++) {
        for (int j=0; j<6; j++) {
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake(refX[i] - l, refY[j] - l, 2 * l, 2 * l)];
            view.layer.cornerRadius = 5;
            view.backgroundColor = color[arc4random() % 5];
            view.tag = 6 * i + j;
            [self.view addSubview:view];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    NSInteger selected = [self findSection:point];
    if (selected != -1) {
        startPoint = point;
        selectedView = [self.view viewWithTag:selected];
        startCenter = selectedView.center;
    }
    else {
        selectedView = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    if (selectedView) {
        selectedView.center = CGPointMake(startCenter.x + point.x - startPoint.x, startCenter.y + point.y - startPoint.y);
        NSInteger selected = [self findSection:point];
        if (selected != -1 && selected != selectedView.tag) {
            UIView* viewToSwap = [self.view viewWithTag:selected];
            
            [UIView animateWithDuration:0.2 animations:^{
                viewToSwap.center = CGPointMake(refX[selectedView.tag / 6], refY[selectedView.tag % 6]);
                NSInteger tempTag = viewToSwap.tag;
                viewToSwap.tag = selectedView.tag;
                selectedView.tag = tempTag;
            }];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (selectedView) {
        [UIView animateWithDuration:0.2 animations:^{
            selectedView.center = CGPointMake(refX[selectedView.tag / 6], refY[selectedView.tag % 6]);
        } completion:^(BOOL finished){
            if ([self resetBlocks]) {
                [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(iterate:) userInfo:nil repeats:YES];
            }
        }];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (NSInteger)findSection:(CGPoint)point
{
    for (int i=0; i<6; i++) {
        for (int j=0; j<6; j++) {
            if (point.x > refX[i] - 25 && point.x < refX[i] + 25 && point.y > refY[j] - 25 && point.y < refY[j] + 25) {
                return 6 * i + j;
            }
        }
    }
    return -1;
}

-(NSUInteger)resetBlocks
{
    // check for lines
    NSMutableSet* blocksToRemove = [NSMutableSet set];
    for (int i=0; i<6; i++) {
        for (int j=0; j<6; j++) {
            UIColor* thisColor = [self.view viewWithTag:6 * i + j].backgroundColor;
            
            // check up
            NSMutableArray* blocksInLineU = [NSMutableArray array];
            [blocksInLineU addObject:[self.view viewWithTag:6 * i + j]];
            int y = i + 1;
            while (y < 6) {
                UIView* block = [self.view viewWithTag:6 * y + j];
                if (block.backgroundColor == thisColor) {
                    [blocksInLineU addObject:block];
                }
                else break;
                y++;
            }
            if (blocksInLineU.count >= 3) {
                [blocksToRemove addObjectsFromArray:blocksInLineU];
            }
            
            // check side
            NSMutableArray* blocksInLineS = [NSMutableArray array];
            [blocksInLineS addObject:[self.view viewWithTag:6 * i + j]];
            int x = j + 1;
            while (x < 6) {
                UIView* block = [self.view viewWithTag:6 * i + x];
                if (block.backgroundColor == thisColor) {
                    [blocksInLineS addObject:block];
                }
                else break;
                x++;
            }
            if (blocksInLineS.count >= 3) {
                [blocksToRemove addObjectsFromArray:blocksInLineS];
            }
        }
    }
    
    // delete
    for (UIView* block in blocksToRemove) {
        [block removeFromSuperview];
    }
    
    // fall
    for (int i=0; i<6; i++) {
        for (int j=1; j<6; j++) {
            selectedView = [self.view viewWithTag:6 * i + j];
            if (selectedView) {
                for (int k=0; k<j; k++) {
                    if (![self.view viewWithTag:6 * i + k]) {
                        selectedView.tag = 6 * i + k;
                        [UIView animateWithDuration:0.2 animations:^{
                            selectedView.center = CGPointMake(refX[i], refY[k]);
                        }];
                        break;
                    }
                }
            }
        }
    }
    
    // add new blocks
    for (int i=0; i<6; i++) {
        for (int j=0; j<6; j++) {
            if (![self.view viewWithTag:6 * i + j]) {
                UIView* view = [[UIView alloc] initWithFrame:CGRectMake(refX[i] - l, refY[j] - l, 2 * l, 2 * l)];
                view.layer.cornerRadius = 5;
                view.backgroundColor = color[arc4random() % 5];
                view.tag = 6 * i + j;
                view.alpha = 0;
                [self.view addSubview:view];
                
                [UIView animateWithDuration:0.4 animations:^{
                    view.alpha = 1;
                }];
            }
        }
    }
    
    return [blocksToRemove count];
}

- (void)iterate:(NSTimer*)timer
{
    if (![self resetBlocks]) {
        [timer invalidate];
    }
}

@end
