package com.steffenl.superpaint.core.painting.detail {
import flash.geom.Point;

import starling.display.Graphics;

import starling.display.Shape;

public class DrawingLayer {
    private var _canvas:Shape;

    public function get canvas():Shape {
        return _canvas;
    }

    public function get graphics():Graphics {
        return _canvas.graphics;
    }

    public function DrawingLayer() {
        _canvas = new Shape();
    }
}
}
