#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "GLView.h"
#import "GLViewController.h"

typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2]; // New
} Vertex;

@interface GLView ()
{
    GLint               backingWidth; 
    GLint               backingHeight;
    GLuint              frameBuffer; 
    GLuint              renderBuffer;
    GLuint              depthBuffer;
    
    // Add multisampling buffers  
    GLuint              sampleFramebuffer;  
    GLuint              sampleColorRenderbuffer;  
    GLuint              sampleDepthRenderbuffer;  
    
    // Add shadow texture
    GLuint              shadowFramebuffer;  
    GLuint              shadowDepthRenderbuffer;  
    GLuint              shadowTexture;
}
@property (nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, retain) CADisplayLink *displayLink;
- (void)drawView;
@end

#pragma mark -
@implementation GLView
@synthesize controller, animating, context, animationFrameInterval, displayLink;
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{    
    if (self = [super initWithFrame:frame])
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        
        EAGLContext *theContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        self.context = theContext;
        [theContext release];
        
        if (!self.context || ![EAGLContext setCurrentContext:self.context])
        {
            
            [self release];
            return nil;
        }        
        animating = NO;
        animationFrameInterval = 2;
    }
    return self;
}

- (void)createVBOs
{
    
}

- (void)createBuffers
{
    glGenFramebuffers(1, &frameBuffer);
    glGenRenderbuffers(1, &renderBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    glGenRenderbuffers(1, &depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
}

- (void)createMSAABuffers
{
    glGenFramebuffers(1, &sampleFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, sampleFramebuffer);
    
    glGenRenderbuffers(1, &sampleColorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, sampleColorRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 1, GL_RGBA8_OES, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, sampleColorRenderbuffer);
    
    glGenRenderbuffers(1, &sampleDepthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, sampleDepthRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 1, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, sampleDepthRenderbuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
}

- (void)createShadowTexture
{
    glGenFramebuffers(1, &shadowFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, shadowFramebuffer);
    glGenRenderbuffers(1, &shadowDepthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, shadowDepthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, shadowDepthRenderbuffer);
    
    glGenTextures(1, &shadowTexture);
    glBindTexture(GL_TEXTURE_2D, shadowTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, backingWidth, backingHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, shadowTexture, 0);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
}

- (GLuint)shadowTexture
{
    return shadowTexture;
}

- (void)destroyMSAABuffers
{
    const GLenum discards[]  = {GL_COLOR_ATTACHMENT0,GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,2,discards);
}

- (void)destroyBuffers
{
    if (frameBuffer)
    {
        glDeleteFramebuffers(1, &frameBuffer);
        frameBuffer = 0;
    }
    if (renderBuffer)
    {
        glDeleteRenderbuffers(1, &renderBuffer);
        renderBuffer = 0;
    }
    if (depthBuffer)
    {
        glDeleteRenderbuffers(1, &depthBuffer);
        depthBuffer = 0;
    }
    
    if (shadowFramebuffer)
    {
        glDeleteFramebuffers(1, &shadowFramebuffer);
        shadowFramebuffer = 0;
    }
    if (shadowDepthRenderbuffer)
    {
        glDeleteFramebuffers(1, &shadowDepthRenderbuffer);
        shadowDepthRenderbuffer = 0;
    }
    if (shadowTexture)
    {
        glDeleteTextures(1, &shadowTexture);
        shadowTexture = 0;
    }
}

- (void)drawView
{   
    [controller update];
    
    glBindFramebuffer(GL_FRAMEBUFFER, shadowFramebuffer);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [controller drawShadow];
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, sampleFramebuffer);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [controller draw];
    
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, frameBuffer);
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, sampleFramebuffer);
    glResolveMultisampleFramebufferAPPLE();
    
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
}
- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:context];
    [self destroyBuffers];
    [self destroyMSAABuffers];
    [self createVBOs];
    [self createBuffers];
    [self createMSAABuffers];
    [self createShadowTexture];
    
    glViewport(0, 0, backingWidth, backingHeight);
    [controller setup];
}
- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}
- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}
- (void)startAnimation
{
    if (!animating)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView)];
        [displayLink setFrameInterval:animationFrameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        animating = YES;
    }
}
- (void)stopAnimation
{
    if (animating)
    {
        [displayLink invalidate];
        self.displayLink = nil;
        
        animating = NO;
    }
}
- (void)dealloc
{
    [controller release], controller = nil;
    
    [self destroyBuffers];
    [self destroyMSAABuffers];
    
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
    [context release], context = nil;    
    
    [displayLink invalidate];
    [displayLink release], displayLink = nil;
    
    [super dealloc];
}
@end
