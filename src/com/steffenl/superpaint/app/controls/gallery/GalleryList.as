package com.steffenl.superpaint.app.controls.gallery {
import com.steffenl.superpaint.app.controls.gallery.detail.GalleryItemRenderer;

import feathers.controls.List;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalLayout;
import feathers.layout.ILayout;
import feathers.layout.VerticalLayout;

import starling.events.Event;

public class GalleryList extends List {
    public static const THUMBNAIL_LIST_STYLE_NAME:String = "galleryThumbnailList";
    public static const VERTICAL_LAYOUT:uint = 1;
    public static const HORIZONTAL_LAYOUT:uint = 2;

    private var layoutInt:uint;

    public function GalleryList(layout:uint = HORIZONTAL_LAYOUT) {
        layoutInt = layout;
        addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
    }

    private function createListLayout(layout:uint):ILayout {
        const createVerticalListLayout:Function = function():ILayout {
            var listLayout:VerticalLayout = new VerticalLayout();
            listLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
            // The original gallery example includes this line, but in our case, it creates a large gap between each item
            //listLayout.hasVariableItemDimensions = true;
            return listLayout;
        };

        const createHorizontalListLayout:Function = function():ILayout {
            var listLayout:HorizontalLayout = new HorizontalLayout();
            listLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
            // The original gallery example includes this line, but in our case, it creates a large gap between each item
            //listLayout.hasVariableItemDimensions = true;
            return listLayout;
        };

        if (layout === VERTICAL_LAYOUT) {
            return createVerticalListLayout();
        }
        else if (layout === HORIZONTAL_LAYOUT) {
            return createHorizontalListLayout();
        }
        else {
            throw new Error("Invalid layout");
        }
    }

    private function creationCompleteHandler(event:Event):void {
        styleNameList.add(THUMBNAIL_LIST_STYLE_NAME);
        this.layout = createListLayout(layoutInt);

        horizontalScrollPolicy = this.layoutInt === HORIZONTAL_LAYOUT ? List.SCROLL_POLICY_ON : List.SCROLL_POLICY_OFF;
        verticalScrollPolicy = this.layoutInt === VERTICAL_LAYOUT ? List.SCROLL_POLICY_ON : List.SCROLL_POLICY_OFF;

        snapScrollPositionsToPixels = true;
        itemRendererType = GalleryItemRenderer;
    }
}
}
