package com.steffenl.superpaint.app.controls.toolstyle.detail {
import feathers.controls.List;
import feathers.events.FeathersEventType;
import feathers.layout.FlowLayout;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;

import starling.events.Event;

public class ColorPresetList extends List {
    public static const LIST_STYLE_NAME:String = "colorPresetList";

    public function ColorPresetList() {
        addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
    }

    private function creationCompleteHandler(event:Event):void {
        styleNameList.add(LIST_STYLE_NAME);
        this.layout = createListLayout();
        verticalScrollPolicy = List.SCROLL_POLICY_OFF;
        horizontalScrollPolicy = List.SCROLL_POLICY_OFF;
        itemRendererType = ColorPresetItemRenderer;
    }

    private function createListLayout():ILayout {
        var listLayout:HorizontalLayout = new HorizontalLayout();
        return listLayout;
    }
}
}
