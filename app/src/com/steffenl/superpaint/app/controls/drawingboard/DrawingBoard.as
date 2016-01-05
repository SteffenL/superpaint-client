package com.steffenl.superpaint.app.controls.drawingboard {

import feathers.core.FeathersControl;

import flash.display.BitmapData;
import flash.display.Shape;
import flash.events.TimerEvent;


import flash.geom.*;
import flash.utils.Timer;

import org.osflash.signals.Signal;

import starling.display.Image;
import starling.display.Quad;

import starling.events.*;
import starling.textures.Texture;

public class DrawingBoard extends FeathersControl {
    public const touchBegan:Signal = new Signal(Point, Number);
    public const touchMoved:Signal = new Signal(Point, Number);
    public const touchEnded:Signal = new Signal(Point, Number);
    public const touchHover:Signal = new Signal(Point);
    // Dispatched when a texture has been loaded for the first time
    public const ready:Signal = new Signal();

    public function get nativeCanvas():Shape {
        return _nativeCanvas;
    }

    public static const DEFAULT_CANVAS_REAL_SIZE:Point = new Point(1280, 720);
    private static const CANVAS_BACKGROUND_COLOR:uint = 0xffffff;

    private var _bitmapData:BitmapData;
    private var _nativeCanvas:Shape;
    private var _panOffset:Point = new Point(0, 0);
    private var _canvasRealSize:Point = DEFAULT_CANVAS_REAL_SIZE;
    private var _pan:Boolean = false;
    private var _touchPosition:Point;
    private var _lastTouchPosition:Point;
    // Persistent texture where we render the temporary canvas to.
    //private var _texture:RenderTexture;
    private var _texture:Texture;
    // Visible canvas presented to the user.
    private var _canvasDisplayImage:Image;
    private var _loadCount:uint = 0;
    private var _textureIsInvalid:Boolean = false;
    private const _textureUpdaterTimer:Timer = new Timer(10, 0);


    public function loadBitmapData(bitmapData:BitmapData):void {
        if (_bitmapData) {
            _bitmapData.dispose();
        }

        _bitmapData = bitmapData.clone();

        const texture:Texture = Texture.fromBitmapData(_bitmapData);
        if (_texture) {
            _texture.dispose();
        }

        _texture = texture;
        _canvasRealSize = new Point(_bitmapData.width, _bitmapData.height);

        _nativeCanvas = new Shape();
        _nativeCanvas.width = _canvasRealSize.x;
        _nativeCanvas.height = _canvasRealSize.y;

        var canvasBackground:Quad = new Quad(_canvasRealSize.x, _canvasRealSize.y, CANVAS_BACKGROUND_COLOR);
        addChild(canvasBackground);

        if (_canvasDisplayImage) {
            _canvasDisplayImage.dispose();
        }

        _canvasDisplayImage = new Image(_texture);
        _canvasDisplayImage.x = _panOffset.x;
        _canvasDisplayImage.y = _panOffset.y;
        _canvasDisplayImage.width = _canvasRealSize.x;
        _canvasDisplayImage.height = _canvasRealSize.y;
        _canvasDisplayImage.addEventListener(TouchEvent.TOUCH, touchHandler);
        addChild(_canvasDisplayImage);

        rasterizeCanvasShape();
        updateClipRect();

        if (_loadCount++ === 0) {
            _textureUpdaterTimer.addEventListener(TimerEvent.TIMER, textureUpdaterTimer_timerHandler);
            _textureUpdaterTimer.start();
            ready.dispatch();
        }
    }

    // TODO: Refactor
    public static function createBlankBitmapData():BitmapData {
        return new BitmapData(DEFAULT_CANVAS_REAL_SIZE.x, DEFAULT_CANVAS_REAL_SIZE.y);
        //return new RenderTexture(DEFAULT_CANVAS_REAL_SIZE.x, DEFAULT_CANVAS_REAL_SIZE.y);
    }

    protected override function initialize():void {
        super.initialize();
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
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
        _bitmapData.draw(_nativeCanvas);
        _nativeCanvas.graphics.clear();
        // We should recreate the rendering texture
        _textureIsInvalid = true;
    }

    private function updateClipRect():void {
        clipRect = new Rectangle(
                Math.max(0, _panOffset.x),
                Math.max(0, _panOffset.y),
                Math.min(_panOffset.x + _canvasRealSize.x, actualWidth),
                Math.min(_panOffset.y + _canvasRealSize.y, actualHeight)
        );
    }

    private function sanitizeCanvasPosition(position:Point):Point {
        const center:Point = new Point(actualWidth >> 1, actualHeight >> 1);
        position.x = Math.min(center.x, Math.max(center.x - _canvasRealSize.x, position.x));
        position.y = Math.min(center.y, Math.max(center.y - _canvasRealSize.y, position.y));
        return position;
    }

    public function capture():BitmapData {
        return _bitmapData.clone();
    }

    private function textureUpdaterTimer_timerHandler(event:TimerEvent):void {
        if (!_textureIsInvalid) {
            return;
        }

        if (_texture) {
            _texture.dispose();
            _texture = null;
        }

        _texture = Texture.fromBitmapData(_bitmapData);
        _canvasDisplayImage.texture = _texture;
    }

    private function removedFromStageHandler(event:Event):void {
        if (_textureUpdaterTimer && _textureUpdaterTimer.running) {
            _textureUpdaterTimer.stop();
        }
    }
}
}
