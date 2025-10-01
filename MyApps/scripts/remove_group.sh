#!/usr/bin/env bash
# سكريبت حذف مجموعات التطبيقات

set -e

# تحميل ملف الألوان
source "$(dirname "$0")/colors.sh"

# المسار الأساسي للبرنامج (يتم تحديده تلقائياً)
MY_APPS_BASE_DIR="$BASE_DIR"
APP_DIR="$HOME/.local/share/applications"
GROUPS_DIR="$MY_APPS_BASE_DIR/my-groups"
SCRIPTS_DIR="$MY_APPS_BASE_DIR/scripts/bash-scripts"

# دالة لعرض المجموعات الموجودة
list_groups() {
    print_subheader " Available groups:"
    if [ -d "$GROUPS_DIR" ]; then
        for group in "$GROUPS_DIR"/*; do
            if [ -d "$group" ]; then
                group_name=$(basename "$group")
                print_list_item "$group_name"
            fi
        done
    else
        print_warning "No groups found."
    fi
}

# دالة لحذف مجموعة
remove_group() {
    local group_name="$1"
    local clean_name="$(echo "$group_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')"
    
    local group_dir="$GROUPS_DIR/$group_name"
    local desktop_file="$APP_DIR/$clean_name.desktop"
    local script_file="$SCRIPTS_DIR/$clean_name.sh"
    
    print_removing "Removing group: $group_name"
    echo "================================"
    
    # حذف مجلد المجموعة
    if [ -d "$group_dir" ]; then
        rm -rf "$group_dir"
        print_success "Removed group directory: $group_dir"
    else
        print_warning "Group directory not found: $group_dir"
    fi
    
    # حذف ملف .desktop
    if [ -f "$desktop_file" ]; then
        rm "$desktop_file"
        print_success "Removed desktop file: $desktop_file"
    else
        print_warning "Desktop file not found: $desktop_file"
    fi
    
    # حذف سكريبت الباش
    if [ -f "$script_file" ]; then
        rm "$script_file"
        print_success "Removed script file: $script_file"
    else
        print_warning "Script file not found: $script_file"
    fi
    
    print_completed "Group '$group_name' removed successfully!"
}

# دالة لقراءة المدخلات
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

# الرسالة الرئيسية
print_header "App Group Remover"
echo

# عرض المجموعات الموجودة
list_groups
echo

# قراءة اسم المجموعة المراد حذفها
if [ $# -eq 0 ]; then
    group_name=$(read_input "Enter group name to remove")
else
    group_name="$1"
fi

# التحقق من وجود المجموعة
if [ ! -d "$GROUPS_DIR/$group_name" ]; then
    print_error "Group '$group_name' not found!"
    echo "Available groups:"
    list_groups
    exit 1
fi

# تأكيد الحذف
echo
read -p "$(echo -e "${YELLOW}  Are you sure you want to remove '$group_name'? (y/N): ${NC}")" confirm
case "$confirm" in
    [Yy]* ) 
        remove_group "$group_name"
        ;;
    * ) 
        print_warning "Operation cancelled."
        exit 0
        ;;
esac