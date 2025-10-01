# Design System

Complete design system for Urban Express with bilingual support (Arabic RTL / English LTR), mobile-first approach, and PWA optimization.

## Brand Identity

### Logo & Brand
- **Name**: Urban Express
- **Tagline (Arabic)**: "توصيل سريع، خدمة موثوقة"
- **Tagline (English)**: "Fast Delivery, Reliable Service"
- **Brand Personality**: Modern, reliable, efficient, trustworthy

### Color Palette

```css
:root {
  /* Primary Colors */
  --color-primary: #10B981;      /* Urban Green - Main brand color */
  --color-primary-light: #34D399; /* Lighter variant for hover states */
  --color-primary-dark: #047857;  /* Darker variant for active states */
  
  /* Neutral Colors */
  --color-ink: #0F172A;          /* Primary text color */
  --color-ink-light: #334155;    /* Secondary text color */
  --color-surface: #F8FAFC;      /* Light background */
  --color-surface-dark: #E2E8F0; /* Darker surface variant */
  --color-white: #FFFFFF;        /* Pure white */
  
  /* Semantic Colors */
  --color-info: #3B82F6;         /* Information states */
  --color-info-light: #DBEAFE;   /* Info background */
  
  --color-warning: #F59E0B;      /* Warning states */
  --color-warning-light: #FEF3C7; /* Warning background */
  
  --color-danger: #EF4444;       /* Error/danger states */
  --color-danger-light: #FEE2E2; /* Error background */
  
  --color-success: #16A34A;      /* Success states */
  --color-success-light: #DCFCE7; /* Success background */
  
  /* Border Colors */
  --color-border: #E2E8F0;       /* Default borders */
  --color-border-light: #F1F5F9; /* Light borders */
  --color-border-focus: #10B981; /* Focus states */
}
```

### Typography

#### Font Families
```css
:root {
  /* English Typography */
  --font-family-en: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  
  /* Arabic Typography */
  --font-family-ar: 'Tajawal', 'Arabic UI Text', 'SF Arabic', 'Segoe UI Arabic', sans-serif;
  
  /* Monospace for codes/numbers */
  --font-family-mono: 'JetBrains Mono', 'Fira Code', 'SF Mono', Consolas, monospace;
}
```

#### Type Scale
```css
:root {
  /* Font Sizes */
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;    /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  --text-4xl: 2rem;      /* 32px */
  
  /* Line Heights */
  --leading-tight: 1.25;
  --leading-normal: 1.4;
  --leading-relaxed: 1.6;
  
  /* Font Weights */
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;
}
```

#### Typography Classes
```css
/* Display Typography */
.text-display {
  font-size: var(--text-4xl);
  font-weight: var(--font-bold);
  line-height: var(--leading-tight);
}

/* Headings */
.text-h1 {
  font-size: var(--text-2xl);
  font-weight: var(--font-semibold);
  line-height: var(--leading-tight);
}

.text-h2 {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  line-height: var(--leading-normal);
}

/* Body Text */
.text-body {
  font-size: var(--text-base);
  font-weight: var(--font-normal);
  line-height: var(--leading-relaxed);
}

.text-body-sm {
  font-size: var(--text-sm);
  font-weight: var(--font-normal);
  line-height: var(--leading-normal);
}

/* Caption Text */
.text-caption {
  font-size: var(--text-xs);
  font-weight: var(--font-normal);
  line-height: var(--leading-normal);
  color: var(--color-ink-light);
}
```

## Spacing & Layout

### Spacing Scale
```css
:root {
  --space-0: 0;
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-5: 1.25rem;  /* 20px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */
  --space-10: 2.5rem;  /* 40px */
  --space-12: 3rem;    /* 48px */
  --space-16: 4rem;    /* 64px */
  --space-20: 5rem;    /* 80px */
}
```

### Border Radius
```css
:root {
  --radius-sm: 0.25rem;   /* 4px */
  --radius: 0.5rem;       /* 8px */
  --radius-md: 0.75rem;   /* 12px */
  --radius-lg: 1rem;      /* 16px */
  --radius-xl: 1.5rem;    /* 24px */
  --radius-full: 9999px;  /* Fully rounded */
}
```

### Shadows
```css
:root {
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
}
```

## Responsive Design

### Breakpoints
```css
:root {
  --breakpoint-sm: 640px;   /* Small devices */
  --breakpoint-md: 768px;   /* Medium devices */
  --breakpoint-lg: 1024px;  /* Large devices */
  --breakpoint-xl: 1280px;  /* Extra large devices */
}
```

### Grid System
```css
.container {
  width: 100%;
  margin: 0 auto;
  padding: 0 var(--space-4);
}

@media (min-width: 640px) {
  .container { max-width: 640px; }
}

@media (min-width: 768px) {
  .container { max-width: 768px; }
}

@media (min-width: 1024px) {
  .container { max-width: 1024px; }
}

@media (min-width: 1280px) {
  .container { max-width: 1280px; }
}
```

## Component Library

### Button Components

```css
/* Base Button */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-lg);
  font-weight: var(--font-medium);
  font-size: var(--text-base);
  line-height: var(--leading-normal);
  text-decoration: none;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  min-height: 48px; /* Accessibility touch target */
  
  /* Disabled state */
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  /* Focus state */
  &:focus-visible {
    outline: 2px solid var(--color-border-focus);
    outline-offset: 2px;
  }
}

/* Primary Button */
.btn-primary {
  background-color: var(--color-primary);
  color: var(--color-white);
  
  &:hover:not(:disabled) {
    background-color: var(--color-primary-dark);
  }
  
  &:active {
    background-color: var(--color-primary-dark);
    transform: translateY(1px);
  }
}

/* Secondary Button */
.btn-secondary {
  background-color: transparent;
  color: var(--color-primary);
  border-color: var(--color-primary);
  
  &:hover:not(:disabled) {
    background-color: var(--color-primary);
    color: var(--color-white);
  }
}

/* Tertiary Button */
.btn-tertiary {
  background-color: transparent;
  color: var(--color-ink);
  
  &:hover:not(:disabled) {
    background-color: var(--color-surface-dark);
  }
}

/* Danger Button */
.btn-danger {
  background-color: var(--color-danger);
  color: var(--color-white);
  
  &:hover:not(:disabled) {
    background-color: #dc2626;
  }
}

/* Button Sizes */
.btn-sm {
  padding: var(--space-2) var(--space-4);
  font-size: var(--text-sm);
  min-height: 40px;
}

.btn-lg {
  padding: var(--space-4) var(--space-8);
  font-size: var(--text-lg);
  min-height: 56px;
}

/* Full Width Button */
.btn-full {
  width: 100%;
}
```

### Input Components

```css
/* Base Input */
.input {
  width: 100%;
  padding: var(--space-3) var(--space-4);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-lg);
  font-size: var(--text-base);
  line-height: var(--leading-normal);
  background-color: var(--color-white);
  color: var(--color-ink);
  min-height: 48px; /* Accessibility */
  transition: border-color 0.2s ease-in-out;
  
  &::placeholder {
    color: var(--color-ink-light);
  }
  
  &:focus {
    outline: none;
    border-color: var(--color-border-focus);
    box-shadow: 0 0 0 3px rgb(16 185 129 / 0.1);
  }
  
  &:disabled {
    background-color: var(--color-surface);
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  &.error {
    border-color: var(--color-danger);
  }
}

/* Input Group */
.input-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.input-label {
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: var(--color-ink);
}

.input-error {
  font-size: var(--text-sm);
  color: var(--color-danger);
}

.input-hint {
  font-size: var(--text-sm);
  color: var(--color-ink-light);
}
```

### Card Components

```css
.card {
  background-color: var(--color-white);
  border-radius: var(--radius-xl);
  border: 1px solid var(--color-border-light);
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  transition: box-shadow 0.2s ease-in-out;
  
  &:hover {
    box-shadow: var(--shadow);
  }
}

.card-header {
  padding: var(--space-6);
  border-bottom: 1px solid var(--color-border-light);
}

.card-body {
  padding: var(--space-6);
}

.card-footer {
  padding: var(--space-6);
  border-top: 1px solid var(--color-border-light);
  background-color: var(--color-surface);
}

/* Interactive Card */
.card-interactive {
  cursor: pointer;
  
  &:hover {
    box-shadow: var(--shadow-md);
    transform: translateY(-2px);
  }
  
  &:active {
    transform: translateY(0);
  }
}
```

### Status Components

```css
/* Status Badges */
.badge {
  display: inline-flex;
  align-items: center;
  gap: var(--space-1);
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-full);
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.badge-success {
  background-color: var(--color-success-light);
  color: var(--color-success);
}

.badge-warning {
  background-color: var(--color-warning-light);
  color: var(--color-warning);
}

.badge-danger {
  background-color: var(--color-danger-light);
  color: var(--color-danger);
}

.badge-info {
  background-color: var(--color-info-light);
  color: var(--color-info);
}

.badge-neutral {
  background-color: var(--color-surface-dark);
  color: var(--color-ink-light);
}

/* Order Status Specific */
.status-placed { @extend .badge-info; }
.status-confirmed { @extend .badge-info; }
.status-picking { @extend .badge-warning; }
.status-packed { @extend .badge-warning; }
.status-ready-to-route { @extend .badge-warning; }
.status-out-for-delivery { @extend .badge-info; }
.status-delivered { @extend .badge-success; }
.status-cancelled { @extend .badge-danger; }
.status-exception { @extend .badge-danger; }
```

### Navigation Components

```css
/* Bottom Navigation (Mobile) */
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: var(--color-white);
  border-top: 1px solid var(--color-border-light);
  padding: var(--space-2) var(--space-4);
  display: flex;
  justify-content: space-around;
  z-index: 50;
}

.bottom-nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-1);
  padding: var(--space-2);
  text-decoration: none;
  color: var(--color-ink-light);
  font-size: var(--text-xs);
  font-weight: var(--font-medium);
  min-width: 44px; /* Touch target */
  
  &.active {
    color: var(--color-primary);
  }
  
  &:hover {
    color: var(--color-primary);
  }
}

/* Tab Bar (Driver App) */
.tab-bar {
  display: flex;
  background-color: var(--color-white);
  border-bottom: 1px solid var(--color-border-light);
  overflow-x: auto;
}

.tab-item {
  flex: 1;
  padding: var(--space-4);
  text-align: center;
  font-weight: var(--font-medium);
  color: var(--color-ink-light);
  text-decoration: none;
  border-bottom: 3px solid transparent;
  transition: all 0.2s ease-in-out;
  
  &.active {
    color: var(--color-primary);
    border-bottom-color: var(--color-primary);
  }
  
  &:hover {
    color: var(--color-primary);
    background-color: var(--color-surface);
  }
}
```

## Bilingual & RTL Support

### Direction-Aware CSS
```css
/* Direction utilities */
.rtl {
  direction: rtl;
  text-align: right;
}

.ltr {
  direction: ltr;
  text-align: left;
}

/* Logical properties for RTL support */
.padding-inline {
  padding-inline-start: var(--space-4);
  padding-inline-end: var(--space-4);
}

.margin-inline-auto {
  margin-inline: auto;
}

.border-inline-start {
  border-inline-start: 1px solid var(--color-border);
}

/* Icon mirroring for RTL */
.icon-directional {
  &[dir="rtl"] {
    transform: scaleX(-1);
  }
}
```

### Font Loading Strategy
```css
/* Arabic font loading */
@font-face {
  font-family: 'Tajawal';
  src: url('/fonts/tajawal-regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
  unicode-range: U+0600-06FF, U+200C-2010, U+2012-2019, U+2026, U+2003;
}

@font-face {
  font-family: 'Tajawal';
  src: url('/fonts/tajawal-medium.woff2') format('woff2');
  font-weight: 500;
  font-style: normal;
  font-display: swap;
  unicode-range: U+0600-06FF, U+200C-2010, U+2012-2019, U+2026, U+2003;
}

/* English font loading */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}
```

## Accessibility Features

### Focus Management
```css
/* Focus visible for keyboard navigation */
.focus-visible {
  outline: 2px solid var(--color-border-focus);
  outline-offset: 2px;
}

/* Skip link for screen readers */
.skip-link {
  position: absolute;
  top: -40px;
  left: 6px;
  background: var(--color-primary);
  color: var(--color-white);
  padding: 8px;
  text-decoration: none;
  border-radius: var(--radius);
  z-index: 1000;
  
  &:focus {
    top: 6px;
  }
}

/* Screen reader only content */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

### High Contrast Mode
```css
@media (prefers-contrast: high) {
  :root {
    --color-border: #000000;
    --color-ink-light: #000000;
  }
  
  .btn-primary {
    border: 2px solid var(--color-white);
  }
  
  .input {
    border-width: 3px;
  }
}
```

## Specialized Components

### Payment Keypad
```css
.keypad {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--space-3);
  padding: var(--space-4);
  background-color: var(--color-surface);
  border-radius: var(--radius-xl);
}

.keypad-button {
  aspect-ratio: 1;
  border: none;
  border-radius: var(--radius-lg);
  background-color: var(--color-white);
  color: var(--color-ink);
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  box-shadow: var(--shadow-sm);
  min-height: 60px;
  
  &:hover {
    background-color: var(--color-surface-dark);
    transform: translateY(-2px);
    box-shadow: var(--shadow);
  }
  
  &:active {
    transform: translateY(0);
    background-color: var(--color-primary);
    color: var(--color-white);
  }
  
  &.keypad-action {
    background-color: var(--color-primary);
    color: var(--color-white);
    
    &:hover {
      background-color: var(--color-primary-dark);
    }
  }
}
```

### Currency Display
```css
.currency {
  font-family: var(--font-family-mono);
  font-weight: var(--font-semibold);
}

.currency-large {
  font-size: var(--text-2xl);
  color: var(--color-primary);
}

.currency-input {
  text-align: center;
  font-family: var(--font-family-mono);
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
}
```

### Location Card
```css
.location-card {
  @extend .card;
  padding: var(--space-4);
  display: flex;
  align-items: flex-start;
  gap: var(--space-3);
  
  .location-icon {
    flex-shrink: 0;
    width: 24px;
    height: 24px;
    color: var(--color-primary);
  }
  
  .location-content {
    flex: 1;
    
    .location-label {
      font-weight: var(--font-medium);
      color: var(--color-ink);
      margin-bottom: var(--space-1);
    }
    
    .location-address {
      font-size: var(--text-sm);
      color: var(--color-ink-light);
      line-height: var(--leading-relaxed);
    }
  }
  
  .location-action {
    flex-shrink: 0;
  }
}
```

## Animation & Transitions

### Motion Tokens
```css
:root {
  --transition-fast: 0.15s ease-out;
  --transition-base: 0.2s ease-out;
  --transition-slow: 0.3s ease-out;
  
  --easing-ease-out: cubic-bezier(0.25, 0.46, 0.45, 0.94);
  --easing-ease-in-out: cubic-bezier(0.645, 0.045, 0.355, 1);
}
```

### Loading States
```css
.loading {
  position: relative;
  overflow: hidden;
  
  &::after {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.6),
      transparent
    );
    animation: loading-shimmer 1.5s infinite;
  }
}

@keyframes loading-shimmer {
  to {
    left: 100%;
  }
}

.spinner {
  width: 24px;
  height: 24px;
  border: 2px solid var(--color-border);
  border-top-color: var(--color-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
```

### Page Transitions
```css
.page-enter {
  opacity: 0;
  transform: translateY(20px);
}

.page-enter-active {
  opacity: 1;
  transform: translateY(0);
  transition: all var(--transition-base);
}

.page-exit {
  opacity: 1;
  transform: translateY(0);
}

.page-exit-active {
  opacity: 0;
  transform: translateY(-20px);
  transition: all var(--transition-base);
}
```

## Print Styles

```css
@media print {
  /* Hide non-essential elements */
  .no-print,
  .bottom-nav,
  .tab-bar,
  nav,
  .btn {
    display: none !important;
  }
  
  /* Optimize for printing */
  body {
    font-size: 12pt;
    line-height: 1.4;
    color: #000;
    background: #fff;
  }
  
  .card {
    border: 1px solid #000;
    box-shadow: none;
    page-break-inside: avoid;
  }
  
  /* Show URLs for links */
  a[href]:after {
    content: " (" attr(href) ")";
    font-size: 0.8em;
  }
}
```

This design system provides a complete foundation for building consistent, accessible, and beautiful interfaces across all Urban Express applications. The system is designed to be maintainable, scalable, and fully supportive of bilingual requirements.