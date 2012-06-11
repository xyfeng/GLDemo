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
    GLuint      matrixUniform;
    GLuint      lightDirectionUniform;
    
    Matrix3D    rotationMatrix;
    Matrix3D    translationMatrix;
    Matrix3D    modelViewMatrix;
    Matrix3D    projectionMatrix;
    Matrix3D    matrix;
}
@property(nonatomic, assign) GLProgram *program3D;
@property(nonatomic, assign) RectQuad quad;
@end

@implementation Sprite3D
@synthesize program3D = _program3D;
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
        
        positionAttribute = [self.program3D attributeIndex:@"position"];
        matrixUniform = [self.program3D uniformIndex:@"matrix"];
        lightDirectionUniform = [self.program3D uniformIndex:@"lightDirection"];
        
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
    [self.program3D use];
    
    glEnable(GL_DEPTH_TEST);
    
    // Set up some default material parameters
    glUniform3f(lightDirectionUniform, -0.2f, 0.2f, -1.f);
    
    long offset = (long)&_quad;
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(RectVertex), (void *) (offset + offsetof(RectVertex, geometryVertex)));
    glEnableVertexAttribArray(positionAttribute);
    
    // Set the model-view transform
    static const Vertex3D rotationVector = {0.f, 1.f, 0.f};
    Matrix3DSetRotationByDegrees(rotationMatrix, self.angle, rotationVector);
    Matrix3DSetTranslation(translationMatrix, self.position.x, self.position.y, self.position.z);
    Matrix3DMultiply(translationMatrix, rotationMatrix, modelViewMatrix);
    
    // Set the projection transform
    Matrix3DSetPerspectiveProjectionWithFieldOfView(projectionMatrix, 45.f, 0.1f, 100.f, 1024.f/768.f);
    Matrix3DMultiply(projectionMatrix, modelViewMatrix, matrix);
    glUniformMatrix4fv(matrixUniform, 1, FALSE, matrix);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc
{
    self.program3D = nil;
    [super dealloc];
}

@end
