# 🎨 **Dora App Design System — v1 (Founder Contract)**

---

## 1️⃣ Design Philosophy

> **Calm · Curious · Premium · Creator-First · Story-Focused · Tool-Ready**

Principles:

* UI must never overpower maps, photos, or stories
* Dora = subtle guide, not a mascot
* Creation tools must feel powerful, not playful
* Browsing = relaxed mode
* Editing = focused workspace
* Export = cinematic studio

---

## 2️⃣ Brand Personality (Dora Layer)

Dora is expressed via:

* Microcopy
* Empty states
* Suggestions
* Onboarding
* Search hints

Tone:

* Friendly
* Encouraging
* Curious
* Intelligent
* Never childish

Examples (style reference only):

> “Let’s explore this together.”
> “Want help finding your next stop?”
> “Nice progress — keep going.”

No avatars. No cartoon UI.

---

## 3️⃣ Color System

### 🎯 Primary Palette (Base Theme)

| Token           | Hex       | Usage                     |
| --------------- | --------- | ------------------------- |
| `primary`       | `#86726B` | Brand headers, highlights |
| `surface`       | `#F5F2EF` | App background            |
| `card`          | `#FFFFFF` | Cards, sheets             |
| `textPrimary`   | `#000000` | Main text                 |
| `textSecondary` | `#5F5F5F` | Hints, metadata           |
| `divider`       | `#E0DDD8` | Subtle separators         |

---

### 🔥 Accent Palette (Tool & Action Mode)

**Single Accent: Deep Teal**

| Token        | Hex       |
| ------------ | --------- |
| `accent`     | `#1F6F78` |
| `accentSoft` | `#E6F2F3` |

Used for:

* Create button
* Active map tools
* Selected routes
* Primary CTAs
* Export button

Never use accent decoratively.

---

### 🌑 Dark / Export Mode (Cinematic)

| Token         | Hex       |
| ------------- | --------- |
| `darkBg`      | `#121212` |
| `darkSurface` | `#1C1C1C` |
| `darkText`    | `#FFFFFF` |
| `darkMuted`   | `#9A9A9A` |

Used only in:

* Export flow
* Preview
* Video player
* Studio mode

---

## 4️⃣ Typography System

### Font

> **SF Pro (Primary)**

Flutter:

```dart
fontFamily: 'SF Pro Display'
```

Fallback:

```
San Francisco
Roboto
System UI
```

---

### Type Scale

| Role    | Size | Weight   | Usage                  |
| ------- | ---- | -------- | ---------------------- |
| H1      | 28   | Bold     | Page titles            |
| H2      | 22   | SemiBold | Section headers        |
| H3      | 18   | Medium   | Card titles            |
| Body    | 15   | Regular  | Main content           |
| Caption | 12   | Regular  | Meta, timestamps, tags |

Never below 12.

---

## 5️⃣ Spacing System (8pt Grid)

All spacing must follow this.

| Token | Px |
| ----- | -- |
| xs    | 4  |
| sm    | 8  |
| md    | 16 |
| lg    | 24 |
| xl    | 32 |
| xxl   | 48 |

No custom spacing allowed.

---

## 6️⃣ Border Radius System

| Token | Radius |
| ----- | ------ |
| sm    | 8      |
| md    | 12     |
| lg    | 20     |
| xl    | 28     |

Usage:

* Cards → md
* Sheets → lg
* Modals → xl
* Floating tools → lg

---

## 7️⃣ Elevation & Shadows

Only soft shadows.

```dart
BoxShadow(
  blurRadius: 8,
  offset: Offset(0, 2),
  color: Colors.black.withOpacity(0.08),
)
```

No heavy Material shadows.

---

## 8️⃣ Component Rules

### 🧩 Cards

```
BG: card
Radius: 12
Padding: 16
Shadow: soft
```

Used for:

* Trip feed
* Timeline items
* Places
* Media
* Export templates

---

### 🔘 Buttons

#### Primary

```
BG: accent
Text: white
Height: 48
Radius: 12
```

#### Secondary

```
BG: transparent
Border: accent
```

#### Destructive

```
BG: red
Text: white
Use rarely
```

---

### 📜 Bottom Sheets

Default interaction surface.

```
Radius: 24 (top)
BG: card
Drag handle visible
Scrollable
```

Avoid full-screen modals unless required.

---

## 9️⃣ Navigation & Layout Rules

### Bottom Tab Bar

Always visible:

```
Feed | Create | My Trips | Profile
```

No hidden primary navigation.

---

### Page Structure

Every main screen:

```
Header
Primary Content
Secondary Actions
Tab Bar
```

No clutter.

---

## 🔟 Map UI Rules (Critical)

### Overlay

Map must always have:

```
10% dark overlay
```

When UI is on top.

---

### Controls

All map tools:

* Floating
* Rounded
* Blurred background
* Clearly separated

No raw icons.

---

## 1️⃣1️⃣ Timeline & Editor Modes

### Browse Mode

```
Muted colors
Minimal tools
Focus on story
```

---

### Editor Mode

```
Accent highlights
Visible toolbar
Selection outlines
Undo/redo
```

Mode switch must be obvious.

---

## 1️⃣2️⃣ Export / Video Mode

Export = Studio Mode.

Rules:

* Dark theme
* No tab bar
* No notifications
* Full focus
* Clear progress UI

Feels like video editing software.

---

## 1️⃣3️⃣ Motion & Animation

### Allowed

✅ Fade
✅ Slide
✅ Small scale
✅ Hero

---

### Timing

| Speed  | ms  |
| ------ | --- |
| Fast   | 150 |
| Normal | 250 |
| Slow   | 400 |

No bounce. No elastic.

---

## 1️⃣4️⃣ Accessibility

Mandatory:

* Contrast ≥ 4.5
* Tap ≥ 44px
* Font scaling
* Screen reader labels

No exceptions.

---

## 1️⃣5️⃣ Flutter Theme Skeleton

```dart
class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'SF Pro Display',

    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF86726B),
      primary: Color(0xFF86726B),
      secondary: Color(0xFF1F6F78),
      background: Color(0xFFF5F2EF),
    ),

    scaffoldBackgroundColor: Color(0xFFF5F2EF),

    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1F6F78),
        foregroundColor: Colors.white,
        minimumSize: Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
```

No inline styles outside theme.

---

## 1️⃣6️⃣ Golden Rule (Non-Negotiable)

Add to PRD:

> ❗ No custom colors, fonts, spacing, or shadows.
> All UI must use AppTheme tokens.
> Violations must be refactored.

---

## 🏁 Expected Result

If this system is enforced:

✔ Dora feels cohesive
✔ Brand is strong
✔ AI agents stay aligned
✔ UI scales cleanly
✔ Exports look premium
✔ Easy redesign later

This is how products stay clean.

---

## ✅ Bottom Line

This is now:

* Your brand
* Your visual language
* Your UX contract
* Your AI guardrail


