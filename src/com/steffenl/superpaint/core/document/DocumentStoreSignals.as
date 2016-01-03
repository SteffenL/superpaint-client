package com.steffenl.superpaint.core.document {
import org.osflash.signals.Signal;

public class DocumentStoreSignals {
    public const listingReady:Signal = new Signal(Vector.<IDocumentStoreEntry>);
    public const listingError:Signal = new Signal(String);
}
}
