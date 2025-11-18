# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This is a monorepo using Turbo and Yarn workspaces. The main Figma plugin is in `packages/tokens-studio-for-figma/`.

### Common Commands
- `yarn --frozen-lockfile --immutable` - Install dependencies
- `yarn build` - Build all packages 
- `yarn start` - Start development mode (runs webpack in watch mode)
- `yarn lint` - Run ESLint across all packages
- `yarn test` - Run Jest tests across all packages
- `yarn test:watch` - Run tests in watch mode

### Plugin-Specific Commands (run from `packages/tokens-studio-for-figma/`)
- `yarn build` - Production build with webpack
- `yarn build:dev` - Development build
- `yarn start` - Start webpack in development watch mode
- `yarn test` - Run Jest tests with feature flags enabled
- `yarn test:watch` - Run tests in watch mode without coverage
- `yarn test:coverage` - Run tests with coverage reporting
- `yarn cy:open` - Open Cypress for E2E testing
- `yarn cy:run` - Run Cypress tests headlessly
- `yarn lint` - Run ESLint with auto-fix
- `yarn lint:nofix` - Run ESLint without auto-fix
- `yarn storybook` - Start Storybook for component development

### Testing
- Jest configuration is in `packages/tokens-studio-for-figma/jest.config.ts`
- Test files follow `.test.ts` or `.test.tsx` naming
- E2E tests use Cypress and are in `packages/tokens-studio-for-figma/cypress/`
- Feature flags are enabled during testing via `LAUNCHDARKLY_FLAGS` environment variable

## Architecture Overview

### Monorepo Structure
- Root-level package.json manages the monorepo with Turbo
- `packages/tokens-studio-for-figma/` contains the main Figma plugin
- Developer documentation is in `developer-knowledgebase/`

### Plugin Architecture
The Figma plugin follows a dual-thread architecture:

1. **Main Thread (Plugin Controller)**: `src/plugin/controller.ts`
   - Handles Figma API interactions
   - Manages async message handlers
   - Controls plugin lifecycle

2. **UI Thread (React App)**: `src/app/index.tsx`
   - React application using Redux for state management
   - Uses Stitches for CSS-in-JS styling
   - Rematch for Redux store configuration

### Key Directories
- `src/plugin/` - Plugin-side code that runs in Figma's plugin environment
- `src/app/` - UI React application code
- `src/storage/` - Token storage providers (GitHub, GitLab, Azure DevOps, etc.)
- `src/selectors/` - Redux selectors for state management
- `src/utils/` - Shared utility functions
- `src/types/` - TypeScript type definitions
- `src/constants/` - Application constants and enums
- `src/figmaStorage/` - Figma plugin data storage management

### Communication Pattern
The plugin uses an AsyncMessageChannel pattern for communication between the main plugin thread and UI thread. Message handlers are defined in `src/plugin/controller.ts` and types in `src/types/AsyncMessages.ts`.

### State Management
- Uses Redux with Rematch for state management
- Store configuration in `src/app/store.ts` 
- Selectors are organized by domain in `src/selectors/`
- State is persisted to Figma's plugin storage via `src/figmaStorage/`

### Token Processing
- Token resolution handled by `src/utils/TokenResolver.ts`
- Support for multiple token formats and transformations
- Variable creation and management for Figma Variables API

### Storage Providers
Multiple storage providers are supported for token synchronization:
- GitHub (`src/storage/GithubTokenStorage.ts`)
- GitLab (`src/storage/GitlabTokenStorage.ts`)
- Azure DevOps (`src/storage/ADOTokenStorage.ts`)
- JSONBin (`src/storage/JSONBinTokenStorage.ts`)
- Local file storage and more

### Build System
- Webpack configuration in root and plugin-specific configs
- Supports development, production, and preview builds
- Bundle analysis and benchmarking tools available
- Uses SWC for fast TypeScript compilation

## Code Standards

### Formatting and Linting
- **Always run formatting tools** after making code changes:
  - `yarn lint` - Run ESLint with auto-fix across all packages
  - `npx prettier --write <file>` - Format specific files
  - `npx eslint <file> --fix` - Fix ESLint issues in specific files
- **Code style**: Follow existing patterns with 2-space indentation, single quotes, trailing commas
- **Console statements**: console.log is acceptable for debugging (widely used in codebase)
- **Before committing**: Ensure code passes linting checks

### Best Practices
- Follow existing component and utility patterns
- Use TypeScript types consistently
- Implement proper error handling with try/catch blocks
- Use async/await patterns with `defaultWorker.schedule()` for operations that need progress tracking

## Token Transformer CLI

The plugin includes a powerful CLI tool for automated token export and transformation, located at `packages/tokens-studio-for-figma/token-transformer/`.

### Installation
```bash
# Global installation
npm install token-transformer -g

# Or use directly from monorepo
cd packages/tokens-studio-for-figma
node token-transformer/index.js [options]
```

### Basic Usage
```bash
# Export tokens with specific token sets
node token-transformer/index.js input.json output.json global,light,dark

# With expansion options
node token-transformer/index.js input.json output.json global,light \
  --expandTypography=true \
  --expandShadow=true \
  --resolveReferences=true \
  --preserveRawValue=false
```

### Options
- `--expandTypography` - Expand typography composite tokens into individual properties
- `--expandShadow` - Expand shadow tokens
- `--expandBorder` - Expand border tokens
- `--expandComposition` - Expand composition tokens
- `--preserveRawValue` - Keep original unresolved token values
- `--resolveReferences` - Resolve token aliases and math expressions (true/false/'math')
- `--throwErrorWhenNotResolved` - Throw error on unresolved references
- `--theme` - Apply theme configuration for output
- `--themeOutputPath` - Output directory for theme-based files

### Programmatic Usage
```typescript
const { transformTokens } = require('token-transformer');

const resolved = transformTokens(
  rawTokens,
  ['foundation', 'light', 'components'],
  ['deprecated'],
  {
    expandTypography: true,
    resolveReferences: true
  }
);
```

### NPM Scripts Integration
```json
{
  "scripts": {
    "tokens:export": "node token-transformer/index.js tokens.json dist/tokens.json foundation,light",
    "tokens:build": "yarn tokens:export && style-dictionary build",
    "dev": "concurrently \"yarn tokens:export --watch\" \"webpack serve\""
  }
}
```

## AsyncMessageChannel API

The plugin uses an AsyncMessageChannel pattern for communication between threads. This can be used for programmatic control.

### Key Message Types
- `CREATE_STYLES` - Generate Figma styles from tokens
- `CREATE_LOCAL_VARIABLES` - Create Figma variables from tokens
- `PULL_STYLES` - Extract existing styles as tokens
- `PULL_VARIABLES` - Extract existing variables as tokens
- `SET_ACTIVE_THEME` - Change active theme configuration
- `UPDATE` - Update token values in the document
- `SET_NODE_DATA` - Apply tokens to Figma nodes

### Example Usage
```typescript
import { AsyncMessageChannel } from '@/AsyncMessageChannel';

// Create styles from tokens
await AsyncMessageChannel.PluginInstance.message({
  type: 'CREATE_STYLES',
  payload: {
    tokens: resolvedTokens,
    settings: { updateMode: 'CREATE', shouldCreate: true }
  }
});

// Switch active theme
await AsyncMessageChannel.PluginInstance.message({
  type: 'SET_ACTIVE_THEME',
  payload: {
    activeTheme: {
      'brand': 'luxury-base',
      'property': 'property-45parkplace'
    }
  }
});
```

## Token File Format

### Standard Token Structure
```json
{
  "color.primary": {
    "value": "#c9a96e",
    "type": "color",
    "description": "Primary brand color"
  },
  "spacing.base": {
    "value": "8px",
    "type": "spacing"
  },
  "typography.heading": {
    "value": {
      "fontFamily": "Playfair Display",
      "fontSize": "48px",
      "fontWeight": "400",
      "lineHeight": "1.2"
    },
    "type": "typography"
  }
}
```

### Theme Configuration
```json
{
  "$themes": [
    {
      "id": "light",
      "name": "Light Theme",
      "group": "mode",
      "selectedTokenSets": {
        "foundation": "ENABLED",
        "semantic/light": "ENABLED",
        "components": "SOURCE"
      }
    }
  ]
}
```

### Token Set Status Values
- `ENABLED` - Active and affects style/variable creation
- `SOURCE` - Used for resolving references only, not exported
- `DISABLED` - Completely inactive

### Supported Token Types
- `color` - Color values (hex, rgb, rgba, hsl)
- `typography` - Font family, size, weight, line height, letter spacing
- `spacing` - Spacing and sizing values
- `borderRadius` - Border radius values
- `borderWidth` - Border width values
- `boxShadow` - Shadow effects
- `opacity` - Opacity values
- `sizing` - Width, height dimensions
- `other` - Custom token types

## CI/CD Integration Examples

### GitHub Actions Workflow
```yaml
name: Export Design Tokens

on:
  push:
    paths:
      - 'tokens.json'
      - 'tokens/**'

jobs:
  export:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: yarn install --frozen-lockfile

      - name: Export tokens
        run: |
          cd packages/tokens-studio-for-figma
          node token-transformer/index.js \
            ../../tokens.json \
            ../../dist/tokens.json \
            foundation,light,components \
            --expandTypography=true \
            --resolveReferences=true

      - name: Commit changes
        run: |
          git config user.name "Token Bot"
          git add dist/
          git commit -m "Update exported tokens" || true
          git push
```

## Storage Provider Integration

The plugin supports multiple remote storage providers for token synchronization:
- **GitHub** - `src/storage/GithubTokenStorage.ts`
- **GitLab** - `src/storage/GitlabTokenStorage.ts`
- **Azure DevOps** - `src/storage/ADOTokenStorage.ts`
- **Bitbucket** - `src/storage/BitbucketTokenStorage.ts`
- **JSONBin** - `src/storage/JSONBinTokenStorage.ts`
- **Tokens Studio Cloud** - `src/storage/TokensStudioTokenStorage.ts`
- **URL-based** - `src/storage/UrlTokenStorage.ts`

These enable automated sync workflows between Figma and your codebase.

## Important Notes

- The plugin requires specific Figma API permissions defined in `manifest.json`
- Feature flags are managed via LaunchDarkly integration
- Internationalization support with i18next
- Comprehensive test coverage with both unit and E2E tests
- Uses Figma Plugin DS for consistent UI components
- Token data is stored in Figma's shared plugin data (accessible via Figma API)
- Supports both legacy and DTCG (Design Tokens Community Group) token formats