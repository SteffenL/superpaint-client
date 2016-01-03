package com.steffenl.superpaint.core.painting.detail {
import starling.display.Image;
import starling.display.Shape;
import starling.textures.RenderTexture;
import starling.textures.Texture;

public class BrushTextureGenerator {
    public static function Circle(color:uint, alpha:Number, radius:Number):Texture {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(color, alpha);
        shape.graphics.drawCircle(radius, radius, radius);
        shape.graphics.endFill();

        var tempTexture:RenderTexture = new RenderTexture(radius * 2, radius * 2);
        tempTexture.draw(shape);

        shape.dispose();

        return tempTexture;
    }
}
}
