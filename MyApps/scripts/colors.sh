#!/usr/bin/env bash
# ملف الألوان المشترك لجميع السكريبتات

# دالة لتحديد المسار الأساسي للبرنامج
get_script_dir() {
    # الحصول على مسار السكريبت الحالي
    local script_path="${BASH_SOURCE[0]}"
    # إذا كان السكريبت يعمل من رابط رمزي، اتبع الرابط
    while [ -L "$script_path" ]; do
        local dir="$(cd -P "$(dirname "$script_path")" && pwd)"
        script_path="$(readlink "$script_path")"
        # إذا كان الرابط نسبي، اجعله مطلق
        [[ $script_path != /* ]] && script_path="$dir/$script_path"
    done
    # إرجاع مجلد السكريبت
    echo "$(cd -P "$(dirname "$script_path")" && pwd)"
}

# تحديد المسار الأساسي للبرنامج
SCRIPT_DIR="$(get_script_dir)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# ألوان النص
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'

# ألوان الخلفية
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'

# إعادة تعيين الألوان
NC='\033[0m' # No Color

# دوال الألوان
print_success() {
    echo -e "${GREEN} $1${NC}"
}

print_error() {
    echo -e "${RED} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  $1${NC}"
}

print_info() {
    echo -e "${BLUE}  $1${NC}"
}

print_header() {
    echo -e "${CYAN}=========================================="
    echo -e "    $1"
    echo -e "==========================================${NC}"
}

print_subheader() {
    echo -e "${PURPLE}$1${NC}"
}

print_list_item() {
    echo -e "${WHITE}   $1${NC}"
}

print_app_count() {
    echo -e "${GRAY}      Apps: $1${NC}"
}

print_status_ok() {
    echo -e "${GREEN}      $1${NC}"
}

print_status_missing() {
    echo -e "${RED}      $1${NC}"
}

print_commands() {
    echo -e "${YELLOW} Commands:${NC}"
}

print_summary() {
    echo -e "${BLUE} Summary:${NC}"
}

print_creating() {
    echo -e "${CYAN} $1${NC}"
}

print_completed() {
    echo -e "${GREEN} $1${NC}"
}

print_removing() {
    echo -e "${RED}  $1${NC}"
}

print_backup() {
    echo -e "${PURPLE} $1${NC}"
}
