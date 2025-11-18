# Luxury Real Estate Plugin Enhancements

## Overview
This document outlines specific enhancements to make the Figma Tokens Studio plugin more personalized for luxury real estate websites and more usable for Claude Code integration.

## Current Capabilities Analysis

### Strong Foundation
The plugin already has excellent multi-variant support through:
- **Theme Groups/Dimensions**: Enable multiple simultaneous themes (e.g., brand + color mode + density)
- **Token Set Composition**: Flexible merging with override rules
- **Style References**: Map tokens to multiple Figma style/variable variants
- **CLI Tool**: `token-transformer` for automated token export
- **Storage Providers**: GitHub, GitLab, Azure DevOps integration
- **Programmatic API**: AsyncMessageChannel for automation

---

## Part 1: Luxury Real Estate Customization

### Use Case: Multi-Property Branding
Luxury real estate sites often showcase multiple properties, each with unique branding while maintaining a cohesive parent brand identity.

#### Recommended Theme Structure

```json
{
  "themes": [
    {
      "id": "base-luxury",
      "name": "Base Luxury Brand",
      "group": "brand-foundation",
      "selectedTokenSets": {
        "foundation/typography": "ENABLED",
        "foundation/spacing": "ENABLED",
        "foundation/effects": "ENABLED"
      }
    },
    {
      "id": "property-45parkplace",
      "name": "45 Park Place",
      "group": "property-variant",
      "selectedTokenSets": {
        "properties/45parkplace/colors": "ENABLED",
        "properties/45parkplace/typography-overrides": "ENABLED"
      }
    },
    {
      "id": "property-riverside",
      "name": "Riverside Tower",
      "group": "property-variant",
      "selectedTokenSets": {
        "properties/riverside/colors": "ENABLED",
        "properties/riverside/typography-overrides": "ENABLED"
      }
    },
    {
      "id": "section-hero",
      "name": "Hero Section Style",
      "group": "section-type",
      "selectedTokenSets": {
        "components/hero": "ENABLED"
      }
    },
    {
      "id": "section-gallery",
      "name": "Gallery Section Style",
      "group": "section-type",
      "selectedTokenSets": {
        "components/gallery": "ENABLED"
      }
    }
  ]
}
```

**Active Theme Composition Example**:
```javascript
{
  "brand-foundation": "base-luxury",
  "property-variant": "property-45parkplace",
  "section-type": "section-hero"
}
```

This allows designers to:
- Switch between properties while maintaining brand consistency
- Combine property branding with section-specific styles
- Create consistent yet distinct experiences for each property

### Enhancement 1: Property Preset Templates

**Location**: `packages/tokens-studio-for-figma/src/utils/presets/`

Create luxury real estate preset configurations:

```typescript
// src/utils/presets/luxuryRealEstatePreset.ts
export const luxuryRealEstatePreset = {
  name: "Luxury Real Estate Multi-Property",
  description: "Template for luxury real estate with multiple property variants",
  tokenSets: {
    "foundation/colors": {
      "brand.primary": { value: "#1a1a1a", type: "color" },
      "brand.secondary": { value: "#f5f5f5", type: "color" },
      "brand.accent": { value: "#c9a96e", type: "color" }
    },
    "foundation/typography": {
      "heading.luxury.h1": {
        value: {
          fontFamily: "Playfair Display",
          fontSize: "72px",
          fontWeight: "400",
          lineHeight: "1.2",
          letterSpacing: "-0.02em"
        },
        type: "typography"
      },
      "heading.luxury.h2": {
        value: {
          fontFamily: "Playfair Display",
          fontSize: "48px",
          fontWeight: "400",
          lineHeight: "1.3",
          letterSpacing: "-0.01em"
        },
        type: "typography"
      },
      "body.primary": {
        value: {
          fontFamily: "Montserrat",
          fontSize: "16px",
          fontWeight: "300",
          lineHeight: "1.6",
          letterSpacing: "0.01em"
        },
        type: "typography"
      }
    },
    "foundation/spacing": {
      "section.luxury.vertical": { value: "120px", type: "spacing" },
      "section.luxury.horizontal": { value: "80px", type: "spacing" },
      "content.luxury.gap": { value: "48px", type: "spacing" }
    },
    "foundation/effects": {
      "image.luxury.overlay": {
        value: {
          color: "#000000",
          alpha: 0.2,
          blur: 0
        },
        type: "boxShadow"
      },
      "card.luxury.elevation": {
        value: {
          x: 0,
          y: 8,
          blur: 32,
          spread: 0,
          color: "#00000010"
        },
        type: "boxShadow"
      }
    }
  },
  themes: [
    {
      id: "foundation",
      name: "Foundation",
      group: "base",
      selectedTokenSets: {
        "foundation/colors": "ENABLED",
        "foundation/typography": "ENABLED",
        "foundation/spacing": "ENABLED",
        "foundation/effects": "ENABLED"
      }
    }
  ]
};
```

### Enhancement 2: Quick Property Switcher Component

**Location**: `packages/tokens-studio-for-figma/src/app/components/PropertySwitcher/`

Create a dedicated UI component for rapid property brand switching:

```tsx
// PropertySwitcher.tsx
import React from 'react';
import { useDispatch, useSelector } from 'react-redux';

export const PropertySwitcher = () => {
  const dispatch = useDispatch();
  const themes = useSelector(themesSelector);
  const activeTheme = useSelector(activeThemeSelector);

  // Group themes by property
  const propertyThemes = themes.filter(t => t.group === 'property-variant');

  return (
    <div className="property-switcher">
      <h3>Property Branding</h3>
      <div className="property-grid">
        {propertyThemes.map(theme => (
          <button
            key={theme.id}
            className={activeTheme['property-variant'] === theme.id ? 'active' : ''}
            onClick={() => dispatch.tokenState.setActiveTheme({
              ...activeTheme,
              'property-variant': theme.id
            })}
          >
            <div className="preview-swatch" style={{
              backgroundColor: theme.previewColor || '#ccc'
            }} />
            <span>{theme.name}</span>
          </button>
        ))}
      </div>
    </div>
  );
};
```

### Enhancement 3: Theme Preview Colors

**Location**: `packages/tokens-studio-for-figma/src/types/ThemeObject.ts`

Add preview metadata to themes:

```typescript
export type ThemeObject = {
  id: string;
  name: string;
  group?: string;
  selectedTokenSets: Record<string, TokenSetStatus>;
  $figmaStyleReferences?: ThemeStyleReferences;
  $figmaVariableReferences?: ThemeVariableReferences;
  $figmaCollectionId?: string;
  $figmaModeId?: string;
  // NEW: Preview metadata for quick visual identification
  $metadata?: {
    previewColor?: string;  // Hex color for property brand
    previewImage?: string;  // Base64 thumbnail
    description?: string;   // Property description
    tags?: string[];        // e.g., ["residential", "luxury", "manhattan"]
  };
};
```

### Enhancement 4: Content Type Token Sets

Create specialized token sets for common luxury real estate content types:

```json
{
  "components/hero-fullscreen": {
    "hero.overlay.opacity": { "value": "0.3", "type": "opacity" },
    "hero.title.size": { "value": "{heading.luxury.h1}", "type": "typography" },
    "hero.cta.style": { "value": "outlined-gold", "type": "other" }
  },
  "components/gallery-masonry": {
    "gallery.gap": { "value": "{spacing.xs}", "type": "spacing" },
    "gallery.hover.scale": { "value": "1.05", "type": "other" },
    "gallery.transition": { "value": "0.4s ease", "type": "other" }
  },
  "components/amenities-grid": {
    "amenity.icon.size": { "value": "48px", "type": "sizing" },
    "amenity.card.padding": { "value": "{spacing.lg}", "type": "spacing" },
    "amenity.card.bg": { "value": "{color.surface.elevated}", "type": "color" }
  },
  "components/floor-plans": {
    "floorplan.label.color": { "value": "{color.text.secondary}", "type": "color" },
    "floorplan.dimensions.font": { "value": "{font.mono}", "type": "fontFamily" },
    "floorplan.highlight.color": { "value": "{color.accent}", "type": "color" }
  },
  "components/contact-form-luxury": {
    "form.input.border": { "value": "1px solid {color.border.subtle}", "type": "border" },
    "form.input.padding": { "value": "{spacing.md} {spacing.lg}", "type": "spacing" },
    "form.label.transform": { "value": "uppercase", "type": "textCase" },
    "form.label.tracking": { "value": "0.1em", "type": "letterSpacing" }
  }
}
```

---

## Part 2: Claude Code Integration Enhancements

### Enhancement 5: Enhanced CLAUDE.md Documentation

**Action**: Expand CLAUDE.md with token-specific workflows

```markdown
## Token Transformer CLI Usage

The plugin includes a powerful CLI tool for token automation:

### Basic Export
```bash
# From plugin directory
cd packages/tokens-studio-for-figma
node token-transformer/index.js input.json output.json global,light,dark
```

### Advanced Options
```bash
node token-transformer/index.js \
  tokens.json \
  output/tokens.css \
  foundation,property-45parkplace,section-hero \
  --expandTypography=true \
  --expandShadow=true \
  --resolveReferences=true \
  --theme='{"property-variant": "property-45parkplace"}'
```

### Integration with Build Pipeline
```json
{
  "scripts": {
    "tokens:export": "node token-transformer/index.js tokens.json dist/tokens.json",
    "tokens:export:css": "yarn tokens:export && style-dictionary build",
    "dev": "yarn tokens:export && webpack serve"
  }
}
```

## Programmatic Token Access

### Reading Tokens
```typescript
import { readFileSync } from 'fs';

const tokens = JSON.parse(readFileSync('./tokens.json', 'utf-8'));
const themes = tokens.$themes || [];
const sets = tokens;
```

### Transforming Tokens
```typescript
const { transformTokens } = require('./token-transformer');

const resolved = transformTokens(
  rawTokens,
  ['foundation', 'property-variant'],
  ['deprecated'],
  { expandTypography: true, resolveReferences: true }
);
```

### Generating Code from Tokens
```typescript
// Example: Generate CSS custom properties
function generateCSS(tokens) {
  let css = ':root {\\n';
  for (const [name, token] of Object.entries(tokens)) {
    css += `  --${name}: ${token.value};\\n`;
  }
  css += '}';
  return css;
}
```
```

### Enhancement 6: Token Schema Documentation

**Location**: `packages/tokens-studio-for-figma/docs/`

Create comprehensive schema documentation:

```markdown
# Token Schema Reference

## Token Structure

### Basic Token
```json
{
  "color.primary": {
    "value": "#c9a96e",
    "type": "color",
    "description": "Primary brand color for luxury accents"
  }
}
```

### Alias Token
```json
{
  "button.background": {
    "value": "{color.primary}",
    "type": "color"
  }
}
```

### Typography Token
```json
{
  "heading.hero": {
    "value": {
      "fontFamily": "Playfair Display",
      "fontSize": "72px",
      "fontWeight": "400",
      "lineHeight": "1.2",
      "letterSpacing": "-0.02em"
    },
    "type": "typography"
  }
}
```

### Math Expressions
```json
{
  "spacing.double": {
    "value": "{spacing.base} * 2",
    "type": "spacing"
  }
}
```
```

### Enhancement 7: VSCode Extension Integration Points

**Location**: Create new package `packages/vscode-tokens-studio/`

Outline for a VSCode extension that would help Claude Code:

```typescript
// Extension features:
// 1. Token autocomplete in code
// 2. Token value preview on hover
// 3. Jump to token definition
// 4. Real-time token sync from Figma
// 5. Token validation and linting

export function activate(context: vscode.ExtensionContext) {
  // Token hover provider
  const hoverProvider = vscode.languages.registerHoverProvider(
    ['typescript', 'javascript', 'css'],
    {
      provideHover(document, position, token) {
        const range = document.getWordRangeAtPosition(position, /\{[\w\.]+\}/);
        if (range) {
          const word = document.getText(range);
          const tokenName = word.slice(1, -1);
          const tokenValue = lookupToken(tokenName);
          return new vscode.Hover(
            `**Token**: ${tokenName}\\n**Value**: ${tokenValue}`
          );
        }
      }
    }
  );

  context.subscriptions.push(hoverProvider);
}
```

### Enhancement 8: API Documentation for Automation

**Location**: `packages/tokens-studio-for-figma/docs/API.md`

Create comprehensive API documentation:

```markdown
# Tokens Studio Plugin API

## Async Message Channel

### Sending Messages to Plugin

```typescript
import { AsyncMessageChannel } from '@/AsyncMessageChannel';

// Create styles from tokens
AsyncMessageChannel.PluginInstance.message({
  type: 'CREATE_STYLES',
  payload: {
    tokens: resolvedTokens,
    settings: {
      updateMode: 'CREATE',
      shouldCreate: true
    }
  }
});

// Pull existing styles as tokens
const styles = await AsyncMessageChannel.PluginInstance.message({
  type: 'PULL_STYLES',
  payload: {}
});

// Update theme
AsyncMessageChannel.PluginInstance.message({
  type: 'SET_ACTIVE_THEME',
  payload: {
    activeTheme: {
      'brand-foundation': 'base-luxury',
      'property-variant': 'property-riverside'
    }
  }
});
```

## Node Data Access

### Reading Token Data from Figma Nodes

```typescript
// In Figma plugin context
const node = figma.currentPage.selection[0];
const tokenData = node.getSharedPluginData('tokens', 'values');
const appliedTokens = JSON.parse(tokenData || '{}');

console.log('Applied tokens:', appliedTokens);
// { "fill": "color.primary", "spacing": "spacing.lg" }
```

### Writing Token Data

```typescript
node.setSharedPluginData('tokens', 'fill', 'color.primary');
node.setSharedPluginData('tokens', 'width', 'sizing.container.lg');
```
```

### Enhancement 9: GitHub Actions Workflow Example

**Location**: `.github/workflows/token-export.yml`

Create example automation workflows:

```yaml
name: Export Design Tokens

on:
  push:
    paths:
      - 'tokens.json'
      - 'tokens/**'
  workflow_dispatch:

jobs:
  export-tokens:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install Dependencies
        run: |
          yarn install --frozen-lockfile

      - name: Export Tokens
        run: |
          cd packages/tokens-studio-for-figma
          node token-transformer/index.js \
            ../../tokens.json \
            ../../dist/tokens-resolved.json \
            foundation,property-45parkplace \
            --expandTypography=true \
            --resolveReferences=true

      - name: Generate CSS Variables
        run: |
          node scripts/generate-css-vars.js \
            dist/tokens-resolved.json \
            dist/tokens.css

      - name: Commit Generated Files
        run: |
          git config user.name "Token Bot"
          git config user.email "bot@example.com"
          git add dist/
          git commit -m "Update generated token files" || true
          git push
```

### Enhancement 10: Example Integration Scripts

**Location**: `packages/tokens-studio-for-figma/examples/`

Create practical examples:

```typescript
// examples/generate-property-pages.ts
import { transformTokens } from '../token-transformer';
import fs from 'fs';

const properties = ['45parkplace', 'riverside', 'tribeca'];

properties.forEach(property => {
  // Load base tokens
  const tokens = JSON.parse(fs.readFileSync('tokens.json', 'utf-8'));

  // Transform with property theme
  const resolved = transformTokens(
    tokens,
    ['foundation', `properties/${property}/colors`],
    [],
    { expandTypography: true, resolveReferences: true }
  );

  // Generate CSS
  const css = generateCSSVars(resolved);
  fs.writeFileSync(`dist/${property}-tokens.css`, css);

  // Generate TypeScript types
  const types = generateTypeScript(resolved);
  fs.writeFileSync(`dist/${property}-tokens.d.ts`, types);

  console.log(`✓ Generated tokens for ${property}`);
});

function generateCSSVars(tokens) {
  let css = `:root[data-property="${property}"] {\\n`;
  for (const [name, token] of Object.entries(tokens)) {
    css += `  --${name.replace(/\\./g, '-')}: ${token.$value || token.value};\\n`;
  }
  css += '}\\n';
  return css;
}
```

---

## Implementation Priority

### Phase 1: Documentation & Examples (Immediate)
1. ✅ Enhance CLAUDE.md with CLI and automation examples
2. ✅ Create luxury real estate preset templates
3. ✅ Add API documentation
4. ✅ Create GitHub Actions workflow examples

### Phase 2: UI Enhancements (Short-term)
1. Property Switcher component
2. Theme preview metadata
3. Preset template selector in UI

### Phase 3: Tooling & Integration (Medium-term)
1. VSCode extension for token autocomplete
2. Improved CLI with property-specific exports
3. Token validation tools

### Phase 4: Advanced Features (Long-term)
1. AI-assisted token generation for new properties
2. Automated property branding from photos
3. Design system consistency checker

---

## Quick Start for Luxury Real Estate

### 1. Set Up Token Structure

```bash
mkdir -p tokens/foundation tokens/properties
```

Create `tokens/foundation/colors.json`:
```json
{
  "brand": {
    "primary": { "value": "#1a1a1a", "type": "color" },
    "accent": { "value": "#c9a96e", "type": "color" }
  }
}
```

Create `tokens/properties/45parkplace/colors.json`:
```json
{
  "property": {
    "hero": { "value": "#2c3e50", "type": "color" },
    "accent": { "value": "#c9a96e", "type": "color" }
  }
}
```

### 2. Define Themes

In `tokens.json`:
```json
{
  "$themes": [
    {
      "id": "45parkplace",
      "name": "45 Park Place",
      "group": "property",
      "selectedTokenSets": {
        "foundation/colors": "ENABLED",
        "properties/45parkplace/colors": "ENABLED"
      }
    }
  ]
}
```

### 3. Export for Web

```bash
node token-transformer/index.js tokens.json dist/45parkplace.json foundation,properties/45parkplace
```

### 4. Use in Code

```css
/* Generated CSS */
:root {
  --brand-primary: #1a1a1a;
  --property-hero: #2c3e50;
}

.hero {
  background: var(--property-hero);
  color: var(--brand-primary);
}
```

---

## Benefits Summary

### For Luxury Real Estate Designers
- ✅ Quickly switch between property brands
- ✅ Maintain consistency across properties
- ✅ Reuse foundation while customizing per-property
- ✅ Visual preview of property themes
- ✅ Pre-built luxury design patterns

### For Claude Code Integration
- ✅ CLI tool for automated token export
- ✅ Clear API documentation for programmatic access
- ✅ Example scripts and workflows
- ✅ GitHub Actions integration
- ✅ Token schema documentation for code generation
- ✅ VSCode extension for better DX

### For Development Teams
- ✅ Automated token sync to codebase
- ✅ Type-safe token usage
- ✅ CI/CD integration ready
- ✅ Multi-brand support out of box
- ✅ Consistent design-to-code workflow
