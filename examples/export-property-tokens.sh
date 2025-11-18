#!/bin/bash

# Export Property Tokens Script
# This script exports design tokens for each luxury real estate property
# Usage: ./export-property-tokens.sh [property-name]
# If no property name is provided, all properties are exported

set -e

# Configuration
TOKENS_DIR="examples"
INPUT_FILE="$TOKENS_DIR/luxury-real-estate-tokens.json"
OUTPUT_DIR="dist/tokens"
TRANSFORMER="packages/tokens-studio-for-figma/token-transformer/index.js"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to export tokens for a specific property
export_property() {
  local property_name=$1
  local property_id=$2
  local token_sets=$3

  echo -e "${BLUE}Exporting tokens for: ${property_name}${NC}"

  # Export JSON with resolved references
  echo "  → Generating resolved JSON..."
  node "$TRANSFORMER" \
    "$INPUT_FILE" \
    "$OUTPUT_DIR/${property_id}-tokens.json" \
    "$token_sets" \
    --expandTypography=true \
    --expandShadow=true \
    --resolveReferences=true \
    --preserveRawValue=false

  echo -e "${GREEN}  ✓ Exported: $OUTPUT_DIR/${property_id}-tokens.json${NC}"

  # Generate CSS custom properties
  echo "  → Generating CSS variables..."
  node -e "
    const fs = require('fs');
    const tokens = JSON.parse(fs.readFileSync('$OUTPUT_DIR/${property_id}-tokens.json', 'utf-8'));

    let css = '/* ${property_name} Design Tokens */\n';
    css += ':root[data-property=\"${property_id}\"] {\n';

    function flattenTokens(obj, prefix = '') {
      for (const [key, value] of Object.entries(obj)) {
        const path = prefix ? \`\${prefix}-\${key}\` : key;
        if (value && typeof value === 'object' && !Array.isArray(value)) {
          if (value.value !== undefined) {
            css += \`  --\${path}: \${value.value};\n\`;
          } else {
            flattenTokens(value, path);
          }
        }
      }
    }

    flattenTokens(tokens);
    css += '}\n';

    fs.writeFileSync('$OUTPUT_DIR/${property_id}-tokens.css', css);
  "

  echo -e "${GREEN}  ✓ Exported: $OUTPUT_DIR/${property_id}-tokens.css${NC}"

  # Generate TypeScript types
  echo "  → Generating TypeScript types..."
  node -e "
    const fs = require('fs');
    const tokens = JSON.parse(fs.readFileSync('$OUTPUT_DIR/${property_id}-tokens.json', 'utf-8'));

    let types = '/* ${property_name} Design Token Types */\n\n';
    types += 'export const ${property_id}Tokens = {\n';

    function generateTypes(obj, indent = 1) {
      const spacing = '  '.repeat(indent);
      for (const [key, value] of Object.entries(obj)) {
        if (value && typeof value === 'object' && !Array.isArray(value)) {
          if (value.value !== undefined) {
            const tokenValue = typeof value.value === 'string'
              ? \`'\${value.value}'\`
              : JSON.stringify(value.value);
            types += \`\${spacing}'\${key}': \${tokenValue},\n\`;
          } else {
            types += \`\${spacing}'\${key}': {\n\`;
            generateTypes(value, indent + 1);
            types += \`\${spacing}},\n\`;
          }
        }
      }
    }

    generateTypes(tokens);
    types += '} as const;\n\n';
    types += 'export type ${property_id}TokenKeys = keyof typeof ${property_id}Tokens;\n';

    fs.writeFileSync('$OUTPUT_DIR/${property_id}-tokens.ts', types);
  "

  echo -e "${GREEN}  ✓ Exported: $OUTPUT_DIR/${property_id}-tokens.ts${NC}"
  echo ""
}

# Export specific property or all properties
if [ -z "$1" ]; then
  echo -e "${YELLOW}Exporting tokens for all properties...${NC}\n"

  # 45 Park Place
  export_property \
    "45 Park Place" \
    "45parkplace" \
    "foundation.colors,foundation.typography,foundation.spacing,foundation.effects,semantic.hero,semantic.gallery,semantic.amenity-card,properties.45parkplace"

  # Riverside Tower
  export_property \
    "Riverside Tower" \
    "riverside-tower" \
    "foundation.colors,foundation.typography,foundation.spacing,foundation.effects,semantic.hero,semantic.gallery,semantic.amenity-card,properties.riverside-tower"

  # Tribeca Loft
  export_property \
    "Tribeca Loft" \
    "tribeca-loft" \
    "foundation.colors,foundation.typography,foundation.spacing,foundation.effects,semantic.hero,semantic.gallery,semantic.amenity-card,properties.tribeca-loft"

  echo -e "${GREEN}✓ All property tokens exported successfully!${NC}"
else
  case "$1" in
    "45parkplace"|"45-park-place")
      export_property \
        "45 Park Place" \
        "45parkplace" \
        "foundation.colors,foundation.typography,foundation.spacing,foundation.effects,semantic.hero,semantic.gallery,semantic.amenity-card,properties.45parkplace"
      ;;
    "riverside"|"riverside-tower")
      export_property \
        "Riverside Tower" \
        "riverside-tower" \
        "foundation.colors,foundation.typography,foundation.spacing,foundation.effects,semantic.hero,semantic.gallery,semantic.amenity-card,properties.riverside-tower"
      ;;
    "tribeca"|"tribeca-loft")
      export_property \
        "Tribeca Loft" \
        "tribeca-loft" \
        "foundation.colors,foundation.typography,foundation.spacing,foundation.effects,semantic.hero,semantic.gallery,semantic.amenity-card,properties.tribeca-loft"
      ;;
    *)
      echo -e "${YELLOW}Unknown property: $1${NC}"
      echo "Available properties: 45parkplace, riverside-tower, tribeca-loft"
      exit 1
      ;;
  esac
fi

# Generate index file
echo -e "${BLUE}Generating index files...${NC}"
cat > "$OUTPUT_DIR/index.css" << 'EOF'
/* Luxury Real Estate Design Tokens */
/* Import all property stylesheets */

@import './45parkplace-tokens.css';
@import './riverside-tower-tokens.css';
@import './tribeca-loft-tokens.css';

/* Default to first property */
:root {
  --current-property: '45parkplace';
}
EOF

cat > "$OUTPUT_DIR/index.ts" << 'EOF'
/* Luxury Real Estate Design Tokens */
/* Export all property tokens */

export * from './45parkplace-tokens';
export * from './riverside-tower-tokens';
export * from './tribeca-loft-tokens';
EOF

echo -e "${GREEN}✓ Index files generated${NC}\n"

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Export complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Output location: $OUTPUT_DIR/"
echo ""
echo "Generated files:"
echo "  • JSON: *-tokens.json (resolved token values)"
echo "  • CSS:  *-tokens.css (CSS custom properties)"
echo "  • TS:   *-tokens.ts (TypeScript constants)"
echo ""
echo "Usage in your code:"
echo ""
echo "  CSS:"
echo "    <html data-property=\"45parkplace\">"
echo "    .hero { background: var(--properties-45parkplace-hero-background); }"
echo ""
echo "  TypeScript:"
echo "    import { parkplaceTokens } from './dist/tokens/45parkplace-tokens';"
echo "    const heroColor = parkplaceTokens.properties['45parkplace']['hero-background'];"
echo ""
