package com.steffenl.superpaint.server.documentstore {

import org.osflash.signals.Signal;

public class DocumentStoreApiSignals {
    public const onListingReady:Signal = new Signal(Vector.<DocumentStoreApiEntry>);
    public const onListingError:Signal = new Signal(String);
}
}
