package com.steffenl.superpaint.core.painting.tools.detail {
import com.steffenl.superpaint.core.painting.detail.DrawingLayer;
import com.steffenl.superpaint.core.painting.detail.PaintStyles;
import com.steffenl.superpaint.core.painting.tools.ITool;

import flash.geom.Point;

import starling.display.Graphics;
import starling.display.Shape;

public class FakeTool implements ITool {
    public static const ID:String = "260d23c8-a242-4419-9a89-0240acee601c";

    public function FakeTool() {
    }

    public function getId():String {
        return ID;
    }

    public function getDisplayName():String {
        return "Fake";
    }

    public function beginAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }

    public function updateAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }

    public function endAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void {
    }
}
}
