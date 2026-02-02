#!/bin/bash
#
# Amplifier Bootstrap Script
# ===========================
# Sets up Amplifier with all bundles and providers on a fresh machine.
#
# Prerequisites: curl, git
# This script will install: uv, amplifier, providers, and bundles
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# -----------------------------------------------------------------------------
# Step 1: Check and install uv (astral-sh)
# -----------------------------------------------------------------------------
print_header "Checking for uv (astral-sh)"

if command -v uv &> /dev/null; then
    UV_VERSION=$(uv --version 2>/dev/null || echo "unknown")
    print_success "uv is already installed: $UV_VERSION"
else
    print_warning "uv not found. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Source the env to get uv in PATH for this session
    if [ -f "$HOME/.local/bin/env" ]; then
        source "$HOME/.local/bin/env"
    elif [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
    
    # Add to PATH if not already there
    export PATH="$HOME/.local/bin:$PATH"
    
    if command -v uv &> /dev/null; then
        print_success "uv installed successfully: $(uv --version)"
    else
        print_error "Failed to install uv. Please install manually from https://astral.sh/uv"
        exit 1
    fi
fi

# -----------------------------------------------------------------------------
# Step 2: Install Amplifier
# -----------------------------------------------------------------------------
print_header "Installing Amplifier"

if command -v amplifier &> /dev/null; then
    AMPLIFIER_VERSION=$(amplifier --version 2>/dev/null || echo "unknown")
    print_success "Amplifier is already installed: $AMPLIFIER_VERSION"
    print_warning "Updating to latest version..."
    amplifier update || uv tool install --upgrade git+https://github.com/microsoft/amplifier-app-cli
else
    print_warning "Amplifier not found. Installing..."
    uv tool install git+https://github.com/microsoft/amplifier-app-cli
    
    if command -v amplifier &> /dev/null; then
        print_success "Amplifier installed successfully: $(amplifier --version)"
    else
        print_error "Failed to install Amplifier"
        exit 1
    fi
fi

# -----------------------------------------------------------------------------
# Step 3: Install Providers
# -----------------------------------------------------------------------------
print_header "Installing Providers"

PROVIDERS=(
    "anthropic"
    "gemini"
    "azure-openai"
)

for provider in "${PROVIDERS[@]}"; do
    echo "Installing provider: $provider"
    amplifier provider install "$provider" || print_warning "Provider $provider may already be installed"
    print_success "Provider $provider ready"
done

# -----------------------------------------------------------------------------
# Step 4: Add Bundles (regular)
# -----------------------------------------------------------------------------
print_header "Adding Bundles"

# Regular bundles (not --app)
BUNDLES=(
    "design-intelligence-enhanced:git+https://github.com/anderlpz/amplifier-bundle-design-intelligence-enhanced@main"
    "discovery:git+https://github.com/anderlpz/amplifier-bundle-discovery@main"
    "m365:git+https://github.com/colombod/amplifier-bundle-m365@main"
    "made-support:git+https://github.com/microsoft-amplifier/amplifier-bundle-made-support@main"
    "pr-review:git+https://github.com/robotdad/amplifier-bundle-pr-review"
    "stories:git+https://github.com/microsoft/amplifier-bundle-stories@main"
    "tui-tester:git+https://github.com/colombod/amplifier-bundle-tui-tester@main"
)

for bundle_entry in "${BUNDLES[@]}"; do
    name="${bundle_entry%%:*}"
    url="${bundle_entry#*:}"
    echo "Adding bundle: $name"
    amplifier bundle add "$name" "$url" 2>/dev/null || print_warning "Bundle $name may already be added"
    print_success "Bundle $name ready"
done

# -----------------------------------------------------------------------------
# Step 5: Add App Bundles (always composed with --app flag)
# -----------------------------------------------------------------------------
print_header "Adding App Bundles (always composed)"

APP_BUNDLES=(
    "deepwiki:git+https://github.com/colombod/amplifier-bundle-deepwiki@main"
    "perplexity:git+https://github.com/colombod/amplifier-bundle-perplexity@main"
)

for bundle_entry in "${APP_BUNDLES[@]}"; do
    name="${bundle_entry%%:*}"
    url="${bundle_entry#*:}"
    echo "Adding app bundle: $name"
    amplifier bundle add "$name" "$url" --app 2>/dev/null || print_warning "App bundle $name may already be added"
    print_success "App bundle $name ready (always composed)"
done

# -----------------------------------------------------------------------------
# Step 6: Environment Variables Setup
# -----------------------------------------------------------------------------
print_header "Environment Variables"

echo "The following environment variables are required for the providers to work:"
echo ""
echo "  ANTHROPIC_API_KEY       - Your Anthropic API key"
echo "  ANTHROPIC_BASE_URL      - Anthropic base URL (optional, for proxies)"
echo "  GOOGLE_API_KEY          - Your Google AI API key (for Gemini)"
echo "  AZURE_OPENAI_ENDPOINT   - Your Azure OpenAI endpoint"
echo "  AZURE_OPENAI_API_VERSION - Azure OpenAI API version (e.g., 2024-02-15-preview)"
echo ""

# Check if keys.env exists
KEYS_FILE="$HOME/.amplifier/keys.env"
if [ -f "$KEYS_FILE" ]; then
    print_success "Found existing keys.env at $KEYS_FILE"
else
    print_warning "No keys.env found at $KEYS_FILE"
    echo ""
    echo "To set up your API keys, create ~/.amplifier/keys.env with:"
    echo ""
    echo "  ANTHROPIC_API_KEY=your-key-here"
    echo "  GOOGLE_API_KEY=your-key-here"
    echo "  AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com"
    echo "  AZURE_OPENAI_API_VERSION=2024-02-15-preview"
    echo ""
fi

# -----------------------------------------------------------------------------
# Done!
# -----------------------------------------------------------------------------
print_header "Bootstrap Complete!"

echo "Your Amplifier setup is ready. Summary:"
echo ""
echo "  Providers installed:"
for provider in "${PROVIDERS[@]}"; do
    echo "    - $provider"
done
echo ""
echo "  Bundles added:"
for bundle_entry in "${BUNDLES[@]}"; do
    name="${bundle_entry%%:*}"
    echo "    - $name"
done
echo ""
echo "  App bundles (always composed):"
for bundle_entry in "${APP_BUNDLES[@]}"; do
    name="${bundle_entry%%:*}"
    echo "    - $name"
done
echo ""
echo "Run 'amplifier run' to start a session!"
echo ""
