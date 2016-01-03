package com.steffenl.superpaint.app.controls.drawingboard {
import com.steffenl.superpaint.app.controls.*;
import com.steffenl.superpaint.app.controls.SpButton;
import com.steffenl.superpaint.core.painting.detail.PaintStyles;
import com.steffenl.superpaint.core.painting.IToolManager;
import com.steffenl.superpaint.core.painting.detail.DrawingLayer;
import com.steffenl.superpaint.core.painting.detail.ToolManager;
import com.steffenl.superpaint.core.painting.tools.ITool;
import com.steffenl.superpaint.core.painting.tools.detail.PencilTool;

import feathers.core.FeathersControl;
import feathers.events.FeathersEventType;


import flash.geom.*;

import org.osflash.signals.Signal;

import starling.display.*;
import starling.events.*;
import starling.textures.RenderTexture;
import starling.textures.Texture;

public class DrawingBoard extends FeathersControl {
    public const touchBegan:Signal = new Signal(Point, Number);
    public const touchMoved:Signal = new Signal(Point, Number);
    public const touchEnded:Signal = new Signal(Point, Number);
    public const touchHover:Signal = new Signal(Point);
    public const loaded:Signal = new Signal();

    public function get canvas():Shape {
        return _canvas;
    }

    public static const DEFAULT_CANVAS_REAL_SIZE:Point = new Point(1280, 720);
    private static const CANVAS_BACKGROUND_COLOR:uint = 0xffffff;

    // Temporary (invisible) canvas that we draw to.
    // This canvas is cleared after being rendered to a persistent texture.
    private var _canvas:Shape;
    private var _panOffset:Point = new Point(0, 0);
    private var _canvasRealSize:Point = DEFAULT_CANVAS_REAL_SIZE;
    private var _pan:Boolean = false;
    private var _touchPosition:Point;
    private var _lastTouchPosition:Point;
    // Persistent texture where we render the temporary canvas to.
    private var _texture:RenderTexture;
    // Visible canvas presented to the user.
    private var _canvasDisplayImage:Image;

    // TODO: Refactor
    public function loadTexture(texture:Texture):void {
        // Ugly workaround for loading texture before initialization...
        // It feels like a really wrong way to do it.

        const load:Function = function():void {
            removeChildren(0, numChildren - 1, true);

            _canvas = new Shape();
            _canvas.width = texture.width;
            _canvas.height = texture.height;

            var canvasBackground:Quad = new Quad(texture.width, texture.height, CANVAS_BACKGROUND_COLOR);
            addChild(canvasBackground);

            if (_texture) {
                _texture.dispose();
            }

            _texture = new RenderTexture(texture.width, texture.height);

            if (_canvasDisplayImage) {
                _canvasDisplayImage.dispose();
            }

            _canvasDisplayImage = new Image(_texture);
            _canvasDisplayImage.x = _panOffset.x;
            _canvasDisplayImage.y = _panOffset.y;
            _canvasDisplayImage.width = texture.width;
            _canvasDisplayImage.height = texture.height;
            _canvasDisplayImage.addEventListener(TouchEvent.TOUCH, touchHandler);
            addChild(_canvasDisplayImage);

            _canvas.addChild(new Image(texture));
            rasterizeCanvasShape();
            updateClipRect();
            loaded.dispatch();
        };

        if (!isCreated) {
            addEventListener(FeathersEventType.CREATION_COMPLETE, function(event:Event):void {
                load();
            });
        }
        else {
            load();
        }
    }

    // TODO: Refactor
    public static function createBlankTexture():Texture {
        return new RenderTexture(DEFAULT_CANVAS_REAL_SIZE.x, DEFAULT_CANVAS_REAL_SIZE.y);
    }

    public function getTexture():Texture {
        return _texture;
    }

    protected override function initialize():void {
        super.initialize();
    }

    private function touchHandler(event:TouchEvent):void {
        var touches:Vector.<Touch> = new <Touch>[];
        event.getTouches(_canvasDisplayImage, null, touches);

        if (touches.length === 0) {
            return;
        }

        const touch:Touch = touches[0];
        var endPan:Boolean = false;

        if (event.ctrlKey || touches.length > 1) {
            if (touch.phase === TouchPhase.BEGAN) {
                _pan = true;
            }
            else if (event.ctrlKey && touch.phase === TouchPhase.ENDED) {
                endPan = true;
            }
        }

        var position:Point;
        if (_pan) {
            if (endPan) {
                _pan = false;
                return;
            }

            position = touch.getLocation(this);

            _lastTouchPosition = _touchPosition;
            _touchPosition = position;

            if (touch.phase === TouchPhase.MOVED) {
                var offset:Point = new Point(
                        _touchPosition.x - _lastTouchPosition.x,
                        _touchPosition.y - _lastTouchPosition.y
                );

                _panOffset.x += offset.x;
                _panOffset.y += offset.y;

                _panOffset = sanitizeCanvasPosition(_panOffset);
                _canvasDisplayImage.x = _panOffset.x;
                _canvasDisplayImage.y = _panOffset.y;
                updateClipRect();
            }
        }
        else {
            position = touch.getLocation(_canvasDisplayImage);

            _lastTouchPosition = _touchPosition;
            _touchPosition = position;

            switch (touch.phase) {
                case TouchPhase.BEGAN:
                    touchBegan.dispatch(position, touch.pressure);
                    rasterizeCanvasShape();
                    break;

                case TouchPhase.MOVED:
                    touchMoved.dispatch(position, touch.pressure);
                    rasterizeCanvasShape();
                    break;

                case TouchPhase.ENDED:
                    touchEnded.dispatch(position, touch.pressure);
                    rasterizeCanvasShape();
                    break;

                case TouchPhase.HOVER:
                    touchHover.dispatch(position);
                    break;
            }
        }
    }

    private function rasterizeCanvasShape():void {
        _texture.draw(_canvas);
        _canvas.graphics.clear();
    }

    private function updateClipRect():void {
        clipRect = new Rectangle(
                Math.max(0, _panOffset.x),
                Math.max(0, _panOffset.y),
                Math.min(_panOffset.x + _texture.width, actualWidth),
                Math.min(_panOffset.y + _texture.height, actualHeight)
        );
    }

    private function sanitizeCanvasPosition(position:Point):Point {
        const center:Point = new Point(actualWidth >> 1, actualHeight >> 1);
        position.x = Math.min(center.x, Math.max(center.x - _texture.width, position.x));
        position.y = Math.min(center.y, Math.max(center.y - _texture.height, position.y));
        return position;
    }
}
}
