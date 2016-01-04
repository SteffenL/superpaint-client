package com.steffenl.superpaint.core.painting.detail {
import flash.geom.Point;

import starling.display.Shape;
import starling.textures.RenderTexture;
import starling.textures.Texture;

public class BrushTextureGenerator {
    public static function circle(color:uint, alpha:Number, radius:Number):Texture {
        const shape:Shape = new Shape();
        shape.graphics.beginFill(color, alpha);
        shape.graphics.drawCircle(radius, radius, radius);
        shape.graphics.endFill();

        const tempTexture:RenderTexture = new RenderTexture(radius * 2, radius * 2);
        tempTexture.draw(shape);

        shape.dispose();

        return tempTexture;
    }

    public static function unfoldedCircle(color:uint, alpha:Number, radius:Number, width:uint, height:uint):Texture {
        const shape:Shape = new Shape();
        shape.graphics.lineStyle(radius * 2, color, alpha);
        shape.graphics.moveTo(0, height * 0.5);
        shape.graphics.curveTo(width * 0.25, height * 0.25, width * 0.5, height * 0.5);
        shape.graphics.curveTo(width * 0.75, height * 0.75, width, height * 0.5);

        const tempTexture:RenderTexture = new RenderTexture(width, height);
        tempTexture.draw(shape);

        shape.dispose();

        return tempTexture;
    }
}
}
