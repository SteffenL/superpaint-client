package com.steffenl.superpaint.core.painting.tools.detail {
import com.steffenl.superpaint.core.painting.detail.BrushTextureGenerator;
import com.steffenl.superpaint.core.painting.detail.DrawingLayer;
import com.steffenl.superpaint.core.painting.detail.PaintStyles;
import com.steffenl.superpaint.core.painting.tools.ITool;

import flash.geom.Point;

import starling.display.Graphics;
import starling.display.Image;
import starling.display.Shape;
import starling.filters.BlurFilter;
import starling.textures.RenderTexture;
import starling.textures.Texture;

public class BrushTool implements ITool {
    public static const ID:String = "37bcb9db-2e69-42c5-a86d-a7bde9d3d176";

    private var _brushTexture:Texture = null;

    public function BrushTool() {
    }

    public function getId():String {
        return ID;
    }

    public function getDisplayName():String {
        return "Brush";
    }

    public function beginAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }

    public function updateAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }

    public function endAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }

    private function _draw(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }
}
}
