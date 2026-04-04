#!/usr/bin/env bash
set -euo pipefail

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Universal AI Rules & Skills Suite — Setup Script
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_DIR="$SCRIPT_DIR/.ai-suite"
READY_DIR="$SUITE_DIR/ready"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ── Helpers ──────────────────────────────────────

print_banner() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  🛡️  Universal AI Rules & Skills Suite — Setup${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▸${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✖${NC} $1"
}

print_done() {
    echo -e "${GREEN}✔${NC} $1"
}

print_info() {
    echo -e "${DIM}  $1${NC}"
}

# ── Validation ───────────────────────────────────

check_prerequisites() {
    if [ ! -d "$SUITE_DIR" ]; then
        print_error ".ai-suite/ directory not found at: $SUITE_DIR"
        print_info "Make sure you're running this script from the repository root."
        exit 1
    fi

    if [ ! -d "$READY_DIR" ]; then
        print_error ".ai-suite/ready/ directory not found."
        print_info "The ready-to-use adapter files are missing. Re-clone the repository."
        exit 1
    fi
}

# ── Target directory ─────────────────────────────

ask_target_directory() {
    echo -e "${BOLD}Where is your project?${NC}"
    echo ""
    echo "  1) Current directory ($(pwd))"
    echo "  2) Enter a custom path"
    echo ""
    read -rp "$(echo -e "${CYAN}Choose [1/2]:${NC} ")" dir_choice

    case "$dir_choice" in
        1)
            TARGET_DIR="$(pwd)"
            ;;
        2)
            read -rp "$(echo -e "${CYAN}Enter project path:${NC} ")" custom_path
            TARGET_DIR="$(cd "$custom_path" 2>/dev/null && pwd)" || {
                print_error "Directory does not exist: $custom_path"
                exit 1
            }
            ;;
        *)
            print_error "Invalid choice. Exiting."
            exit 1
            ;;
    esac

    echo ""
    print_done "Target project: ${BOLD}$TARGET_DIR${NC}"
    echo ""
}

# ── IDE selection ────────────────────────────────

ask_ide_selection() {
    echo -e "${BOLD}Which AI code editor(s) do you use?${NC}"
    echo -e "${DIM}Select all that apply — enter numbers separated by spaces.${NC}"
    echo ""
    echo "  1) Cursor"
    echo "  2) Claude Code (Anthropic)"
    echo "  3) Antigravity IDE (Google)"
    echo "  4) Warp AI"
    echo "  5) OpenAI Codex CLI"
    echo "  6) Windsurf (Codeium)"
    echo "  7) All of the above"
    echo ""
    read -rp "$(echo -e "${CYAN}Your choice(s) [e.g. 1 3 5]:${NC} ")" ide_input

    SELECTED_IDES=()

    if [[ "$ide_input" == *"7"* ]]; then
        SELECTED_IDES=("cursor" "claude" "antigravity" "warp" "codex" "windsurf")
    else
        for choice in $ide_input; do
            case "$choice" in
                1) SELECTED_IDES+=("cursor") ;;
                2) SELECTED_IDES+=("claude") ;;
                3) SELECTED_IDES+=("antigravity") ;;
                4) SELECTED_IDES+=("warp") ;;
                5) SELECTED_IDES+=("codex") ;;
                6) SELECTED_IDES+=("windsurf") ;;
                *) print_warn "Unknown option: $choice — skipping" ;;
            esac
        done
    fi

    if [ ${#SELECTED_IDES[@]} -eq 0 ]; then
        print_error "No editors selected. Exiting."
        exit 1
    fi

    echo ""
    print_done "Selected: ${BOLD}${SELECTED_IDES[*]}${NC}"
    echo ""
}

# ── Cursor-specific ──────────────────────────────

ask_cursor_format() {
    echo -e "${BOLD}Cursor setup format:${NC}"
    echo ""
    echo "  1) Single .cursorrules file (simple, good for most projects)"
    echo "  2) Multiple .cursor/rules/*.mdc files (granular, recommended for teams)"
    echo ""
    read -rp "$(echo -e "${CYAN}Choose [1/2]:${NC} ")" cursor_choice
    echo ""

    case "$cursor_choice" in
        1) CURSOR_FORMAT="single" ;;
        2) CURSOR_FORMAT="multi" ;;
        *) CURSOR_FORMAT="single" ;;
    esac
}

# ── File installation ────────────────────────────

install_suite_directory() {
    print_step "Copying .ai-suite/ into project..."

    if [ -d "$TARGET_DIR/.ai-suite" ]; then
        print_warn ".ai-suite/ already exists in the target project."
        read -rp "$(echo -e "${YELLOW}Overwrite? [y/N]:${NC} ")" overwrite
        if [[ "$overwrite" =~ ^[Yy]$ ]]; then
            rm -rf "$TARGET_DIR/.ai-suite"
        else
            print_info "Keeping existing .ai-suite/ directory."
            return
        fi
    fi

    cp -r "$SUITE_DIR" "$TARGET_DIR/.ai-suite"
    print_done ".ai-suite/ installed"
}

install_cursor_single() {
    local target="$TARGET_DIR/.cursorrules"
    if [ -f "$target" ]; then
        print_warn ".cursorrules already exists."
        read -rp "$(echo -e "${YELLOW}Overwrite? [y/N]:${NC} ")" ow
        [[ ! "$ow" =~ ^[Yy]$ ]] && return
    fi
    cp "$READY_DIR/cursorrules" "$target"
    print_done "Created .cursorrules"
}

install_cursor_multi() {
    local rules_dir="$TARGET_DIR/.cursor/rules"
    mkdir -p "$rules_dir"
    for mdc_file in "$READY_DIR"/cursor-rules/*.mdc; do
        [ -f "$mdc_file" ] || continue
        local basename=$(basename "$mdc_file")
        cp "$mdc_file" "$rules_dir/$basename"
        print_done "Created .cursor/rules/$basename"
    done
}

install_claude() {
    local target="$TARGET_DIR/CLAUDE.md"
    if [ -f "$target" ]; then
        print_warn "CLAUDE.md already exists."
        read -rp "$(echo -e "${YELLOW}Overwrite? [y/N]:${NC} ")" ow
        [[ ! "$ow" =~ ^[Yy]$ ]] && return
    fi
    cp "$READY_DIR/CLAUDE.md" "$target"
    print_done "Created CLAUDE.md"
}

install_antigravity() {
    local target="$TARGET_DIR/GEMINI.md"
    if [ -f "$target" ]; then
        print_warn "GEMINI.md already exists."
        read -rp "$(echo -e "${YELLOW}Overwrite? [y/N]:${NC} ")" ow
        [[ ! "$ow" =~ ^[Yy]$ ]] && return
    fi
    cp "$READY_DIR/GEMINI.md" "$target"
    print_done "Created GEMINI.md"
}

install_warp() {
    mkdir -p "$TARGET_DIR/.warp"
    local target="$TARGET_DIR/.warp/rules.md"
    if [ -f "$target" ]; then
        print_warn ".warp/rules.md already exists."
        read -rp "$(echo -e "${YELLOW}Overwrite? [y/N]:${NC} ")" ow
        [[ ! "$ow" =~ ^[Yy]$ ]] && return
    fi
    cp "$READY_DIR/warp-rules.md" "$target"
    print_done "Created .warp/rules.md"
}

install_codex() {
    local target="$TARGET_DIR/AGENTS.md"
    if [ -f "$target" ]; then
        print_warn "AGENTS.md already exists."
        read -rp "$(echo -e "${YELLOW}Overwrite? [y/N]:${NC} ")" ow
        [[ ! "$ow" =~ ^[Yy]$ ]] && return
    fi
    cp "$READY_DIR/AGENTS.md" "$target"
    print_done "Created AGENTS.md"
}

install_windsurf() {
    local target="$TARGET_DIR/.windsurfrules"
    if [ -f "$target" ]; then
        print_warn ".windsurfrules already exists."
        read -rp "$(echo -e "${YELLOW}Overwrite? [y/N]:${NC} ")" ow
        [[ ! "$ow" =~ ^[Yy]$ ]] && return
    fi
    cp "$READY_DIR/windsurfrules" "$target"
    print_done "Created .windsurfrules"
}

# ── Summary ──────────────────────────────────────

print_summary() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  ✅ Setup Complete!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}Project:${NC} $TARGET_DIR"
    echo -e "  ${BOLD}Editors:${NC} ${SELECTED_IDES[*]}"
    echo ""
    echo -e "  ${BOLD}Files installed:${NC}"
    echo -e "  ${DIM}├── .ai-suite/          (26 rule files — the brain)${NC}"

    for ide in "${SELECTED_IDES[@]}"; do
        case "$ide" in
            cursor)
                if [ "$CURSOR_FORMAT" = "single" ]; then
                    echo -e "  ${DIM}├── .cursorrules        (Cursor adapter)${NC}"
                else
                    echo -e "  ${DIM}├── .cursor/rules/*.mdc (Cursor rules — granular)${NC}"
                fi
                ;;
            claude)     echo -e "  ${DIM}├── CLAUDE.md           (Claude Code adapter)${NC}" ;;
            antigravity) echo -e "  ${DIM}├── GEMINI.md           (Antigravity adapter)${NC}" ;;
            warp)       echo -e "  ${DIM}├── .warp/rules.md      (Warp AI adapter)${NC}" ;;
            codex)      echo -e "  ${DIM}├── AGENTS.md           (Codex CLI adapter)${NC}" ;;
            windsurf)   echo -e "  ${DIM}├── .windsurfrules      (Windsurf adapter)${NC}" ;;
        esac
    done

    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo -e "  1. ${DIM}cd $TARGET_DIR${NC}"
    echo -e "  2. Add project-specific rules to the bottom of your adapter file"
    echo -e "  3. ${DIM}git add .ai-suite/ && git commit -m 'chore: add AI rules suite'${NC}"
    echo -e "  4. Open your editor — the AI will load rules automatically"
    echo ""
    echo -e "  ${DIM}Docs: https://github.com/your-org/ai-rules-suite${NC}"
    echo ""
}

# ── Main ─────────────────────────────────────────

main() {
    print_banner
    check_prerequisites

    # Step 1: Where to install
    ask_target_directory

    # Step 2: Which editor(s)
    ask_ide_selection

    # Step 3: Editor-specific questions
    CURSOR_FORMAT="single"
    for ide in "${SELECTED_IDES[@]}"; do
        if [ "$ide" = "cursor" ]; then
            ask_cursor_format
        fi
    done

    # Step 4: Confirm
    echo -e "${BOLD}Ready to install:${NC}"
    echo -e "  Target:  $TARGET_DIR"
    echo -e "  Editors: ${SELECTED_IDES[*]}"
    echo ""
    read -rp "$(echo -e "${CYAN}Proceed? [Y/n]:${NC} ")" confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    echo ""

    # Step 5: Install
    install_suite_directory

    for ide in "${SELECTED_IDES[@]}"; do
        case "$ide" in
            cursor)
                if [ "$CURSOR_FORMAT" = "single" ]; then
                    install_cursor_single
                else
                    install_cursor_multi
                fi
                ;;
            claude)      install_claude ;;
            antigravity) install_antigravity ;;
            warp)        install_warp ;;
            codex)       install_codex ;;
            windsurf)    install_windsurf ;;
        esac
    done

    # Step 6: Summary
    print_summary
}

main "$@"
