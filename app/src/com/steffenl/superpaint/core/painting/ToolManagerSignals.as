package com.steffenl.superpaint.core.painting {
import org.osflash.signals.Signal;

public class ToolManagerSignals {
    // Dispatched when a tool has been added.
    public var toolAdded:Signal = new Signal();
    // Dispatched when the active tool was changed (tools may be null).
    public var activeToolChanged:Signal = new Signal();
}
}
