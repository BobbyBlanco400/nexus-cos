# N3XUS COS Design Tokens

## Overview

Design tokens are the atomic values of our design system—the single source of truth for colors, typography, spacing, and more. They ensure consistency across the entire platform and enable theming.

---

## Color Tokens

### Primary Colors

```typescript
export const colors = {
  primary: {
    main: '#2563eb',
    hover: '#1d4ed8',
    active: '#1e40af',
    disabled: 'rgba(37, 99, 235, 0.5)'
  },
  secondary: {
    main: '#8b5cf6',
    hover: '#7c3aed',
    active: '#6d28d9',
    disabled: 'rgba(139, 92, 246, 0.5)'
  },
  success: {
    main: '#10b981',
    hover: '#059669',
    active: '#047857',
    disabled: 'rgba(16, 185, 129, 0.5)'
  },
  warning: {
    main: '#f59e0b',
    hover: '#d97706',
    active: '#b45309',
    disabled: 'rgba(245, 158, 11, 0.5)'
  },
  error: {
    main: '#ef4444',
    hover: '#dc2626',
    active: '#b91c1c',
    disabled: 'rgba(239, 68, 68, 0.5)'
  }
};
```

### Neutral Scale

```typescript
export const neutral = {
  900: '#0a0e1a', // Deep Space
  800: '#1e293b', // Void
  700: '#334155', // Shadow
  600: '#475569', // Slate
  500: '#64748b', // Stone
  400: '#94a3b8', // Mist
  300: '#cbd5e1', // Fog
  200: '#e2e8f0', // Cloud
  100: '#f1f5f9', // Light
  white: '#ffffff'
};
```

### Semantic Colors

```typescript
export const semantic = {
  background: {
    primary: neutral[900],
    secondary: neutral[800],
    tertiary: neutral[700]
  },
  surface: {
    default: neutral[800],
    hover: neutral[700],
    active: neutral[600]
  },
  border: {
    default: neutral[700],
    hover: colors.primary.main,
    focus: colors.primary.main
  },
  text: {
    primary: neutral.white,
    secondary: neutral[400],
    tertiary: neutral[500],
    disabled: neutral[600]
  }
};
```

---

## Typography Tokens

### Font Families

```typescript
export const fontFamily = {
  sans: 'Inter, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif',
  mono: '"JetBrains Mono", "SF Mono", Monaco, Consolas, monospace'
};
```

### Font Sizes

```typescript
export const fontSize = {
  xs: '12px',    // 0.75rem
  sm: '14px',    // 0.875rem
  base: '16px',  // 1rem
  lg: '20px',    // 1.25rem
  xl: '24px',    // 1.5rem
  '2xl': '32px', // 2rem
  '3xl': '48px', // 3rem
  '4xl': '64px', // 4rem
  '5xl': '96px'  // 6rem
};
```

### Font Weights

```typescript
export const fontWeight = {
  normal: 400,
  medium: 500,
  semibold: 600,
  bold: 700
};
```

### Line Heights

```typescript
export const lineHeight = {
  tight: 1.2,
  normal: 1.5,
  relaxed: 1.6,
  loose: 2
};
```

### Letter Spacing

```typescript
export const letterSpacing = {
  tighter: '-0.02em',
  tight: '-0.01em',
  normal: '0em',
  wide: '0.01em',
  wider: '0.02em'
};
```

---

## Spacing Tokens

### Spacing Scale

```typescript
export const spacing = {
  0: '0',
  1: '4px',
  2: '8px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  8: '32px',
  10: '40px',
  12: '48px',
  16: '64px',
  20: '80px',
  24: '96px',
  32: '128px',
  40: '160px',
  48: '192px'
};
```

---

## Border Tokens

### Border Radius

```typescript
export const borderRadius = {
  none: '0',
  sm: '4px',
  base: '8px',
  md: '12px',
  lg: '16px',
  xl: '24px',
  '2xl': '32px',
  full: '9999px'
};
```

### Border Width

```typescript
export const borderWidth = {
  0: '0',
  1: '1px',
  2: '2px',
  4: '4px',
  8: '8px'
};
```

---

## Shadow Tokens

```typescript
export const shadows = {
  sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
  base: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
  md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
  lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
  xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
  '2xl': '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
  glow: '0 0 24px rgba(37, 99, 235, 0.4)',
  inner: 'inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)'
};
```

---

## Motion Tokens

### Duration

```typescript
export const duration = {
  instant: 0,
  fast: 150,
  base: 250,
  slow: 350,
  slower: 500
};
```

### Easing

```typescript
export const easing = {
  standard: 'cubic-bezier(0.4, 0.0, 0.2, 1)',
  decelerate: 'cubic-bezier(0.0, 0.0, 0.2, 1)',
  accelerate: 'cubic-bezier(0.4, 0.0, 1, 1)',
  sharp: 'cubic-bezier(0.4, 0.0, 0.6, 1)',
  spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)'
};
```

---

## Breakpoint Tokens

```typescript
export const breakpoints = {
  xs: '0px',
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px'
};
```

---

## Z-Index Tokens

```typescript
export const zIndex = {
  hide: -1,
  base: 0,
  dropdown: 1000,
  sticky: 1100,
  modal: 1300,
  popover: 1400,
  tooltip: 1500,
  toast: 1600
};
```

---

## Usage Examples

### CSS Variables

```css
:root {
  /* Colors */
  --color-primary: #2563eb;
  --color-bg-primary: #0a0e1a;
  --color-text-primary: #ffffff;
  
  /* Spacing */
  --spacing-4: 16px;
  --spacing-6: 24px;
  
  /* Typography */
  --font-sans: Inter, system-ui, sans-serif;
  --font-size-base: 16px;
  
  /* Motion */
  --duration-base: 250ms;
  --easing-standard: cubic-bezier(0.4, 0.0, 0.2, 1);
}
```

### TypeScript/React

```typescript
import { colors, spacing, fontSize } from '@/tokens';

const buttonStyles = {
  backgroundColor: colors.primary.main,
  padding: `${spacing[3]} ${spacing[6]}`,
  fontSize: fontSize.base
};
```

### Tailwind Config

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#2563eb',
        neutral: {
          900: '#0a0e1a',
          // ... rest of scale
        }
      },
      spacing: {
        1: '4px',
        2: '8px',
        // ... rest of scale
      }
    }
  }
};
```

---

**Token Version:** 1.0  
**Handshake:** 55-45-17
