#if os(macOS)

import AppKit

public class ZigTextField: NSTextField {
    
    var leadingPadding: CGFloat?
    var trailingPadding: CGFloat?
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.cell = VerticalCenteredTextFieldCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(leadingPadding: CGFloat, trailingPadding: CGFloat) {
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        super.init(frame: NSZeroRect)
        self.cell = VerticalCenteredTextFieldCell(leadingPadding: leadingPadding, trailingPadding: trailingPadding)
    }
    
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if let textEditor = currentEditor() {
            textEditor.selectAll(self)
        }
    }
    
    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

    public override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
                default:
                    break
                }
            } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}


class VerticalCenteredTextFieldCell: NSTextFieldCell {
    
    var leadingPadding = 18.0
    var trailingPadding = 18.0
    
    init(leadingPadding: Double = 18.0, trailingPadding: Double = 18.0) {
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        super.init(textCell: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        // call super and pass in our modified frame
        super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        // call super and pass in our modified frame
        super.select(withFrame: titleRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        // call super to get its original rect
        var rect = super.titleRect(forBounds: rect)
        // shift down a little so the draw rect is vertically centered in cell frame
        rect.origin.y += (rect.height - cellSize.height) / 2
        rect.origin.x += leadingPadding
        rect.size.width -= (leadingPadding + trailingPadding)
        // finally return the new rect
        return rect
    }
}


class VerticalCenteredSearchFieldCell: NSSearchFieldCell {
    var leadingPadding = 18.0
    var trailingPadding = 18.0
    
    init(leadingPadding: Double = 18.0, trailingPadding: Double = 18.0) {
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        super.init(textCell: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        // call super and pass in our modified frame
        super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        // call super and pass in our modified frame
        super.select(withFrame: titleRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        // call super to get its original rect
        var rect = super.titleRect(forBounds: rect)
        // shift down a little so the draw rect is vertically centered in cell frame
        rect.origin.y += (rect.height - cellSize.height) / 2
        rect.origin.x += leadingPadding
        rect.size.width -= (leadingPadding + trailingPadding)
        // finally return the new rect
        return rect
    }
}

public class ZigSearchField: NSSearchField {
    var leadingPadding: CGFloat?
    var trailingPadding: CGFloat?
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.cell = VerticalCenteredTextFieldCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(leadingPadding: CGFloat, trailingPadding: CGFloat) {
        self.leadingPadding = leadingPadding
        self.trailingPadding = trailingPadding
        super.init(frame: NSZeroRect)
        self.cell = VerticalCenteredSearchFieldCell(leadingPadding: leadingPadding, trailingPadding: trailingPadding)
    }
    
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if let textEditor = currentEditor() {
            textEditor.selectAll(self)
        }
    }
    
    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

    public override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
                default:
                    break
                }
            } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}

#endif
