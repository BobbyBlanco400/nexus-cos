# N3XUS COS Component Library

## Overview

Complete component specifications for the N3XUS COS design system, following atomic design methodology.

---

## Atomic Design Structure

### Atoms (Basic Building Blocks)
- Button
- Input
- Label
- Badge
- Icon
- Avatar
- Tooltip

### Molecules (Simple Combinations)
- FormField
- Card
- NavigationItem
- SearchBox
- Dropdown
- Tabs

### Organisms (Complex Components)
- ModuleCard
- AppTile
- NavigationDock
- AppDock
- Dashboard
- ModuleGrid
- AppGrid

### Templates (Page Layouts)
- DesktopLayout
- DashboardLayout
- FoundersLayout

### Pages (Complete Views)
- HomePage
- DashboardPage
- FoundersPage
- DesktopPage

---

## Button Component

```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  icon?: React.ReactNode;
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  icon,
  loading,
  disabled,
  fullWidth,
  onClick,
  children
}) => {
  return (
    <button
      className={`button button-${variant} button-${size}`}
      disabled={disabled || loading}
      onClick={onClick}
      style={{ width: fullWidth ? '100%' : 'auto' }}
    >
      {loading ? <Spinner /> : icon}
      {children}
    </button>
  );
};
```

**Visual Specifications:**
- Primary: #2563eb background, white text, 8px radius
- Secondary: Transparent, #2563eb border and text
- Ghost: Transparent, white text, hover background
- Small: 8px vertical, 12px horizontal padding, 14px text
- Medium: 12px vertical, 24px horizontal padding, 16px text
- Large: 16px vertical, 32px horizontal padding, 20px text

---

## Card Component

```typescript
interface CardProps {
  variant?: 'default' | 'elevated' | 'outlined' | 'glassmorphic';
  padding?: 'sm' | 'md' | 'lg';
  interactive?: boolean;
  glow?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}
```

**Visual Specifications:**
- Default: #1e293b background, #334155 border, 12px radius
- Elevated: Same + shadow-lg
- Glassmorphic: rgba(30,41,59,0.8) background, 12px backdrop-blur
- Interactive: Hover transforms, border color change

---

## ModuleCard Component

```typescript
interface ModuleCardProps {
  id: string;
  name: string;
  icon: React.ReactNode;
  appCount: number;
  status: 'online' | 'offline' | 'loading';
  onClick: () => void;
}

export const ModuleCard: React.FC<ModuleCardProps> = ({
  name,
  icon,
  appCount,
  status,
  onClick
}) => {
  return (
    <Card interactive onClick={onClick} className="module-card">
      <div className="module-icon">{icon}</div>
      <h3 className="module-name">{name}</h3>
      <p className="module-app-count">{appCount} apps available</p>
      <StatusIndicator status={status} />
    </Card>
  );
};
```

**Visual Specifications:**
- Size: 280px × 200px minimum
- Icon: 48px, centered
- Name: 24px, bold, centered
- App count: 14px, muted, centered
- Status: 8px dot, bottom-right corner
- Hover: translateY(-4px), border glow

---

## AppTile Component

```typescript
interface AppTileProps {
  id: string;
  name: string;
  description: string;
  url: string;
  icon?: React.ReactNode;
}

export const AppTile: React.FC<AppTileProps> = ({
  name,
  description,
  url,
  icon
}) => {
  return (
    <Card className="app-tile">
      {icon && <div className="app-icon">{icon}</div>}
      <h4 className="app-name">{name}</h4>
      <p className="app-description">{description}</p>
      <Button variant="primary" href={url}>
        Launch App →
      </Button>
    </Card>
  );
};
```

**Visual Specifications:**
- Size: 320px × 160px minimum
- Icon: 32px, top-left
- Name: 18px, semibold
- Description: 14px, muted, 2 line max
- Button: Bottom-right, primary variant

---

## NavigationDock Component

```typescript
interface NavigationDockProps {
  items: NavItem[];
  activeItem: string;
  onItemClick: (id: string) => void;
}

interface NavItem {
  id: string;
  label: string;
  icon?: React.ReactNode;
  href?: string;
}
```

**Visual Specifications:**
- Position: Top of page, full width
- Height: 64px
- Background: rgba(30,41,59,0.95), backdrop-blur
- Items: Horizontal, centered
- Active indicator: 4px blue underline
- Spacing: 24px between items

---

## Virtual Desktop Components

### DesktopShell

```typescript
interface DesktopShellProps {
  breadcrumb: string[];
  activeTab: 'modules' | 'apps';
  onTabChange: (tab: 'modules' | 'apps') => void;
  children: React.ReactNode;
}
```

### ModuleGrid

```typescript
interface ModuleGridProps {
  modules: Module[];
  onModuleSelect: (id: string) => void;
}
```

**Layout:** CSS Grid, auto-fill, minmax(280px, 1fr), 24px gap

### AppGrid

```typescript
interface AppGridProps {
  apps: App[];
  onBack: () => void;
}
```

**Layout:** CSS Grid, auto-fill, minmax(320px, 1fr), 24px gap

---

## Accessibility Requirements

All components must:
- Support keyboard navigation
- Include ARIA labels and roles
- Meet WCAG 2.1 AA contrast ratios
- Support screen readers
- Respect prefers-reduced-motion

---

**Component Library Version:** 1.0  
**Handshake:** 55-45-17
