#!/usr/bin/env bash
set -e

# تحميل ملف الألوان
source "$(dirname "$0")/colors.sh"

USER_NAME="$(whoami)"
# مسار ملفات .desktop
APP_DIR="$HOME/.local/share/applications"
# المسار الأساسي للبرنامج (يتم تحديده تلقائياً)
MY_APPS_BASE_DIR="$BASE_DIR"
# مسار لحفظ ملفات الباش التنفيذية
BASH_SCRIPTS_DIR="$MY_APPS_BASE_DIR/scripts/bash-scripts"
# مسار ملفات الثيم
THEMES_DIR="$MY_APPS_BASE_DIR/themes"
# مسار مجموعات التطبيقات
APP_GROUPS_DIR="$MY_APPS_BASE_DIR/my-groups"

# دالة لكشف مدير الحزم المستخدم
detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    elif command -v emerge >/dev/null 2>&1; then
        echo "emerge"
    else
        echo "unknown"
    fi
}

# دالة لتثبيت المتطلبات
install_dependencies() {
    local pkg_manager=$(detect_package_manager)
    echo "Detected package manager: $pkg_manager"
    echo "Installing required dependencies..."
    
    # التحقق من صلاحيات sudo
    if ! sudo -n true 2>/dev/null; then
        echo "This script requires sudo privileges to install dependencies."
        echo "Please run with sudo or enter your password when prompted."
    fi
    
    case "$pkg_manager" in
        "apt")
            sudo apt-get update
            sudo apt-get install -y rofi bc libgtk-3-0 libgtk-3-dev
            ;;
        "yum"|"dnf")
            if [ "$pkg_manager" = "yum" ]; then
                sudo yum install -y rofi bc gtk3 gtk3-devel
            else
                sudo dnf install -y rofi bc gtk3 gtk3-devel
            fi
            ;;
        "pacman")
            sudo pacman -S --noconfirm rofi bc gtk3
            ;;
        "zypper")
            sudo zypper install -y rofi bc gtk3 gtk3-devel
            ;;
        "emerge")
            sudo emerge -av rofi bc gtk+
            ;;
        *)
            echo "Warning: Unknown package manager. Please install rofi, bc, and gtk3 manually."
            echo "Required packages: rofi, bc, gtk3"
            echo "You can try installing them manually:"
            echo "  - Ubuntu/Debian: sudo apt install rofi bc libgtk-3-0"
            echo "  - CentOS/RHEL: sudo yum install rofi bc gtk3"
            echo "  - Fedora: sudo dnf install rofi bc gtk3"
            echo "  - Arch: sudo pacman -S rofi bc gtk3"
            return 1
            ;;
    esac
    
    # التحقق من نجاح التثبيت
    if [ $? -eq 0 ]; then
        echo "Dependencies installed successfully!"
    else
        echo "Error: Failed to install some dependencies."
        echo "Please install them manually and try again."
        return 1
    fi
}

# دالة للتحقق من وجود المتطلبات
check_dependencies() {
    local missing_deps=()
    
    if ! command -v rofi >/dev/null 2>&1; then
        missing_deps+=("rofi")
    fi
    
    if ! command -v bc >/dev/null 2>&1; then
        missing_deps+=("bc")
    fi
    
    if ! command -v gtk-launch >/dev/null 2>&1; then
        missing_deps+=("gtk-launch")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        echo "Installing missing dependencies..."
        install_dependencies
    else
        print_success "All dependencies are already installed."
    fi
}

# رسالة ترحيب
print_header "App Group Creator - Universal Script"
echo "This script will automatically install all required dependencies"
echo "and create app groups that work on any Linux distribution."
echo

# التحقق من المتطلبات وتثبيتها إذا لزم الأمر
echo "Checking dependencies..."
check_dependencies

# التأكد من وجود المجلدات المطلوبة
mkdir -p "$APP_DIR"
mkdir -p "$BASH_SCRIPTS_DIR"
mkdir -p "$HOME/.config/rofi"
cp "$THEMES_DIR/theme.rasi" "$HOME/.config/rofi/" 2>/dev/null || print_warning "theme.rasi not found, using default rofi theme"
# دالة لقراءة المدخلات من المستخدم
read_input() {
  local prompt="$1"
  local var
  while true; do
    read -e -p "$prompt: " var
    if [ -n "$var" ]; then
      printf "%s" "$var"
      break
    else
      echo "Please enter a valid value."
    fi
  done
}

echo "Creating a new .desktop file for user: $USER_NAME"
echo

# قراءة المعلومات من المستخدم
echo "Please provide the following information:"
Name=$(read_input "Name of the app group")
Icon=$(read_input "Icon (full path or icon name)")

# إنشاء مجلد للتطبيقات داخل المجموعة الجديدة
mkdir -p "$MY_APPS_BASE_DIR/my-groups/$Name"

# إنشاء أسماء ملفات نظيفة
clean_name="$(echo "$Name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')"
desktop_filename="$clean_name.desktop"
bash_filename="$clean_name.sh"

# تحديد المسارات النهائية للملفات
dest_desktop="$APP_DIR/$desktop_filename"
dest_bash="$BASH_SCRIPTS_DIR/$bash_filename"

# التحقق إذا كان الملف موجودًا بالفعل
echo
if [[ -f "$dest_desktop" ]]; then
  read -p "File $dest_desktop already exists. Overwrite? (y/n) " yn
  case "$yn" in
    [Yy]* ) ;;
    * ) echo "Canceled."; exit 1 ;;
  esac
fi

# استبدال ~ بالمسار الكامل للمنزل في أيقونة
Icon="${Icon/#\~/$HOME}"

# إنشاء ملف .desktop
cat > "$dest_desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$Name
Comment=App group created by script
Exec=$dest_bash
Icon=$Icon
Categories=Utility;
Terminal=false
EOF

# إنشاء ملف الباش التنفيذي
cat > "$dest_bash" <<EOF
#!/bin/bash
# الدليل الذي يحتوي على اختصارات هذه المجموعة
APP_DIR="$MY_APPS_BASE_DIR/my-groups/$Name"

# --- Rofi script logic starts here ---
ELEMENT_WIDTH=80
ELEMENT_HEIGHT=65
ELEMENT_SPACING=10
WINDOW_PADDING=15

APP_COUNT=\$(find "\$APP_DIR" -maxdepth 1 -name "*.desktop" | wc -l)

if [ "\$APP_COUNT" -eq 0 ]; then
    exit 0
fi

if [ "\$APP_COUNT" -eq 3 ]; then
    COLUMNS=3
else
    COLUMNS=\$(printf "%.0f" "\$(echo "sqrt(\$APP_COUNT)" | bc -l)")
    COLUMNS=\$(( COLUMNS < 2 ? 2 : (COLUMNS > 6 ? 6 : COLUMNS) ))
fi

ROWS=\$(( (APP_COUNT + COLUMNS - 1) / COLUMNS ))

WINDOW_WIDTH=\$(( (COLUMNS * ELEMENT_WIDTH) + ((COLUMNS - 1) * ELEMENT_SPACING) + (2 * WINDOW_PADDING) ))
WINDOW_HEIGHT=\$(( (ROWS * ELEMENT_HEIGHT) + ((ROWS - 1) * ELEMENT_SPACING) + (2 * WINDOW_PADDING) ))

generate_list() {
    for app_file in "\$APP_DIR"/*.desktop; do
        if [ -f "\$app_file" ]; then
            APP_NAME=\$(grep -m 1 '^Name=' "\$app_file" | cut -d'=' -f2-)
            ICON_NAME=\$(grep -m 1 '^Icon=' "\$app_file" | cut -d'=' -f2-)
            echo -en "\$APP_NAME\\0icon\\x1f\$ICON_NAME\\n"
        fi
    done
}

CHOSEN_APP_NAME=\$(generate_list | rofi -dmenu -i \\
    -theme ~/.config/rofi/theme.rasi \\
    -theme-str "window { width: \${WINDOW_WIDTH}px; height: \${WINDOW_HEIGHT}px; } listview { columns: \${COLUMNS}; }")

if [ -n "\$CHOSEN_APP_NAME" ]; then
    MATCHING_FILE=\$(grep -l "^Name=\$CHOSEN_APP_NAME$" "\$APP_DIR"/*.desktop)
    if [ -n "\$MATCHING_FILE" ]; then
        APP_ID=\$(basename "\$MATCHING_FILE" .desktop)
        gtk-launch "\$APP_ID" &
    fi
fi
EOF


# إعطاء الصلاحيات اللازمة
chmod 644 "$dest_desktop"
chmod +x "$dest_bash"

echo
print_header "Successfully created app group!"
echo "Desktop File: $dest_desktop"
echo "Executable Script: $dest_bash"
echo "App Directory: $MY_APPS_BASE_DIR/my-groups/$Name"
echo
print_subheader " To add apps to this group:"
echo "   1. Copy your .desktop files to: $MY_APPS_BASE_DIR/my-groups/$Name"
echo "   2. The group will automatically appear in your application menu"
echo
print_subheader " Supported Linux distributions:"
print_success "Ubuntu/Debian (apt)"
print_success "CentOS/RHEL (yum)"
print_success "Fedora (dnf)"
print_success "Arch Linux (pacman)"
print_success "openSUSE (zypper)"
print_success "Gentoo (emerge)"
echo "=========================================="

# التحقق من نجاح العملية
if [ $? -eq 0 ]; then
    print_completed "App group creation completed successfully!"
else
    print_error "Error occurred during app group creation."
    echo "Please check the error messages above and try again."
    exit 1
fi