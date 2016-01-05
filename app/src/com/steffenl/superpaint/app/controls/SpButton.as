package com.steffenl.superpaint.app.controls {

import com.steffenl.superpaint.app.controls.features.*;

import feathers.controls.Button;

/**
 * A custom button to be used in place of regular buttons.
 */
public class SpButton extends feathers.controls.Button {
    public function SpButton() {
        _tooltipFeature = new ButtonTooltipFeature(this);
    }

    private var _tooltipFeature:ButtonTooltipFeature;

    // Lets us specify a tooltip in MXML
    public function get tooltip():String {
        return _tooltipFeature.getTooltip();
    }

    public function set tooltip(value:String):void {
        _tooltipFeature.setTooltip(value);
    }
}
}
