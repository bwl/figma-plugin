# Luxury Real Estate Examples

This directory contains practical examples for using Figma Tokens Studio with luxury real estate websites.

## Files

### `luxury-real-estate-tokens.json`
Complete token configuration demonstrating:
- **Foundation tokens**: Colors, typography, spacing, effects
- **Semantic tokens**: Hero sections, galleries, amenity cards, floor plans, contact forms
- **Property-specific tokens**: Three example properties with unique branding
  - 45 Park Place (gold/black theme)
  - Riverside Tower (blue/water theme)
  - Tribeca Loft (metallic gold/industrial theme)
- **Theme configuration**: Multi-dimensional theme structure

### `export-property-tokens.sh`
Automated export script that:
- Exports tokens for each property
- Generates JSON, CSS, and TypeScript files
- Resolves token references and math expressions
- Creates ready-to-use code artifacts

## Quick Start

### 1. Import Tokens into Figma

1. Open Figma Tokens Studio plugin
2. Click "Load from file"
3. Select `luxury-real-estate-tokens.json`
4. Your tokens and themes will be imported

### 2. Switch Between Properties

In the plugin UI:
1. Go to Themes tab
2. Under "property" group, select:
   - "45 Park Place" for gold accent theme
   - "Riverside Tower" for blue water theme
   - "Tribeca Loft" for metallic gold theme
3. Click "Apply" to update your designs

### 3. Export Tokens for Development

```bash
# Export all properties
./examples/export-property-tokens.sh

# Export specific property
./examples/export-property-tokens.sh 45parkplace
./examples/export-property-tokens.sh riverside-tower
./examples/export-property-tokens.sh tribeca-loft
```

Output files are generated in `dist/tokens/`:
- `{property}-tokens.json` - Resolved token values
- `{property}-tokens.css` - CSS custom properties
- `{property}-tokens.ts` - TypeScript constants

### 4. Use in Your Website

#### CSS Approach
```html
<html data-property="45parkplace">
<head>
  <link rel="stylesheet" href="dist/tokens/45parkplace-tokens.css">
</head>
<body>
  <section class="hero">
    <h1>Welcome to 45 Park Place</h1>
  </section>
</body>
</html>
```

```css
.hero {
  background: var(--properties-45parkplace-hero-background);
  color: var(--foundation-colors-brand-secondary);
  padding: var(--semantic-hero-padding-vertical) var(--foundation-spacing-xl);
}

.hero h1 {
  font-family: var(--foundation-typography-font-families-display);
  font-size: var(--foundation-typography-font-sizes-5xl);
  letter-spacing: var(--foundation-typography-letter-spacing-tighter);
}
```

#### TypeScript Approach
```typescript
import { parkplaceTokens } from './dist/tokens/45parkplace-tokens';

const theme = {
  hero: {
    background: parkplaceTokens.properties['45parkplace']['hero-background'],
    accent: parkplaceTokens.properties['45parkplace'].accent,
  }
};
```

## Token Structure Explanation

### Foundation Layer
Base design system tokens shared across all properties:
- Colors (brand palette, neutral scale)
- Typography (font families, sizes, line heights, letter spacing)
- Spacing scale
- Effects (shadows, overlays)

### Semantic Layer
Component-specific tokens that reference foundation tokens:
- Hero sections
- Image galleries
- Amenity cards
- Floor plan displays
- Contact forms

### Property Layer
Property-specific overrides and additions:
- Unique color schemes per property
- Property-specific hero backgrounds
- Brand accent colors

### Theme Configuration
Themes combine token sets in different ways:
- `base` group: Foundation + Semantic tokens
- `property` group: Foundation + Semantic + Property-specific tokens

## Multi-Property Workflow

### For Designers
1. Design common components using **foundation** tokens
2. Create property-specific variants using **property themes**
3. Switch themes to preview different properties
4. Export components with applied tokens

### For Developers
1. Run export script to generate code artifacts
2. Import appropriate token file for each property
3. Use CSS custom properties or TypeScript constants
4. Dynamically switch properties with `data-property` attribute

## Advanced Usage

### Adding a New Property

1. **Add property tokens** in `luxury-real-estate-tokens.json`:
```json
{
  "properties": {
    "your-property-name": {
      "hero-background": { "value": "#your-color", "type": "color" },
      "accent": { "value": "#your-accent", "type": "color" }
    }
  }
}
```

2. **Create a theme**:
```json
{
  "$themes": [
    {
      "id": "your-property-name",
      "name": "Your Property Name",
      "group": "property",
      "selectedTokenSets": {
        "foundation.colors": "ENABLED",
        "foundation.typography": "ENABLED",
        "semantic.hero": "ENABLED",
        "properties.your-property-name": "ENABLED"
      },
      "$metadata": {
        "previewColor": "#your-accent",
        "description": "Your property description"
      }
    }
  ]
}
```

3. **Update export script** to include your property

### Customizing Components

Add new semantic tokens for custom components:

```json
{
  "semantic": {
    "virtual-tour": {
      "button-bg": { "value": "{foundation.colors.brand.accent}", "type": "color" },
      "button-text": { "value": "{foundation.colors.brand.primary}", "type": "color" },
      "padding": { "value": "{foundation.spacing.xl}", "type": "spacing" }
    }
  }
}
```

## Integration with Build Tools

### webpack
```javascript
// webpack.config.js
const tokens = require('./dist/tokens/45parkplace-tokens.json');

module.exports = {
  plugins: [
    new webpack.DefinePlugin({
      DESIGN_TOKENS: JSON.stringify(tokens)
    })
  ]
};
```

### Next.js
```typescript
// _app.tsx
import '../dist/tokens/index.css';

export default function App({ Component, pageProps, router }) {
  const property = router.query.property || '45parkplace';

  return (
    <div data-property={property}>
      <Component {...pageProps} />
    </div>
  );
}
```

### Style Dictionary
```javascript
// style-dictionary.config.js
const StyleDictionary = require('style-dictionary');

StyleDictionary.registerTransform({
  name: 'size/rem',
  type: 'value',
  matcher: (token) => token.type === 'spacing',
  transformer: (token) => {
    return `${parseFloat(token.value) / 16}rem`;
  }
});

module.exports = {
  source: ['dist/tokens/45parkplace-tokens.json'],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'build/css/',
      files: [{
        destination: 'variables.css',
        format: 'css/variables'
      }]
    }
  }
};
```

## Resources

- [Figma Tokens Studio Documentation](https://docs.tokens.studio/)
- [Design Tokens Community Group](https://www.designtokens.org/)
- [Token Transformer CLI](../packages/tokens-studio-for-figma/token-transformer/)
- [Main Documentation](../LUXURY_REAL_ESTATE_ENHANCEMENTS.md)

## Support

For questions or issues:
1. Check the main [LUXURY_REAL_ESTATE_ENHANCEMENTS.md](../LUXURY_REAL_ESTATE_ENHANCEMENTS.md) guide
2. Review the enhanced [CLAUDE.md](../CLAUDE.md) for CLI usage
3. Consult [developer-knowledgebase/](../developer-knowledgebase/) for architecture details
