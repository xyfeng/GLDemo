//
//  Sprite3D.m
//  GLDemo
//
//  Created by XY Feng on 6/8/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import "Sprite3D.h"
#import "GLProgram.h"
#import "GLTexture.h"

typedef struct {
    Vertex3D geometryVertex;
    CGPoint  textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;    
} TexturedQuad;

@interface Sprite3D()
{
    GLuint      positionAttribute;
    GLuint      modelViewMatrixUniform;
    GLuint      projectionMatrixUniform;
    GLuint      lightPositionUniform;
    GLuint      pagePositionUniform;
    
    Vector3D    centerVertex;
    
    Matrix3D    rotationMatrix;
    Matrix3D    translationMatrix;
    Matrix3D    modelViewMatrix;
    Matrix3D    projectionMatrix;
    
    //shadow 
    GLuint      shadowPositionAttribute;
    GLuint      shadowModelViewMatrixUniform;
    GLuint      shadowProjectionMatrixUniform;
    GLuint      shadowLightPositionUniform;
    GLuint      shadowGroundZPositionUinform;
}
@property(nonatomic, assign) GLProgram *program3D;
@property(nonatomic, assign) GLProgram *programShadow;
@property(nonatomic, retain) GLTexture *texture;
@property(nonatomic, assign) TexturedQuad quad;
@end

@implementation Sprite3D
@synthesize program3D = _program3D;
@synthesize programShadow = _programShadow;
@synthesize texture = _texture;
@synthesize quad = _quad;
@synthesize position = _position;
@synthesize contentSize = _contentSize;
@synthesize angle = _angle;
@synthesize shadow = _shadow;

- (id)initWithContentSize:(CGSize)contentSize Alignment:(SpriteAlignment)alignment
{
    self = [super init];
    if (self)
    {
        [self setup3DProgram];
        
        [self setupShadowProgram];
        
        self.contentSize = contentSize;
        self.texture = [[[GLTexture alloc] initWithFilename:@"shadow.png"] autorelease];
        
        TexturedQuad newQuad;
        
        if (alignment == SPRITE_ALIGN_LEFT) {
            newQuad.bl.geometryVertex = Vertex3DMake(0.f, -self.contentSize.height/2/1024, 0.f);
            newQuad.br.geometryVertex = Vertex3DMake(self.contentSize.width/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.tl.geometryVertex = Vertex3DMake(0.f, self.contentSize.height/2/1024, 0.f);
            newQuad.tr.geometryVertex = Vertex3DMake(self.contentSize.width/1024, self.contentSize.height/2/1024, 0.f);
        }
        else if (alignment == SPRITE_ALIGN_RIGHT) {
            newQuad.bl.geometryVertex = Vertex3DMake(-self.contentSize.width/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.br.geometryVertex = Vertex3DMake(0.f, -self.contentSize.height/2/1024, 0.f);
            newQuad.tl.geometryVertex = Vertex3DMake(-self.contentSize.width/1024, self.contentSize.height/2/1024, 0.f);
            newQuad.tr.geometryVertex = Vertex3DMake(0.f, self.contentSize.height/2/1024, 0.f);
        }
        else {
            newQuad.bl.geometryVertex = Vertex3DMake(-self.contentSize.width/2/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.br.geometryVertex = Vertex3DMake(self.contentSize.width/2/1024, -self.contentSize.height/2/1024, 0.f);
            newQuad.tl.geometryVertex = Vertex3DMake(-self.contentSize.width/2/1024, self.contentSize.height/2/1024, 0.f);
            newQuad.tr.geometryVertex = Vertex3DMake(self.contentSize.width/2/1024, self.contentSize.height/2/1024, 0.f);
        }
        
        newQuad.bl.textureVertex = CGPointMake(0, 0);
        newQuad.br.textureVertex = CGPointMake(1, 0);
        newQuad.tl.textureVertex = CGPointMake(0, 1);
        newQuad.tr.textureVertex = CGPointMake(1, 1);
        
        centerVertex = Vertex3DMake((self.quad.tl.geometryVertex.x + self.quad.bl.geometryVertex.x + self.quad.tr.geometryVertex.x + self.quad.br.geometryVertex.x ) * 0.25, (self.quad.tl.geometryVertex.y + self.quad.bl.geometryVertex.y + self.quad.tr.geometryVertex.y + self.quad.br.geometryVertex.y ) * 0.25, (self.quad.tl.geometryVertex.z + self.quad.bl.geometryVertex.z + self.quad.tr.geometryVertex.z + self.quad.br.geometryVertex.z ) * 0.25);
        
        self.quad = newQuad;
        
        Matrix3DSetPerspectiveProjectionWithFieldOfView(projectionMatrix, 45.f, 0.1f, 100.f, 1024.f/768.f);
    }
    return self;
}

- (void)setup3DProgram
{
    self.program3D = [[GLProgram alloc] initWithVertexShaderFilename:@"VShader3D" fragmentShaderFilename:@"FShader3D"];
    [self.program3D addAttribute:@"position"];
    
    if (![self.program3D link])
    {
        NSLog(@"Link failed");
        
        NSString *progLog = [self.program3D programLog];
        NSLog(@"Program Log: %@", progLog); 
        
        NSString *fragLog = [self.program3D fragmentShaderLog];
        NSLog(@"Frag Log: %@", fragLog);
        
        NSString *vertLog = [self.program3D vertexShaderLog];
        NSLog(@"Vert Log: %@", vertLog);
        
        self.program3D = nil;
    }
    
    positionAttribute = [self.program3D attributeIndex:@"position"];
    modelViewMatrixUniform = [self.program3D uniformIndex:@"modelViewMatrix"];
    projectionMatrixUniform = [self.program3D uniformIndex:@"projectionMatrix"];
    lightPositionUniform = [self.program3D uniformIndex:@"lightPosition"];
    pagePositionUniform = [self.program3D uniformIndex:@"pagePosition"];
}

- (void)setupShadowProgram
{
    //create program for the shadow
    self.programShadow = [[GLProgram alloc] initWithVertexShaderFilename:@"VShaderShadow" fragmentShaderFilename:@"FShaderShadow"];
    [self.programShadow addAttribute:@"position"];
    
    if (![self.programShadow link])
    {
        NSLog(@"Link failed");
        
        NSString *progLog = [self.programShadow programLog];
        NSLog(@"Program Log: %@", progLog); 
        
        NSString *fragLog = [self.programShadow fragmentShaderLog];
        NSLog(@"Frag Log: %@", fragLog);
        
        NSString *vertLog = [self.programShadow vertexShaderLog];
        NSLog(@"Vert Log: %@", vertLog);
        
        self.program3D = nil;
    }
    
    shadowPositionAttribute = [self.programShadow attributeIndex:@"position"];
    shadowModelViewMatrixUniform = [self.programShadow uniformIndex:@"modelViewMatrix"];
    shadowProjectionMatrixUniform = [self.programShadow uniformIndex:@"projectionMatrix"];
    shadowLightPositionUniform = [self.programShadow uniformIndex:@"lightPosition"];
    shadowGroundZPositionUinform = [self.programShadow uniformIndex:@"groundZPosition"];
    
}

- (void)update
{
    static const Vertex3D rotationVector = {0.f, 1.f, 0.f};
    Matrix3DSetRotationByDegrees(rotationMatrix, self.angle, rotationVector);
    Matrix3DSetTranslation(translationMatrix, self.position.x, self.position.y, self.position.z);
    Matrix3DMultiply(translationMatrix, rotationMatrix, modelViewMatrix);
}

- (void)draw3DPages
{
    [self.program3D use];
    long offset = (long)&_quad;
    glUniform3f(pagePositionUniform, centerVertex.x , centerVertex.y, centerVertex.z);
    glUniform3f(lightPositionUniform, -0.24f, 0.6f, 1.2f);
    glUniformMatrix4fv(modelViewMatrixUniform, 1, FALSE, modelViewMatrix);
    glUniformMatrix4fv(projectionMatrixUniform, 1, FALSE, projectionMatrix);
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glEnableVertexAttribArray(positionAttribute);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)drawShadow
{
    [self.programShadow use];
    long offset = (long)&_quad;
    glUniform3f(shadowLightPositionUniform, -0.24f, 0.6f, 1.2f);
    glUniform1f(shadowGroundZPositionUinform, -2.f);
    glUniformMatrix4fv(shadowModelViewMatrixUniform, 1, FALSE, modelViewMatrix);
    glUniformMatrix4fv(shadowProjectionMatrixUniform, 1, FALSE, projectionMatrix);
    glVertexAttribPointer(shadowPositionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glEnableVertexAttribArray(shadowPositionAttribute);
    
    glActiveTexture (GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.shadow);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(shadowPositionAttribute);
}

- (void)draw
{
    glEnable(GL_DEPTH_TEST);
    [self draw3DPages];
}

- (void)dealloc
{
    self.program3D = nil;
    self.programShadow = nil;
    [super dealloc];
}

@end
