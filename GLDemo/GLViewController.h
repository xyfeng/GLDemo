#import <UIKit/UIKit.h>

@class Sprite2D;
@class Sprite3D;
@class SpriteShadow;

@interface GLViewController : UIViewController 
{
}
@property (nonatomic, retain) Sprite2D *bgSprite;
@property (nonatomic, retain) Sprite3D *leftPage;
@property (nonatomic, retain) Sprite3D *rightPage;
@property (nonatomic, retain) Sprite3D *rightPage2;
@property (nonatomic, retain) SpriteShadow *shadowLayer;

- (void)update;
- (void)draw;
- (void)drawShadow;
- (void)setup;
@end
