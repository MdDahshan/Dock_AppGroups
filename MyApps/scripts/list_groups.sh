#!/usr/bin/env bash
# سكريبت لعرض جميع المجموعات

# تحميل ملف الألوان
source "$(dirname "$0")/colors.sh"

# المسار الأساسي للبرنامج (يتم تحديده تلقائياً)
MY_APPS_BASE_DIR="$BASE_DIR"
GROUPS_DIR="$MY_APPS_BASE_DIR/my-groups"
APP_DIR="$HOME/.local/share/applications"

# دالة لعرض تفاصيل المجموعة
show_group_details() {
    local group_name="$1"
    local group_dir="$GROUPS_DIR/$group_name"
    local clean_name="$(echo "$group_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-|-$//g')"
    local desktop_file="$APP_DIR/$clean_name.desktop"
    
    print_list_item "$group_name"
    
    # عدد التطبيقات في المجموعة
    local app_count=0
    if [ -d "$group_dir" ]; then
        app_count=$(find "$group_dir" -maxdepth 1 -name "*.desktop" | wc -l)
    fi
    print_app_count "$app_count"
    
    # حالة ملف .desktop
    if [ -f "$desktop_file" ]; then
        print_status_ok "Desktop entry: Available"
    else
        print_status_missing "Desktop entry: Missing"
    fi
    
    # قائمة التطبيقات
    if [ $app_count -gt 0 ]; then
        echo "      Applications:"
        for app in "$group_dir"/*.desktop; do
            if [ -f "$app" ]; then
                app_name=$(grep -m 1 '^Name=' "$app" | cut -d'=' -f2- 2>/dev/null || basename "$app" .desktop)
                echo "        • $app_name"
            fi
        done
    else
        echo "     Applications: None"
    fi
    echo
}

# الرسالة الرئيسية
print_header "App Groups Manager"
echo

# التحقق من وجود مجلد المجموعات
if [ ! -d "$GROUPS_DIR" ]; then
    print_error "No groups directory found at: $GROUPS_DIR"
    echo "Run create_group.sh to create your first group."
    exit 1
fi

# عرض المجموعات
print_subheader " Available Groups:"

group_count=0
for group in "$GROUPS_DIR"/*; do
    if [ -d "$group" ]; then
        group_name=$(basename "$group")
        show_group_details "$group_name"
        ((group_count++))
    fi
done

if [ $group_count -eq 0 ]; then
    print_warning "No groups found."
    echo
    print_commands
    echo "   ./create_group.sh"
else
    print_summary
    echo "==========="
    echo "  Total groups: $group_count"
    echo "  Groups directory: $GROUPS_DIR"
    echo "  Desktop entries: $APP_DIR"
    echo
    print_commands
    echo "   Create group: ./create_group.sh"
    echo "   Remove group: ./remove_group.sh"
    echo "   Update theme: ./update_theme"
fi
