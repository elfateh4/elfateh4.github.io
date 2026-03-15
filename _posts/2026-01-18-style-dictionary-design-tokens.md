---
title: Building a Scalable Design Token System with Style Dictionary
date: 2026-01-18
layout: post
tags: [design-tokens, style-dictionary, css, frontend, design-system]
lang: en
base_slug: style-dictionary-design-tokens
---

# Building a Scalable Design Token System with Style Dictionary

Design tokens are the atomic building blocks of a design system. They're the single source of truth for colors, typography, spacing, and other design decisions. In this post, I'll share how I built a robust token architecture using Style Dictionary that supports seamless dark mode switching.

## What Are Design Tokens?

Design tokens are named entities that store visual design attributes. Instead of hardcoding values like `#13ADE3` throughout your codebase, you define it once as a token:

```
{
  "global": {
    "primary": {
      "500": { "value": "#13ADE3" }
    }
  }
}
```

This becomes a CSS custom property: `--global-primary-500: #13ADE3;`

## The Three-Tier Token Architecture

I structured my tokens into three tiers:

### 1. Global Tokens (Raw Values)
These are your palette - the raw color values, base font sizes, and spacing units:

```
{
  "global": {
    "primary": {
      "main": { "value": "#13ADE3" },
      "100": { "value": "#C0ECF8" },
      "500": { "value": "#13ADE3" },
      "900": { "value": "#043649" }
    }
  }
}
```

### 2. Semantic Tokens (Contextual Meaning)
These give meaning to the raw values. Instead of "primary-500", you have "brand-primary":

```
{
  "brand": {
    "primary": { "value": "var(--global-primary-main)" },
    "primary-light": { "value": "var(--global-primary-100)" },
    "primary-dark": { "value": "var(--global-primary-600)" }
  }
}
```

### 3. Component Tokens (Specific Usage)
These are tokens for specific UI components:

```
{
  "button": {
    "bg": { "value": "var(--brand-primary)" },
    "text": { "value": "var(--text-color-on-primary)" }
  }
}
```

## Dark Mode: The Key Insight

Here's where it gets interesting. For dark mode, **semantic tokens change, but component code doesn't**.

Light mode (`general.json`):
```
{
  "brand": {
    "primary": { "value": "var(--global-primary-main)" },
    "primary-light": { "value": "var(--global-primary-100)" }
  }
}
```

Dark mode (`general.dark.json`):
```
{
  "brand": {
    "primary": { "value": "var(--global-primary-400)" },
    "primary-light": { "value": "var(--global-primary-900)" }
  }
}
```

Notice how \`--brand-primary\` maps to lighter variants in dark mode for better contrast.

## Style Dictionary Configuration

Here's my ESM configuration that builds both light and dark tokens:

```javascript
import StyleDictionary from 'style-dictionary';

// Custom format for dark mode CSS
StyleDictionary.registerFormat({
  name: 'css/variables-dark',
  format: function({ dictionary }) {
    return `[data-theme="dark"] {
${dictionary.allTokens.map(token => 
  `  --${token.name}: ${token.value};`
).join('\n')}
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
${dictionary.allTokens.map(token => 
  `    --${token.name}: ${token.value};`
).join('\n')}
  }
}`;
  }
});

// Light mode build
const lightSD = new StyleDictionary({
  source: [
    'tokens/global/**/*.json',
    'tokens/semantic/**/!(*dark).json',
  ],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'src/styles/',
      files: [{
        destination: 'tokens.css',
        format: 'css/variables',
      }]
    }
  }
});

// Dark mode build
const darkSD = new StyleDictionary({
  source: [
    'tokens/global/**/*.json',
    'tokens/semantic/**/*.dark.json',
  ],
  platforms: {
    cssDark: {
      buildPath: 'src/styles/',
      files: [{
        destination: 'tokens-dark.css',
        format: 'css/variables-dark',
      }]
    }
  }
});

await lightSD.buildAllPlatforms();
await darkSD.buildAllPlatforms();
```

## The Golden Rule: Never Use Global Tokens Directly

In your components, always use semantic tokens:

```css
/* ❌ Bad - hardcoded to light mode */
.button {
  background: var(--global-primary-main);
}

/* ✅ Good - adapts to theme automatically */
.button {
  background: var(--brand-primary);
}
```

## Token Categories I Use

| Category | Purpose | Examples |
|----------|---------|----------|
| `--brand-*` | Brand colors | primary, secondary, accent |
| `--status-*` | Feedback states | success, warning, error, info |
| `--neutral-*` | Gray scale | 100-600 shades |
| `--surface-*` | Backgrounds | bg-primary, bg-card, border |
| `--text-*` | Typography | heading, body, muted, link |
| `--interactive-*` | UI elements | hover, focus, disabled states |

## Real-World Impact

After migrating 50+ components to semantic tokens:

1. **Dark mode just works** - Toggle \`data-theme="dark"\` and everything adapts
2. **Consistency** - No more magic color values scattered in CSS
3. **Maintainability** - Change a color in one place, update everywhere
4. **Developer experience** - Clear naming makes code self-documenting

## Getting Started

1. Install Style Dictionary: \`npm install style-dictionary\`
2. Create your token JSON files in a \`tokens/\` directory
3. Configure Style Dictionary to build CSS custom properties
4. Import the generated CSS in your app
5. Use semantic tokens in all your components

## Conclusion

Design tokens are a game-changer for maintaining consistent UI at scale. Style Dictionary provides the tooling to transform token definitions into platform-specific outputs. The three-tier architecture (global → semantic → component) gives you flexibility while maintaining a clear contract between design and code.

The key insight is that **semantic tokens are the interface your components should depend on**. Raw values (global tokens) and theme variations (dark mode) become implementation details that can change without touching component code.

Start small, but start with the right architecture. Your future self will thank you.