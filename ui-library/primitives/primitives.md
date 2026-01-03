# N3XUS COS Layout Primitives

## Overview

Layout primitives are the foundational building blocks for creating consistent, responsive layouts throughout the N3XUS COS platform.

---

## Grid System

### 12-Column Grid

```typescript
interface GridProps {
  columns?: 1 | 2 | 3 | 4 | 6 | 12;
  gap?: keyof typeof spacing;
  responsive?: boolean;
}

// Usage
<Grid columns={12} gap={6}>
  <GridItem span={4}>Column 1</GridItem>
  <GridItem span={4}>Column 2</GridItem>
  <GridItem span={4}>Column 3</GridItem>
</Grid>
```

### CSS Grid Properties

```css
.grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 24px;
}

.grid-item {
  grid-column: span 4;
}

/* Responsive */
@media (max-width: 768px) {
  .grid {
    grid-template-columns: 1fr;
  }
  .grid-item {
    grid-column: span 1;
  }
}
```

---

## Flexbox Patterns

### Stack (Vertical)

```typescript
interface StackProps {
  gap?: keyof typeof spacing;
  align?: 'start' | 'center' | 'end' | 'stretch';
  justify?: 'start' | 'center' | 'end' | 'between';
}

<Stack gap={4} align="start">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</Stack>
```

```css
.stack {
  display: flex;
  flex-direction: column;
  gap: 16px;
  align-items: flex-start;
}
```

### Inline (Horizontal)

```typescript
interface InlineProps {
  gap?: keyof typeof spacing;
  align?: 'start' | 'center' | 'end';
  wrap?: boolean;
}

<Inline gap={3} align="center" wrap>
  <Button>Action 1</Button>
  <Button>Action 2</Button>
</Inline>
```

```css
.inline {
  display: flex;
  flex-direction: row;
  gap: 12px;
  align-items: center;
  flex-wrap: wrap;
}
```

### Center

```css
.center {
  display: flex;
  align-items: center;
  justify-content: center;
}
```

### Space Between

```css
.space-between {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

---

## Container

### Max-Width Container

```typescript
interface ContainerProps {
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
  padding?: keyof typeof spacing;
}

<Container size="lg" padding={8}>
  {children}
</Container>
```

```css
.container {
  max-width: 1400px;
  margin-left: auto;
  margin-right: auto;
  padding: 32px;
}

.container-sm { max-width: 640px; }
.container-md { max-width: 768px; }
.container-lg { max-width: 1024px; }
.container-xl { max-width: 1280px; }
.container-full { max-width: 100%; }
```

---

## Responsive Breakpoints

```typescript
const breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px'
};

// Usage in styled components
const ResponsiveBox = styled.div`
  padding: 16px;
  
  @media (min-width: ${breakpoints.md}) {
    padding: 24px;
  }
  
  @media (min-width: ${breakpoints.lg}) {
    padding: 32px;
  }
`;
```

---

## Layout Utilities

### Aspect Ratio

```css
.aspect-square { aspect-ratio: 1 / 1; }
.aspect-video { aspect-ratio: 16 / 9; }
.aspect-4-3 { aspect-ratio: 4 / 3; }
```

### Overflow

```css
.overflow-auto { overflow: auto; }
.overflow-hidden { overflow: hidden; }
.overflow-scroll { overflow: scroll; }
```

### Position

```css
.relative { position: relative; }
.absolute { position: absolute; }
.fixed { position: fixed; }
.sticky { position: sticky; top: 0; }
```

---

## Module Grid (Virtual Desktop)

```typescript
interface ModuleGridProps {
  minCardWidth?: string;
  gap?: keyof typeof spacing;
}

<ModuleGrid minCardWidth="280px" gap={6}>
  {modules.map(module => (
    <ModuleCard key={module.id} {...module} />
  ))}
</ModuleGrid>
```

```css
.module-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}
```

---

## App Grid (Virtual Desktop)

```css
.app-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
}
```

---

**Primitives Version:** 1.0  
**Handshake:** 55-45-17
