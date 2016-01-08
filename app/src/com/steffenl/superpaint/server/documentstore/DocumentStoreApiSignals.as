package com.steffenl.superpaint.server.documentstore {

import org.osflash.signals.Signal;

public class DocumentStoreApiSignals {
    public const listingReady:Signal = new Signal(Vector.<DocumentStoreApiEntry>);
    public const listingError:Signal = new Signal(String);
}
}
