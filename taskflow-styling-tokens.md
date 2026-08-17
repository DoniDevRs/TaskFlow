# TaskFlow — Styling tokens (from Claude Design prototype)

Confirmed via pixel sampling of the exported prototype screens. Use these
directly in `Core/Sources/Core/Styling/Styling.swift` (T4).

## Colors

```swift
enum TFColor {
    static let background   = Color(hex: "#F7F4EE") // confirmed
    static let ink           = Color(hex: "#1C1B19") // primary text (from original brief, matches dark UI text in prototype)
    static let terracotta    = Color(hex: "#C15F3C") // confirmed — accent, high priority, overdue, FAB
    static let sage          = Color(hex: "#7C8B6F") // confirmed — low priority, completed/done state
    static let amber         = Color(hex: "#B98D4B") // medium priority — NEW, not in original 2-accent brief;
                                                       // approximate from screenshot (thin indicator, heavy
                                                       // anti-aliasing at sample scale). CONFIRM exact hex from
                                                       // the "Project HTML" export's CSS before finalizing.
}
```

## Typography

- Display/serif (screen titles, task titles, project names): New York /
  Fraunces-style serif, as specified
- Body/UI (metadata, labels, chips, buttons): grotesk/SF Pro-style, as
  specified
- Section labels ("UPCOMING", "COMPLETED", "TO DO", "SUBTASKS", "SYNC")
  render as small-caps with letter-spacing — implement as `.tracking(1.2)`
  + `.font(.caption.smallCaps())` or equivalent on the grotesk face

## Shape

- Cards/rows: soft-cornered rectangles, thin 1px hairline dividers — as
  specified, confirmed in prototype
- FAB: rounded-square (squircle), terracotta fill — confirmed
- Priority indicator: thin colored vertical bar on row's left edge —
  confirmed, now **3-way**: terracotta (high) / amber (medium) / sage (low)
- Segmented controls (List/Board toggle, priority picker): prototype
  rendered these as fully rounded pills rather than the soft-cornered
  rectangle originally specified. Keeping as-is (matches shipped
  prototype); only cards/rows/FAB follow the strict soft-corner rule.

## Open item before closing T4

Confirm exact hex for `amber` (medium priority) from the prototype's CSS
export rather than the approximated value above.
