# Amplifier Bootstrap

Bootstrap script for setting up [Amplifier](https://github.com/microsoft/amplifier) with my preferred bundles and providers on a fresh machine.

## Quick Start

```bash
curl -sSL https://raw.githubusercontent.com/colombod/amplifier-bootstrap/main/bootstrap-amplifier.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/colombod/amplifier-bootstrap.git
cd amplifier-bootstrap
./bootstrap-amplifier.sh
```

## What It Does

1. **Checks/installs uv** - The script verifies that [uv](https://astral.sh/uv) (from astral-sh) is installed. If not, it installs it automatically.

2. **Installs Amplifier** - Installs the Amplifier CLI via uv.

3. **Installs providers**:
   - `anthropic` - Claude models
   - `gemini` - Google Gemini models  
   - `azure-openai` - Azure OpenAI models

4. **Adds bundles**:
   - `design-intelligence-enhanced` - Enhanced design intelligence
   - `discovery` - Discovery capabilities
   - `m365` - Microsoft 365 integration
   - `made-support` - MADE support bundle
   - `pr-review` - PR review capabilities
   - `stories` - Story generation
   - `tui-tester` - TUI testing utilities

5. **Adds app bundles** (always composed):
   - `deepwiki` - DeepWiki integration for understanding open-source projects
   - `perplexity` - Perplexity research integration

## Required Environment Variables

After running the bootstrap, you need to set up your API keys. Create `~/.amplifier/keys.env`:

```env
ANTHROPIC_API_KEY=your-anthropic-key
ANTHROPIC_BASE_URL=https://api.anthropic.com  # optional, for proxies
GOOGLE_API_KEY=your-google-api-key
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
AZURE_OPENAI_API_VERSION=2024-02-15-preview
```

## Usage

After bootstrap completes:

```bash
# Start an Amplifier session
amplifier run

# Use a specific bundle
amplifier run --bundle pr-review

# List available bundles
amplifier bundle list
```

## Customization

Edit `bootstrap-amplifier.sh` to add or remove bundles/providers as needed.

## License

MIT
