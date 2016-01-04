package com.steffenl.superpaint.app.controls.toolstyle.detail {
import feathers.controls.LayoutGroup;
import feathers.data.ListCollection;
import feathers.layout.VerticalLayout;

import org.osflash.signals.Signal;

import starling.events.Event;

public class ColorPicker extends LayoutGroup {
    public var styleChanged:Signal = new Signal(Number, Number);

    public function ColorPicker(color:uint, alpha:uint) {

    }

    protected override function initialize():void {
        super.initialize();

        // TODO: Implement color spectrum and custom colors

        layout = new VerticalLayout();

        const presets:ListCollection = new ListCollection([
                new ColorPresetItem(0x000000),
                new ColorPresetItem(0x0000ff),
                new ColorPresetItem(0x00ff00),
                new ColorPresetItem(0x00ffff),
                new ColorPresetItem(0xff0000),
                new ColorPresetItem(0xff00ff),
                new ColorPresetItem(0xffff00),
                new ColorPresetItem(0xffffff)
        ]);

        const list:ColorPresetList = new ColorPresetList();
        list.dataProvider = presets;
        list.addEventListener(Event.CHANGE, list_changeHandler);

        addChild(list);
    }

    private function list_changeHandler(event:Event):void {
        const list:ColorPresetList = ColorPresetList(event.currentTarget);
        const preset:ColorPresetItem = list.selectedItem as ColorPresetItem;
        if (!preset) {
            return;
        }

        const alpha:Number = 1.0;
        styleChanged.dispatch(preset.color, alpha);
    }
}
}
