package com.steffenl.superpaint.app.controls.toolstyle.detail {
import com.steffenl.superpaint.core.painting.detail.BrushTextureGenerator;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Slider;
import feathers.events.FeathersEventType;
import feathers.layout.VerticalLayout;

import flash.geom.Point;

import org.osflash.signals.Signal;

import starling.display.Image;
import starling.display.Quad;

import starling.events.Event;
import starling.textures.Texture;

public class StrokeStylePicker extends LayoutGroup {
    public var onStyleChanged:Signal = new Signal(Number);

    private var _widthChanged:Signal = new Signal(Number);
    private var _widthChanging:Signal = new Signal(Number);

    private static const MIN_STROKE_WIDTH:Number = 1;
    private static const MAX_STROKE_WIDTH:Number = 200;

    private var _widthLabel:Label;
    private var _brushPreviewImage:Image;
    private var _width:Number;
    private var _previewColor:uint;
    private var _previewAlpha:Number;
    private var _previewLayoutGroup:LayoutGroup = new LayoutGroup();

    public function StrokeStylePicker(initialWidth:Number, initialColor:uint, initialAlpha:Number) {
        _width = initialWidth;
        _previewColor = initialColor;
        _previewAlpha = initialAlpha;

        _widthChanged.add(function(width:Number):void {
            onStyleChanged.dispatch(width);
        });
    }

    protected override function initialize():void {
        super.initialize();

        layout = new VerticalLayout();

        _widthLabel = new Label();
        updateWidthText(_width);
        addChild(_widthLabel);

        const widthSlider:Slider = new Slider();
        widthSlider.minimum = MIN_STROKE_WIDTH;
        widthSlider.maximum = MAX_STROKE_WIDTH;
        widthSlider.step = 1;
        widthSlider.page = 10;
        widthSlider.value = _width;
        widthSlider.direction = Slider.DIRECTION_HORIZONTAL;
        widthSlider.liveDragging = true;
        widthSlider.addEventListener(Event.CHANGE, widthSlider_changeHandler);
        widthSlider.addEventListener(FeathersEventType.END_INTERACTION, widthSlider_endInteractionHandler);
        addChild(widthSlider);

        /*previewLayoutGroup.width = MAX_STROKE_WIDTH;
        previewLayoutGroup.height = MAX_STROKE_WIDTH;*/

        _brushPreviewImage = new Image(Texture.empty(1, 1));
        updateBrushPreview(_width);
        _previewLayoutGroup.addChild(_brushPreviewImage);

        addChild(_previewLayoutGroup);
    }

    private function widthSlider_changeHandler(event:Event):void {
        const slider:Slider = Slider(event.currentTarget);
        updateWidthText(slider.value);
        updateBrushPreview(slider.value);
        _widthChanging.dispatch(width);
    }

    private function widthSlider_endInteractionHandler(event:Event):void {
        const slider:Slider = Slider(event.currentTarget);
        _width = slider.value;
        _widthChanged.dispatch(slider.value);
    }

    private function updateWidthText(width:Number):void {
        _widthLabel.text = "Width: " + width;
    }

    private function updateBrushPreview(width:Number):void {
        if (_brushPreviewImage.texture) {
            _brushPreviewImage.texture.dispose();
        }

        _previewLayoutGroup.backgroundSkin = new Quad(1, 1, makeBackgroundColor(_previewColor));

        const halfWidth:Number = width / 2;
        const texture:Texture = BrushTextureGenerator.unfoldedCircle(_previewColor, _previewAlpha, halfWidth, 200, 100);
        _brushPreviewImage.texture = texture;
        _brushPreviewImage.readjustSize();
    }

    public function setColor(color:uint, alpha:Number):void {
        _previewColor = color;
        _previewAlpha = alpha;
        updateBrushPreview(_width);
    }

    /**
     * Makes an inverted background color from the specified foreground color.
     * When the colors are too similar (gray on gray), the background color defaults to black.
     * @param fgColor Foreground color.
     * @return The inverted background color.
     */
    private function makeBackgroundColor(fgColor:uint):uint {
        const invertedColor:uint = fgColor ^ 0xffffff;
        const b:uint = fgColor & 0xff;
        const g:uint = (fgColor >> 8) & 0xff;
        const r:uint = (fgColor >> 16) & 0xff;
        // Take into account gray on gray
        const x:uint = Math.abs(0x80 - ((r + g + b) / 3));
        return (x <= 0x20) ? 0 : invertedColor;
    }
}
}
