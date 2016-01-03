package com.steffenl.superpaint.app.controls.toolstyle.generic {
import com.steffenl.superpaint.core.painting.detail.BrushTextureGenerator;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Slider;
import feathers.events.FeathersEventType;
import feathers.layout.VerticalLayout;

import org.osflash.signals.Signal;

import starling.display.Image;

import starling.events.Event;
import starling.textures.Texture;

public class StrokeStylePicker extends LayoutGroup {
    public var styleChanged:Signal = new Signal(Number);

    private var _widthChanged:Signal = new Signal(Number);
    private var _widthChanging:Signal = new Signal(Number);

    private static const MIN_STROKE_WIDTH:Number = 1;
    private static const MAX_STROKE_WIDTH:Number = 200;

    private var _widthLabel:Label;
    private var _brushPreviewImage:Image;
    private var _width:Number;

    public function StrokeStylePicker(initialWidth:Number) {
        _width = initialWidth;

        _widthChanged.add(function(width:Number):void {
            styleChanged.dispatch(width);
        });
    }

    protected override function initialize():void {
        super.initialize();

        layout = new VerticalLayout();

        _widthLabel = new Label();
        updateWidthText(_width);
        addChild(_widthLabel);

        var widthSlider:Slider = new Slider();
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

        var previewLayoutGroup:LayoutGroup = new LayoutGroup();

        previewLayoutGroup.width = MAX_STROKE_WIDTH;
        previewLayoutGroup.height = MAX_STROKE_WIDTH;

        _brushPreviewImage = new Image(Texture.empty(1, 1));
        updateBrushPreview(_width);
        previewLayoutGroup.addChild(_brushPreviewImage);

        addChild(previewLayoutGroup);
    }

    private function widthSlider_changeHandler(event:Event):void {
        var slider:Slider = Slider(event.currentTarget);
        updateWidthText(slider.value);
        updateBrushPreview(slider.value);
        _widthChanging.dispatch(width);
    }

    private function widthSlider_endInteractionHandler(event:Event):void {
        var slider:Slider = Slider(event.currentTarget);
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

        _brushPreviewImage.texture = BrushTextureGenerator.Circle(0xffffff, 1, width / 2);
        _brushPreviewImage.readjustSize();
    }
}
}
