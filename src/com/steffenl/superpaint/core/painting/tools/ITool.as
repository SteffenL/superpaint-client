package com.steffenl.superpaint.core.painting.tools {

import com.steffenl.superpaint.core.painting.detail.PaintStyles;

import flash.geom.Point;

import starling.display.Graphics;
import starling.display.Shape;

public interface ITool {
    // UUID (v4)
    function getId():String;
    function getDisplayName():String;
    function beginAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void;
    function updateAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void;
    function endAction(position:Point, canvas:Shape, standardStyles:PaintStyles):void;
}
}
