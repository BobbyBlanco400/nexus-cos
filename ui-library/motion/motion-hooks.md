# N3XUS COS Motion System & Hooks

## Overview

The motion system provides consistent, performant animations throughout N3XUS COS using React hooks and predefined animation patterns.

---

## Motion Tokens

```typescript
export const motion = {
  duration: {
    instant: 0,
    fast: 150,
    base: 250,
    slow: 350,
    slower: 500
  },
  easing: {
    standard: 'cubic-bezier(0.4, 0.0, 0.2, 1)',
    decelerate: 'cubic-bezier(0.0, 0.0, 0.2, 1)',
    accelerate: 'cubic-bezier(0.4, 0.0, 1, 1)',
    sharp: 'cubic-bezier(0.4, 0.0, 0.6, 1)',
    spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)'
  }
};
```

---

## React Animation Hooks

### useTransition

```typescript
export const useTransition = (
  isVisible: boolean,
  duration = motion.duration.base
): boolean => {
  const [shouldRender, setShouldRender] = useState(isVisible);

  useEffect(() => {
    if (isVisible) {
      setShouldRender(true);
    } else {
      const timer = setTimeout(() => setShouldRender(false), duration);
      return () => clearTimeout(timer);
    }
  }, [isVisible, duration]);

  return shouldRender;
};

// Usage
const Component = ({ isOpen }) => {
  const shouldRender = useTransition(isOpen);
  
  if (!shouldRender) return null;
  
  return <div className={isOpen ? 'visible' : 'hidden'}>Content</div>;
};
```

### useFade

```typescript
export const useFade = (isVisible: boolean) => {
  return {
    opacity: isVisible ? 1 : 0,
    transition: `opacity ${motion.duration.fast}ms ${motion.easing.standard}`
  };
};

// Usage
const Component = ({ isVisible }) => {
  const fadeStyle = useFade(isVisible);
  return <div style={fadeStyle}>Fading content</div>;
};
```

### useSlide

```typescript
type Direction = 'up' | 'down' | 'left' | 'right';

export const useSlide = (
  isVisible: boolean,
  direction: Direction = 'up'
) => {
  const transforms = {
    up: 'translateY(20px)',
    down: 'translateY(-20px)',
    left: 'translateX(20px)',
    right: 'translateX(-20px)'
  };

  return {
    transform: isVisible ? 'translate(0)' : transforms[direction],
    opacity: isVisible ? 1 : 0,
    transition: `all ${motion.duration.base}ms ${motion.easing.decelerate}`
  };
};

// Usage
const Component = ({ isVisible }) => {
  const slideStyle = useSlide(isVisible, 'up');
  return <div style={slideStyle}>Sliding content</div>;
};
```

### useScale

```typescript
export const useScale = (isVisible: boolean, springy = false) => {
  return {
    transform: isVisible ? 'scale(1)' : 'scale(0.95)',
    opacity: isVisible ? 1 : 0,
    transition: `all ${motion.duration.base}ms ${
      springy ? motion.easing.spring : motion.easing.standard
    }`
  };
};
```

### useReducedMotion

```typescript
export const useReducedMotion = (): boolean => {
  const [prefersReducedMotion, setPrefersReducedMotion] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setPrefersReducedMotion(mediaQuery.matches);

    const handleChange = (e: MediaQueryListEvent) => {
      setPrefersReducedMotion(e.matches);
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, []);

  return prefersReducedMotion;
};

// Usage
const Component = () => {
  const prefersReducedMotion = useReducedMotion();
  const animationDuration = prefersReducedMotion ? 0 : motion.duration.base;
  
  return <div style={{ transition: `all ${animationDuration}ms` }}>Content</div>;
};
```

---

## CSS Animation Classes

### Fade Animations

```css
.fade-enter {
  opacity: 0;
}

.fade-enter-active {
  opacity: 1;
  transition: opacity 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
}

.fade-exit {
  opacity: 1;
}

.fade-exit-active {
  opacity: 0;
  transition: opacity 150ms cubic-bezier(0.4, 0.0, 1, 1);
}
```

### Slide Animations

```css
.slide-up-enter {
  transform: translateY(20px);
  opacity: 0;
}

.slide-up-enter-active {
  transform: translateY(0);
  opacity: 1;
  transition: all 250ms cubic-bezier(0.0, 0.0, 0.2, 1);
}

.slide-up-exit {
  transform: translateY(0);
  opacity: 1;
}

.slide-up-exit-active {
  transform: translateY(-20px);
  opacity: 0;
  transition: all 200ms cubic-bezier(0.4, 0.0, 1, 1);
}
```

### Scale Animations

```css
.scale-enter {
  transform: scale(0.95);
  opacity: 0;
}

.scale-enter-active {
  transform: scale(1);
  opacity: 1;
  transition: all 200ms cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

---

## Framer Motion Variants

```typescript
export const fadeVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 }
};

export const slideUpVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: { y: 0, opacity: 1 }
};

export const scaleVariants = {
  hidden: { scale: 0.95, opacity: 0 },
  visible: { scale: 1, opacity: 1 }
};

export const staggerContainer = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05
    }
  }
};

// Usage with Framer Motion
<motion.div
  initial="hidden"
  animate="visible"
  variants={fadeVariants}
  transition={{ duration: 0.25 }}
>
  Content
</motion.div>
```

---

## Performance Guidelines

### Use GPU-Accelerated Properties

✅ **DO animate:**
- `transform`
- `opacity`

❌ **DON'T animate:**
- `width`, `height`
- `top`, `left`, `right`, `bottom`
- `margin`, `padding`

### will-change

```css
/* Add before animation */
.animating-element {
  will-change: transform, opacity;
}

/* Remove after animation */
.animating-element.animation-complete {
  will-change: auto;
}
```

### Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

**Motion System Version:** 1.0  
**Handshake:** 55-45-17
