# N3XUS COS Theme System

## Overview

The N3XUS COS theme system enables consistent styling, dark/light mode support, and custom theme creation.

---

## Default Theme

### Dark Theme (Default)

```typescript
export const darkTheme = {
  name: 'N3XUS Dark',
  mode: 'dark',
  colors: {
    primary: '#2563eb',
    secondary: '#8b5cf6',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    background: {
      primary: '#0a0e1a',
      secondary: '#1e293b',
      tertiary: '#334155'
    },
    surface: {
      default: '#1e293b',
      hover: '#334155',
      active: '#475569'
    },
    border: {
      default: '#334155',
      hover: '#2563eb',
      focus: '#2563eb'
    },
    text: {
      primary: '#ffffff',
      secondary: '#94a3b8',
      tertiary: '#64748b',
      disabled: '#475569'
    }
  },
  spacing: { /* spacing tokens */ },
  typography: { /* typography tokens */ },
  shadows: { /* shadow tokens */ },
  motion: { /* motion tokens */ }
};
```

---

## Theme Provider

```typescript
import { createContext, useContext, ReactNode } from 'react';

interface ThemeContextValue {
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

const ThemeContext = createContext<ThemeContextValue | undefined>(undefined);

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [theme, setTheme] = useState<Theme>(darkTheme);

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
};
```

---

## Theme Usage

```typescript
const Component = () => {
  const { theme } = useTheme();

  return (
    <div style={{
      backgroundColor: theme.colors.background.primary,
      color: theme.colors.text.primary
    }}>
      Content
    </div>
  );
};
```

---

## CSS Variables Approach

```css
:root {
  --color-primary: #2563eb;
  --color-bg-primary: #0a0e1a;
  --color-text-primary: #ffffff;
}

[data-theme="dark"] {
  --color-bg-primary: #0a0e1a;
  --color-text-primary: #ffffff;
}

[data-theme="light"] {
  --color-bg-primary: #ffffff;
  --color-text-primary: #0a0e1a;
}
```

---

**Theme System Version:** 1.0  
**Handshake:** 55-45-17
