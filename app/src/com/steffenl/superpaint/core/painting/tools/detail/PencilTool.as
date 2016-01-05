package com.steffenl.superpaint.core.painting.tools.detail {
import com.steffenl.superpaint.core.painting.detail.PaintStyles;
import com.steffenl.superpaint.core.painting.tools.ITool;

import flash.geom.Point;

import flash.display.Shape;

public class PencilTool implements ITool {
    public static const ID:String = "87038ed0-fa8c-4e2f-a1db-5cf5f680e3c1";

    public function PencilTool() {
    }

    public function getId():String {
        return ID;
    }

    public function getDisplayName():String {
        return "Pencil";
    }

    public function beginAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
        _draw(position, canvas, standardStyles);
    }

    public function updateAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
        _draw(position, canvas, standardStyles);
    }

    public function endAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }

    private function _draw(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
        // TODO: Size stroke according to pressure
        const width:Number = standardStyles.strokeWidth;
        const halfWidth:Number = width / 2;

        canvas.graphics.beginFill(standardStyles.strokeColor, standardStyles.strokeAlpha);

        if (standardStyles.strokeWidth > 1) {
            canvas.graphics.drawCircle(position.x, position.y, halfWidth);
        }
        else {
            // Optimization for the smallest stroke width
            canvas.graphics.drawRect(Number.floor(position.x - halfWidth), Number.floor(position.y - halfWidth), width, width);
        }

        canvas.graphics.endFill();
    }
}
}
