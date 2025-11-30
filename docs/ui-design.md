# Selona - UI Design Document

## 1. Design Philosophy

### 1.1 Core Principles
- **Serenity**: Calm, quiet, non-intrusive interface
- **Safety**: Users feel secure, nothing embarrassing visible
- **Simplicity**: Minimal UI, focus on content
- **Elegance**: Sophisticated dark aesthetic

### 1.2 Brand Keywords
- Moonlight, Night, Quiet, Private, Safe, Serene, Elegant

---

## 2. Color Palette

### 2.1 Primary Colors (Dark Theme Only)

| Name | Hex | Usage |
|------|-----|-------|
| Background Primary | `#0D1117` | Main background |
| Background Secondary | `#161B22` | Cards, panels |
| Background Tertiary | `#21262D` | Elevated surfaces |
| Surface | `#30363D` | Input fields, buttons |

### 2.2 Accent Colors

| Name | Hex | Usage |
|------|-----|-------|
| Primary Accent | `#7C8DB5` | Primary actions, links |
| Secondary Accent | `#9BA8C7` | Secondary elements |
| Moon Glow | `#C9D1D9` | Highlights, important text |

### 2.3 Text Colors

| Name | Hex | Usage |
|------|-----|-------|
| Text Primary | `#E6EDF3` | Main text |
| Text Secondary | `#8B949E` | Secondary text, hints |
| Text Muted | `#6E7681` | Disabled, placeholder |

### 2.4 Semantic Colors

| Name | Hex | Usage |
|------|-----|-------|
| Success | `#3FB950` | Success states |
| Warning | `#D29922` | Warning states |
| Error | `#F85149` | Error states |
| Info | `#58A6FF` | Information |

---

## 3. Typography

### 3.1 Font Family
- **Primary**: System default sans-serif
  - iOS: San Francisco
  - Android: Roboto
  - Windows: Segoe UI
  - macOS: San Francisco
  - Linux: Ubuntu / Noto Sans

### 3.2 Type Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Display | 32sp | Bold | Splash, empty states |
| Headline | 24sp | SemiBold | Screen titles |
| Title | 18sp | SemiBold | Section headers |
| Body Large | 16sp | Regular | Primary content |
| Body | 14sp | Regular | Default text |
| Caption | 12sp | Regular | Secondary info |
| Overline | 10sp | Medium | Labels, badges |

---

## 4. Iconography

### 4.1 App Icon

**Default Icon**:
- Concept: Abstract crescent moon with subtle gradient
- Style: Minimal, elegant, no obvious meaning
- Colors: Gradient from `#7C8DB5` to `#9BA8C7` on dark background

**Disguise Icons**:
1. Calculator - Simple calculator icon
2. Notes - Notepad icon
3. Weather - Cloud/sun icon
4. Utilities - Gear/wrench icon
5. Photo Album - Generic photo icon (safe)

### 4.2 In-App Icons

| Category | Style |
|----------|-------|
| Navigation | Outlined, 24px |
| Actions | Outlined, 20px |
| Status | Filled, 16px |
| Library | Material Icons or custom |

---

## 5. Screen Designs

### 5.1 PIN Lock Screen

```
┌────────────────────────────────┐
│                                │
│                                │
│         [Moon Logo]            │
│          Selona                │
│                                │
│        Enter your PIN          │
│                                │
│      ●  ●  ○  ○  ○  ○         │
│                                │
│   ┌─────┬─────┬─────┐         │
│   │  1  │  2  │  3  │         │
│   ├─────┼─────┼─────┤         │
│   │  4  │  5  │  6  │         │
│   ├─────┼─────┼─────┤         │
│   │  7  │  8  │  9  │         │
│   ├─────┼─────┼─────┤         │
│   │     │  0  │  ⌫  │         │
│   └─────┴─────┴─────┘         │
│                                │
└────────────────────────────────┘
```

### 5.2 Library Screen (Home)

```
┌────────────────────────────────┐
│ ← Library              [+] [⚙]│
├────────────────────────────────┤
│                                │
│  ┌──────┐ ┌──────┐ ┌──────┐  │
│  │ 📁   │ │ 📁   │ │ 📁   │  │
│  │      │ │      │ │      │  │
│  │Folder│ │Folder│ │Folder│  │
│  │  1   │ │  2   │ │  3   │  │
│  └──────┘ └──────┘ └──────┘  │
│                                │
│  ┌──────┐ ┌──────┐ ┌──────┐  │
│  │ 🖼   │ │ 🎬   │ │ 🖼   │  │
│  │      │ │      │ │      │  │
│  │image1│ │video1│ │image2│  │
│  │.jpg  │ │.mp4  │ │.png  │  │
│  └──────┘ └──────┘ └──────┘  │
│                                │
└────────────────────────────────┘

[+] = Import button
[⚙] = Settings
```

### 5.3 Unified Viewer - Image Mode

**Right-hand mode (default):**
```
┌────────────────────────────────┐
│                          [✕]  │
│                                │
│                                │
│                                │
│     ┌──────────────────┐      │
│     │                  │      │
│     │                  │      │
│     │     [IMAGE]      │      │
│     │                  │      │
│     │                  │      │
│     └──────────────────┘      │
│                                │
│                                │
│         ○ ● ○ ○ ○             │
│       (page indicator)         │
│                                │
│              [縦] [横] [単]   │
│              [↻]      1/24   │
└────────────────────────────────┘
```

**Left-hand mode:**
```
┌────────────────────────────────┐
│ [✕]                           │
│                                │
│                                │
│                                │
│     ┌──────────────────┐      │
│     │                  │      │
│     │                  │      │
│     │     [IMAGE]      │      │
│     │                  │      │
│     │                  │      │
│     └──────────────────┘      │
│                                │
│                                │
│         ○ ● ○ ○ ○             │
│       (page indicator)         │
│                                │
│  [縦] [横] [単]               │
│  [↻]    1/24                  │
└────────────────────────────────┘
```

[縦] = Vertical scroll mode
[横] = Horizontal scroll mode
[単] = Single page mode
[↻] = Rotate button

### 5.4 Unified Viewer - Video Mode

**Right-hand mode (default):**
```
┌────────────────────────────────┐
│                          [✕]  │
│                                │
│                                │
│     ┌──────────────────┐      │
│     │                  │      │
│     │                  │      │
│     │     [VIDEO]      │      │
│     │                  │      │
│     │       ▶         │      │
│     │                  │      │
│     └──────────────────┘      │
│                                │
│  ──●────────────────────      │
│              0:23 / 3:45      │
│                                │
│       [◀|] [◀◀] [▶/⏸] [▶▶] [|▶]│
│       [0.5x] [1x] [2x] [↻] 🔊│
└────────────────────────────────┘
```

**Left-hand mode:**
```
┌────────────────────────────────┐
│ [✕]                           │
│                                │
│                                │
│     ┌──────────────────┐      │
│     │                  │      │
│     │                  │      │
│     │     [VIDEO]      │      │
│     │                  │      │
│     │       ▶         │      │
│     │                  │      │
│     └──────────────────┘      │
│                                │
│  ──●────────────────────      │
│  0:23 / 3:45                   │
│                                │
│[◀|] [◀◀] [▶/⏸] [▶▶] [|▶]      │
│🔊 [↻] [0.5x] [1x] [2x]        │
└────────────────────────────────┘
```

[↻] = Rotate button (persists per file)
[◀|] [|▶] = Frame step (when paused)
[0.5x] etc = Playback speed
Pinch gesture = Zoom (resets on close)

### 5.5 Settings Screen

```
┌────────────────────────────────┐
│ ← Settings                     │
├────────────────────────────────┤
│                                │
│  SECURITY                      │
│  ┌────────────────────────┐   │
│  │ PIN Lock          [ON] │   │
│  ├────────────────────────┤   │
│  │ Change PIN          →  │   │
│  └────────────────────────┘   │
│                                │
│  APPEARANCE                    │
│  ┌────────────────────────┐   │
│  │ App Icon            →  │   │
│  │ (Current: Default)     │   │
│  └────────────────────────┘   │
│                                │
│  CONTROLS                      │
│  ┌────────────────────────┐   │
│  │ Handedness          →  │   │
│  │ (Right hand)           │   │
│  ├────────────────────────┤   │
│  │ Screen Orientation  →  │   │
│  │ (Auto)                 │   │
│  └────────────────────────┘   │
│                                │
│  GENERAL                       │
│  ┌────────────────────────┐   │
│  │ Language            →  │   │
│  │ (日本語)               │   │
│  ├────────────────────────┤   │
│  │ Default View Mode   →  │   │
│  │ (Horizontal)           │   │
│  └────────────────────────┘   │
│                                │
│  ABOUT                         │
│  ┌────────────────────────┐   │
│  │ Version          1.0.0 │   │
│  ├────────────────────────┤   │
│  │ Licenses            →  │   │
│  └────────────────────────┘   │
│                                │
└────────────────────────────────┘
```

---

## 6. Component Specifications

### 6.1 Buttons

| Type | Background | Text | Border | Usage |
|------|------------|------|--------|-------|
| Primary | Accent | White | None | Main actions |
| Secondary | Transparent | Accent | 1px Accent | Secondary actions |
| Ghost | Transparent | Text | None | Tertiary actions |

### 6.2 Cards

```
Border Radius: 12px
Background: Background Secondary
Shadow: None (flat design)
Padding: 16px
```

### 6.3 Input Fields

```
Height: 48px
Border Radius: 8px
Background: Surface
Border: 1px Border (on focus: Accent)
Padding: 12px horizontal
```

### 6.4 Bottom Sheet

```
Border Radius: 16px (top only)
Background: Background Secondary
Handle: 40px × 4px, centered, Border color
Max Height: 80% screen
```

---

## 7. Animation & Motion

### 7.1 Principles
- Subtle, not distracting
- Quick transitions (150-300ms)
- Ease-out for most animations

### 7.2 Standard Durations

| Type | Duration | Curve |
|------|----------|-------|
| Micro | 150ms | ease-out |
| Short | 200ms | ease-out |
| Medium | 300ms | ease-in-out |
| Long | 400ms | ease-in-out |

### 7.3 Specific Animations

| Element | Animation |
|---------|-----------|
| Page transitions | Slide + fade |
| Image zoom | Scale with spring |
| Bottom sheet | Slide up |
| Modal | Fade + scale |
| List items | Staggered fade in |

---

## 8. Responsive Design

### 8.1 Breakpoints

| Name | Width | Usage |
|------|-------|-------|
| Mobile S | < 375px | Small phones |
| Mobile | 375-428px | Standard phones |
| Tablet | 429-1024px | Tablets, small laptops |
| Desktop | > 1024px | Desktop, large tablets |

### 8.2 Grid System

| Platform | Columns | Gutter | Margin |
|----------|---------|--------|--------|
| Mobile | 2 | 12px | 16px |
| Tablet | 3-4 | 16px | 24px |
| Desktop | 4-6 | 24px | 32px |

---

## 9. Accessibility

### 9.1 Requirements
- Minimum touch target: 44×44px
- Color contrast ratio: 4.5:1 minimum
- Support for screen readers
- Support for reduced motion preference
- Scalable text (respect system font size)

### 9.2 Focus States
- Clear focus indicators for keyboard navigation
- Logical tab order
- Skip links where appropriate
