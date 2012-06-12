//
//  Sprite3D.m
//  GLDemo
//
//  Created by XY Feng on 6/8/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import "Sprite3D.h"
#import "GLProgram.h"

typedef struct {
    Vertex3D geometryVertex;
} RectVertex;

typedef struct {
    RectVertex bl;
    RectVertex br;
    RectVertex tl;
    RectVertex tr;    
} RectQuad;

@interface Sprite3D()
{
    GLuint      positionAttribute;
    GLuint      modelViewMatrixUniform;
    GLuint      projectionMatrixUniform;
    GLuint      lightPositionUniform;
    
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
@property(nonatomic, assign) RectQuad quad;
@end

@implementation Sprite3D
@synthesize program3D = _program3D;
@synthesize programShadow = _programShadow;
@synthesize color = _color;
@synthesize quad = _quad;
@synthesize position = _position;
@synthesize contentSize = _contentSize;
@synthesize angle = _angle;

- (id)initWithContentSize:(CGSize)contentSize Alignment:(SpriteAlignment)alignment
{
    self = [super init];
    if (self)
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
        
        //create program for the shadow
        positionAttribute = [self.program3D attributeIndex:@"position"];
        modelViewMatrixUniform = [self.program3D uniformIndex:@"modelViewMatrix"];
        projectionMatrixUniform = [self.program3D uniformIndex:@"projectionMatrix"];
        lightPositionUniform = [self.program3D uniformIndex:@"lightPosition"];
        
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
        
        self.contentSize = contentSize;
        
        RectQuad newQuad;
        
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
        
        self.quad = newQuad;
    }
    return self;
}

- (void)update
{
}

- (void)draw
{
    glEnable(GL_DEPTH_TEST);
    // Set the model-view transform
    static const Vertex3D rotationVector = {0.f, 1.f, 0.f};
    Matrix3DSetRotationByDegrees(rotationMatrix, self.angle, rotationVector);
    Matrix3DSetTranslation(translationMatrix, self.position.x, self.position.y, self.position.z);
    Matrix3DMultiply(translationMatrix, rotationMatrix, modelViewMatrix);
    
    // Set the projection transform
    Matrix3DSetPerspectiveProjectionWithFieldOfView(projectionMatrix, 45.f, 0.1f, 100.f, 1024.f/768.f);
    long offset = (long)&_quad;
    
    //cast shadow
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    [self.programShadow use];
    // Set up light directions
    glUniform3f(shadowLightPositionUniform, -0.24f, 0.6f, 1.2f);
    glUniform1f(shadowGroundZPositionUinform, -2.f);
    glUniformMatrix4fv(shadowModelViewMatrixUniform, 1, FALSE, modelViewMatrix);
    glUniformMatrix4fv(shadowProjectionMatrixUniform, 1, FALSE, projectionMatrix);
    glVertexAttribPointer(shadowPositionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(RectVertex), (void *) (offset + offsetof(RectVertex, geometryVertex)));
    glEnableVertexAttribArray(shadowPositionAttribute);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //draw pages
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    [self.program3D use];
    glUniform3f(lightPositionUniform, -0.24f, 0.6f, 1.2f);
    glUniformMatrix4fv(modelViewMatrixUniform, 1, FALSE, modelViewMatrix);
    glUniformMatrix4fv(projectionMatrixUniform, 1, FALSE, projectionMatrix);
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(RectVertex), (void *) (offset + offsetof(RectVertex, geometryVertex)));
    glEnableVertexAttribArray(positionAttribute);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

}

- (void)dealloc
{
    self.program3D = nil;
    self.programShadow = nil;
    [super dealloc];
}

@end
