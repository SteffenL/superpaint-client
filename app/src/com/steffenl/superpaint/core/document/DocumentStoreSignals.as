package com.steffenl.superpaint.core.document {
import org.osflash.signals.Signal;

public class DocumentStoreSignals {
    public const onListingReady:Signal = new Signal(Vector.<IDocumentStoreEntry>);
    public const onListingError:Signal = new Signal(String);
}
}
