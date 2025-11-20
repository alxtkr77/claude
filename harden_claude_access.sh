#!/bin/bash
set -euo pipefail

# Claude Code Comprehensive Security Hardening Script
# - Restricts file system access to approved directories
# - Creates restricted user without sudo privileges
# - Provides defense-in-depth security

SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_DIR="$HOME/.claude/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/settings_backup_$TIMESTAMP.json"
RESTRICTED_USER="claude-restricted"
WORK_DIR="/home/iguazio/mlrun"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if settings file exists
check_settings_exist() {
    if [[ ! -f "$SETTINGS_FILE" ]]; then
        log_error "Claude Code settings file not found at: $SETTINGS_FILE"
        log_info "Please ensure Claude Code is installed and has been run at least once"
        exit 1
    fi
}

# Create backup
create_backup() {
    log_info "Creating backup of current settings..."
    mkdir -p "$BACKUP_DIR"
    cp "$SETTINGS_FILE" "$BACKUP_FILE"
    log_success "Backup created at: $BACKUP_FILE"
}

# Apply hardening
apply_hardening() {
    log_info "Applying access hardening to Claude Code..."

    # Read current settings
    local current_settings
    current_settings=$(cat "$SETTINGS_FILE")

    # Create hardened configuration
    # This restricts Claude to ONLY /home/iguazio/mlrun and blocks sensitive directories
    local hardened_config
    hardened_config=$(cat <<'EOF'
{
  "alwaysThinkingEnabled": true,
  "permissions": {
    "additionalDirectories": [
      "/home/iguazio/mlrun"
    ],
    "deny": [
      "/home/iguazio/.ssh",
      "/home/iguazio/.aws",
      "/home/iguazio/.config",
      "/home/iguazio/.kube",
      "/home/iguazio/.docker",
      "/home/iguazio/.gnupg",
      "/home/iguazio/.*rc",
      "/home/iguazio/.*history",
      "/etc/passwd",
      "/etc/shadow",
      "/etc/ssh"
    ]
  },
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
EOF
)

    # Write hardened configuration
    echo "$hardened_config" > "$SETTINGS_FILE"
    log_success "Hardened configuration applied"
}

# Verify hardening
verify_hardening() {
    log_info "Verifying hardened configuration..."

    local all_checks_passed=true

    # Check 1: Only /home/iguazio/mlrun is in additionalDirectories
    log_info "Check 1: Verifying allowed directories..."
    local allowed_dirs
    allowed_dirs=$(jq -r '.permissions.additionalDirectories[]' "$SETTINGS_FILE" 2>/dev/null || echo "")

    if [[ "$allowed_dirs" == "/home/iguazio/mlrun" ]]; then
        log_success "  ✓ Only /home/iguazio/mlrun is allowed"
    else
        log_error "  ✗ Unexpected allowed directories found:"
        echo "$allowed_dirs"
        all_checks_passed=false
    fi

    # Check 2: Sensitive directories are denied
    log_info "Check 2: Verifying denied directories..."
    local denied_dirs
    denied_dirs=$(jq -r '.permissions.deny[]' "$SETTINGS_FILE" 2>/dev/null || echo "")

    local required_denials=(
        "/home/iguazio/.ssh"
        "/home/iguazio/.aws"
        "/home/iguazio/.config"
        "/home/iguazio/.kube"
    )

    local denials_ok=true
    for required in "${required_denials[@]}"; do
        if echo "$denied_dirs" | grep -q "^$required$"; then
            log_success "  ✓ $required is denied"
        else
            log_error "  ✗ $required is NOT denied"
            denials_ok=false
            all_checks_passed=false
        fi
    done

    # Check 3: No global home directory access
    log_info "Check 3: Verifying no global home access..."
    if echo "$allowed_dirs" | grep -qE "^/home/iguazio$|^/home$|^~$"; then
        log_error "  ✗ Global home directory access detected!"
        all_checks_passed=false
    else
        log_success "  ✓ No global home directory access"
    fi

    # Check 4: Memory MCP server is configured
    log_info "Check 4: Verifying Memory MCP server..."
    local mcp_memory
    mcp_memory=$(jq -r '.mcpServers.memory.command' "$SETTINGS_FILE" 2>/dev/null || echo "")

    if [[ "$mcp_memory" == "npx" ]]; then
        log_success "  ✓ Memory MCP server is configured"
    else
        log_warning "  ! Memory MCP server not found (optional but recommended)"
    fi

    echo ""
    if [[ "$all_checks_passed" == true ]]; then
        log_success "=== File access hardening checks PASSED ==="
        return 0
    else
        log_error "=== Some file access hardening checks FAILED ==="
        return 1
    fi
}

# Check if restricted user exists
check_restricted_user() {
    if id "$RESTRICTED_USER" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Verify restricted user privileges
verify_restricted_user() {
    if ! check_restricted_user; then
        log_error "Restricted user '$RESTRICTED_USER' does not exist"
        return 1
    fi

    log_info "Verifying restricted user privileges..."
    local all_checks_passed=true

    # Check 1: User exists
    log_success "  ✓ Restricted user exists: $RESTRICTED_USER"

    # Check 2: User has no sudo access
    log_info "Check: User sudo access..."
    if sudo -u "$RESTRICTED_USER" sudo -n true 2>/dev/null; then
        log_error "  ✗ Restricted user HAS sudo access (SECURITY ISSUE!)"
        all_checks_passed=false
    else
        log_success "  ✓ Restricted user has NO sudo access"
    fi

    # Check 3: User can read work directory
    log_info "Check: Work directory read access..."
    if sudo -u "$RESTRICTED_USER" test -r "$WORK_DIR/README.md" 2>/dev/null; then
        log_success "  ✓ Restricted user CAN read work directory"
    else
        log_warning "  ! Restricted user CANNOT read work directory"
        all_checks_passed=false
    fi

    # Check 4: User can write to work directory
    log_info "Check: Work directory write access..."
    if sudo -u "$RESTRICTED_USER" test -w "$WORK_DIR" 2>/dev/null; then
        log_success "  ✓ Restricted user CAN write to work directory"
    else
        log_warning "  ! Restricted user CANNOT write to work directory"
    fi

    # Check 5: User cannot access SSH keys
    log_info "Check: SSH key protection..."
    if sudo -u "$RESTRICTED_USER" test -r "/home/iguazio/.ssh/id_rsa" 2>/dev/null; then
        log_error "  ✗ Restricted user CAN access SSH keys (SECURITY ISSUE!)"
        all_checks_passed=false
    else
        log_success "  ✓ Restricted user CANNOT access SSH keys"
    fi

    # Check 6: Wrapper script exists
    log_info "Check: Wrapper script..."
    if [[ -x "/usr/local/bin/claude-restricted" ]]; then
        log_success "  ✓ Wrapper script exists and is executable"
    else
        log_warning "  ! Wrapper script not found"
    fi

    echo ""
    if [[ "$all_checks_passed" == true ]]; then
        log_success "=== User privilege checks PASSED ==="
        return 0
    else
        log_error "=== Some user privilege checks FAILED ==="
        return 1
    fi
}

# Create restricted user
create_restricted_user() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Creating restricted user requires sudo privileges"
        log_info "Please run: sudo $0 --create-user"
        return 1
    fi

    if check_restricted_user; then
        log_warning "User '$RESTRICTED_USER' already exists"
        read -rp "Delete and recreate? (y/N): " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            log_info "Skipping user creation"
            return 0
        fi
        log_info "Removing existing user..."
        userdel -r "$RESTRICTED_USER" 2>/dev/null || true
    fi

    log_info "Creating restricted user: $RESTRICTED_USER"
    useradd -m -s /bin/bash "$RESTRICTED_USER"
    passwd -l "$RESTRICTED_USER" >/dev/null 2>&1
    log_success "User created: $RESTRICTED_USER"

    # Setup access to work directory
    log_info "Setting up access to $WORK_DIR"
    if command -v setfacl &>/dev/null; then
        setfacl -R -m u:$RESTRICTED_USER:rwX "$WORK_DIR" 2>/dev/null
        setfacl -d -m u:$RESTRICTED_USER:rwX "$WORK_DIR" 2>/dev/null
        log_success "ACL access configured"
    else
        log_warning "setfacl not available, using group permissions"
        chgrp -R iguazio "$WORK_DIR"
        chmod -R g+rwX "$WORK_DIR"
        usermod -aG iguazio "$RESTRICTED_USER"
        log_success "Group access configured"
    fi

    # Create wrapper script
    local wrapper_script="/usr/local/bin/claude-restricted"
    log_info "Creating wrapper script: $wrapper_script"

    cat > "$wrapper_script" <<'WRAPPER_EOF'
#!/bin/bash
# Wrapper to run Claude Code as restricted user

RESTRICTED_USER="claude-restricted"
WORK_DIR="/home/iguazio/mlrun"

# Check if already running as restricted user
if [[ $(whoami) == "$RESTRICTED_USER" ]]; then
    cd "$WORK_DIR" && exec claude "$@"
fi

# Run Claude Code as restricted user
exec sudo -u "$RESTRICTED_USER" -H \
    --preserve-env=PATH,MLRUN_DBPATH,V3IO_API,V3IO_ACCESS_KEY,MLRUN_HTTPDB__HTTP__VERIFY \
    bash -c "cd '$WORK_DIR' && claude $*"
WRAPPER_EOF

    chmod +x "$wrapper_script"
    log_success "Wrapper script created"

    # Configure sudoers
    local sudoers_file="/etc/sudoers.d/claude-restricted"
    log_info "Configuring sudoers..."

    cat > "$sudoers_file" <<SUDOERS_EOF
# Allow iguazio to run commands as claude-restricted without password
iguazio ALL=(claude-restricted) NOPASSWD: ALL
SUDOERS_EOF

    chmod 0440 "$sudoers_file"
    log_success "Sudoers configured"

    echo ""
    log_success "=== Restricted user setup complete ==="
    echo ""
    log_info "Usage:"
    echo "  Run Claude Code as restricted user:"
    echo "    claude-restricted"
    echo ""
    echo "  Or manually:"
    echo "    sudo -u $RESTRICTED_USER claude"
    echo ""
}

# Remove restricted user
remove_restricted_user() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Removing restricted user requires sudo privileges"
        log_info "Please run: sudo $0 --remove-user"
        return 1
    fi

    if ! check_restricted_user; then
        log_warning "Restricted user '$RESTRICTED_USER' does not exist"
        return 0
    fi

    log_warning "This will remove the restricted user and all associated files"
    read -rp "Are you sure? (y/N): " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        log_info "Cancelled"
        return 0
    fi

    log_info "Removing restricted user..."
    userdel -r "$RESTRICTED_USER" 2>/dev/null || true

    log_info "Removing wrapper script..."
    rm -f "/usr/local/bin/claude-restricted"

    log_info "Removing sudoers configuration..."
    rm -f "/etc/sudoers.d/claude-restricted"

    log_success "Restricted user removed"
}

# Display current configuration
show_current_config() {
    echo ""
    log_info "=== File Access Configuration ==="
    echo ""
    echo "Allowed Directories:"
    jq -r '.permissions.additionalDirectories[]' "$SETTINGS_FILE" 2>/dev/null | while read -r dir; do
        echo "  - $dir"
    done
    echo ""
    echo "Denied Directories:"
    jq -r '.permissions.deny[]' "$SETTINGS_FILE" 2>/dev/null | while read -r dir; do
        echo "  - $dir"
    done
    echo ""

    log_info "=== User Privilege Configuration ==="
    echo ""
    if check_restricted_user; then
        echo "Restricted User: $RESTRICTED_USER (EXISTS)"
        echo "Current User: $(whoami)"
        echo "Sudo Access: $(groups | grep -q sudo && echo "YES" || echo "NO")"
        if [[ -x "/usr/local/bin/claude-restricted" ]]; then
            echo "Wrapper: /usr/local/bin/claude-restricted (installed)"
        else
            echo "Wrapper: NOT installed"
        fi
    else
        echo "Restricted User: NOT created"
    fi
    echo ""
}

# Comprehensive verification
comprehensive_check() {
    local file_check_passed=true
    local user_check_passed=true

    echo ""
    log_info "=== COMPREHENSIVE SECURITY CHECK ==="
    echo ""

    # File access checks
    verify_hardening || file_check_passed=false

    echo ""

    # User privilege checks (only if user exists)
    if check_restricted_user; then
        verify_restricted_user || user_check_passed=false
    else
        log_warning "Restricted user not created - privilege hardening not active"
        user_check_passed=false
    fi

    echo ""
    echo "=================================================="
    if [[ "$file_check_passed" == true ]] && [[ "$user_check_passed" == true ]]; then
        log_success "=== ALL SECURITY CHECKS PASSED ==="
        log_success "Defense-in-depth security is active"
        return 0
    elif [[ "$file_check_passed" == true ]]; then
        log_warning "=== FILE ACCESS HARDENING ACTIVE ==="
        log_warning "Consider creating restricted user for additional security"
        return 1
    else
        log_error "=== SECURITY CHECKS FAILED ==="
        log_error "Run hardening steps to secure your environment"
        return 1
    fi
}

# Rollback to backup
rollback() {
    log_info "Available backups:"
    ls -lht "$BACKUP_DIR"/ 2>/dev/null | grep "settings_backup_" | head -5
    echo ""
    read -rp "Enter backup filename to restore (or 'cancel'): " backup_choice

    if [[ "$backup_choice" == "cancel" ]]; then
        log_info "Rollback cancelled"
        return
    fi

    local restore_path="$BACKUP_DIR/$backup_choice"
    if [[ -f "$restore_path" ]]; then
        cp "$restore_path" "$SETTINGS_FILE"
        log_success "Settings restored from: $restore_path"
        log_warning "Please restart Claude Code for changes to take effect"
    else
        log_error "Backup file not found: $restore_path"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "===================================================================="
    echo "  Claude Code Comprehensive Security Hardening"
    echo "===================================================================="
    echo ""
    echo "File Access Hardening:"
    echo "  1) Apply file access hardening (restrict directories)"
    echo "  2) Verify file access hardening"
    echo ""
    echo "User Privilege Hardening:"
    echo "  3) Create restricted user (requires sudo)"
    echo "  4) Verify restricted user"
    echo "  5) Remove restricted user (requires sudo)"
    echo ""
    echo "Combined Operations:"
    echo "  6) Apply BOTH hardenings (file + user)"
    echo "  7) Comprehensive security check (all verifications)"
    echo ""
    echo "Other:"
    echo "  8) Show current configuration"
    echo "  9) Rollback file settings to backup"
    echo "  0) Exit"
    echo ""
}

# Main function
main() {
    # Check dependencies
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Install with: sudo apt-get install jq"
        exit 1
    fi

    check_settings_exist

    # Command-line argument handling
    case "${1:-}" in
        --check)
            comprehensive_check
            exit $?
            ;;
        --apply)
            create_backup
            apply_hardening
            verify_hardening
            log_warning ""
            log_warning "IMPORTANT: You must restart Claude Code for changes to take effect!"
            exit $?
            ;;
        --create-user)
            create_restricted_user
            exit $?
            ;;
        --remove-user)
            remove_restricted_user
            exit $?
            ;;
        --full)
            log_info "Applying full hardening (file + user)..."
            create_backup
            apply_hardening
            verify_hardening
            echo ""
            create_restricted_user
            echo ""
            comprehensive_check
            log_warning ""
            log_warning "IMPORTANT: You must restart Claude Code for changes to take effect!"
            log_info "Usage: claude-restricted"
            exit $?
            ;;
        --help|-h)
            echo "Claude Code Comprehensive Security Hardening"
            echo ""
            echo "Usage:"
            echo "  $0 [OPTION]"
            echo ""
            echo "Options:"
            echo "  --check          Run comprehensive security check"
            echo "  --apply          Apply file access hardening only"
            echo "  --create-user    Create restricted user (requires sudo)"
            echo "  --remove-user    Remove restricted user (requires sudo)"
            echo "  --full           Apply BOTH file and user hardening (requires sudo)"
            echo "  --help, -h       Show this help message"
            echo "  (no options)     Interactive menu"
            echo ""
            exit 0
            ;;
    esac

    # Interactive mode
    while true; do
        show_menu
        read -rp "Select option [0-9]: " choice

        case $choice in
            1)
                create_backup
                apply_hardening
                verify_hardening
                log_warning ""
                log_warning "IMPORTANT: You must restart Claude Code for changes to take effect!"
                ;;
            2)
                verify_hardening
                ;;
            3)
                create_restricted_user
                ;;
            4)
                verify_restricted_user
                ;;
            5)
                remove_restricted_user
                ;;
            6)
                log_info "Applying full hardening..."
                create_backup
                apply_hardening
                verify_hardening
                echo ""
                create_restricted_user
                echo ""
                comprehensive_check
                log_warning ""
                log_warning "IMPORTANT: You must restart Claude Code for changes to take effect!"
                ;;
            7)
                comprehensive_check
                ;;
            8)
                show_current_config
                ;;
            9)
                rollback
                ;;
            0)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid option"
                ;;
        esac

        echo ""
        read -rp "Press Enter to continue..."
    done
}

# Run main function
main "$@"
