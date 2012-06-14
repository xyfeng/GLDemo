#import "GLViewController.h"
#import "GLView.h"
#import "Sprite2D.h"
#import "Sprite3D.h"
#import "SpriteShadow.h"

@implementation GLViewController
{
    CGFloat velocity;
    CGFloat pageOpenAngle;
}
@synthesize bgSprite = _bgSprite;
@synthesize leftPage = _leftPage;
@synthesize rightPage = _rightPage;
@synthesize rightPage2 = _rightPage2;
@synthesize shadowLayer = _shadowLayer;

- (id)init
{
    self = [super init];
    if (self) {
        GLView *glView = [[[GLView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)] autorelease];
        glView.controller = self;
        self.view = glView;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[(GLView *)self.view startAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	[(GLView *)self.view stopAnimation];
}

- (void)setup
{
    //setup pinch gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchRecognized:)];
    [self.view addGestureRecognizer:pinch];
    [pinch release];
    
    self.bgSprite = [[[Sprite2D alloc] initWithFileName:@"bg.png"] autorelease];;
    self.bgSprite.position = Vertex3DMake(512, 384, -1000);
    self.shadowLayer = [[[SpriteShadow alloc] init] autorelease];
    
    pageOpenAngle = 15;
    velocity = 3;
    
    self.leftPage = [[[Sprite3D alloc] initWithContentSize:CGSizeMake(320, 480) Alignment:SPRITE_ALIGN_RIGHT] autorelease];
    self.rightPage = [[[Sprite3D alloc] initWithContentSize:CGSizeMake(320, 480) Alignment:SPRITE_ALIGN_LEFT] autorelease];
//    self.rightPage2 = [[[Sprite3D alloc] initWithContentSize:CGSizeMake(320, 480) Alignment:SPRITE_ALIGN_LEFT] autorelease];
    self.leftPage.shadow = self.rightPage.shadow = self.shadowLayer.texture = [(GLView *)self.view shadowTexture];
    
	glEnable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
}

static int pinchEnded = 0;
- (void)update
{
    if (pinchEnded == 1 && pageOpenAngle < 120) {
        pageOpenAngle += (120 - pageOpenAngle)*0.2;
    }
    else if(pinchEnded == -1 && pageOpenAngle > 15) {
        pageOpenAngle -= (pageOpenAngle - 15)*0.2;
    }
    else {
        pinchEnded = 0;
    }
    
    self.leftPage.position = Vertex3DMake(0, 0, -1.5+(pageOpenAngle - 15)/300); 
    self.rightPage.position = Vertex3DMake(0, 0, -1.5+(pageOpenAngle - 15)/300);
    self.leftPage.angle = 90 - pageOpenAngle/2;
    self.rightPage.angle = pageOpenAngle/2 - 90;

//    self.rightPage2.position = Vertex3DMake(0, 0, -1.5+(pageOpenAngle - 15)/300);
//    self.rightPage2.angle = (pageOpenAngle+30)/2 - 90;
    
    [self.leftPage update];
    [self.rightPage update];
//    [self.rightPage2 update];
}

- (void)drawShadow
{
    [self.leftPage drawShadow];
    [self.rightPage drawShadow];
//    [self.rightPage2 drawShadow];
}

- (void)draw
{
    [self.bgSprite draw];
    
    [self.shadowLayer draw];
    
    [self.leftPage draw];
    [self.rightPage draw];
//    [self.rightPage2 draw];
}

#pragma mark - Gesture Recognizer
static CGFloat openAngleStart;
static CGFloat lastChangedScale;
static BOOL openingPage;
- (void)pinchRecognized:(UIPinchGestureRecognizer *)pinch
{
//    NSLog(@"pinch state:%d, pinch scale:%f", pinch.state, pinch.scale);
    if (pinch.state == UIGestureRecognizerStateBegan) {
        openAngleStart = pageOpenAngle;
        pinchEnded = 0;
        lastChangedScale = pinch.scale;
    }
    else if(pinch.state == UIGestureRecognizerStateChanged) {
        pageOpenAngle = openAngleStart*pinch.scale;
        if (pinch.scale > lastChangedScale && !openingPage) {
            openingPage = YES;
        }
        else if(pinch.scale < lastChangedScale && openingPage) {
            openingPage = NO;
        }
        lastChangedScale = pinch.scale;
    }
    else if(pinch.state == UIGestureRecognizerStateEnded || pinch.state == UIGestureRecognizerStateCancelled)
    {
        pinchEnded = (openingPage)? 1: -1;
    }
    else {
        NSLog(@"Warning: gesture xxx");
    }
    if (pageOpenAngle < 15) {
        pageOpenAngle = 15;
    }
    else if (pageOpenAngle > 160) {
        pageOpenAngle = 160;
    }
}

#pragma mark -
- (void)viewDidUnload 
{
    self.bgSprite = nil;
    self.leftPage = nil;
    self.rightPage = nil;
//    self.rightPage2 = nil;
    [super viewDidUnload];
}
- (void)dealloc 
{
    [super dealloc];
}
@end
