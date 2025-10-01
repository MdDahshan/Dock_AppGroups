#!/usr/bin/env bash
# سكريبت النسخ الاحتياطي للمجموعات

set -e

# تحميل ملف الألوان
source "$(dirname "$0")/colors.sh"

MY_APPS_BASE_DIR="$HOME/MyApps"
BACKUP_DIR="$MY_APPS_BASE_DIR/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="groups_backup_$TIMESTAMP"

# إنشاء مجلد النسخ الاحتياطي
mkdir -p "$BACKUP_DIR"

# دالة لإنشاء نسخة احتياطية
create_backup() {
    print_creating "Creating backup..."
    echo "===================="
    
    # نسخ المجموعات
    if [ -d "$MY_APPS_BASE_DIR/my-groups" ]; then
        cp -r "$MY_APPS_BASE_DIR/my-groups" "$BACKUP_DIR/$BACKUP_NAME"
        print_success "Groups backed up to: $BACKUP_DIR/$BACKUP_NAME"
    else
        print_warning "No groups found to backup"
        return 1
    fi
    
    # نسخ السكريبتات
    if [ -d "$MY_APPS_BASE_DIR/scripts" ]; then
        cp -r "$MY_APPS_BASE_DIR/scripts" "$BACKUP_DIR/$BACKUP_NAME/scripts"
        print_success "Scripts backed up"
    fi
    
    # نسخ الثيمات
    if [ -d "$MY_APPS_BASE_DIR/themes" ]; then
        cp -r "$MY_APPS_BASE_DIR/themes" "$BACKUP_DIR/$BACKUP_NAME/themes"
        print_success "Themes backed up"
    fi
    
    # إنشاء ملف معلومات النسخة الاحتياطية
    cat > "$BACKUP_DIR/$BACKUP_NAME/backup_info.txt" <<EOF
Backup created: $(date)
Groups directory: $MY_APPS_BASE_DIR/my-groups
Scripts directory: $MY_APPS_BASE_DIR/scripts
Themes directory: $MY_APPS_BASE_DIR/themes
Backup location: $BACKUP_DIR/$BACKUP_NAME
EOF
    
    print_success "Backup info saved"
    print_completed "Backup completed successfully!"
    echo "   Location: $BACKUP_DIR/$BACKUP_NAME"
}

# دالة لاستعادة نسخة احتياطية
restore_backup() {
    local backup_name="$1"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        print_error "Backup not found: $backup_path"
        return 1
    fi
    
    print_creating "Restoring backup: $backup_name"
    echo "=================================="
    
    # استعادة المجموعات
    if [ -d "$backup_path/my-groups" ]; then
        rm -rf "$MY_APPS_BASE_DIR/my-groups"
        cp -r "$backup_path/my-groups" "$MY_APPS_BASE_DIR/"
        print_success "Groups restored"
    fi
    
    # استعادة السكريبتات
    if [ -d "$backup_path/scripts" ]; then
        rm -rf "$MY_APPS_BASE_DIR/scripts"
        cp -r "$backup_path/scripts" "$MY_APPS_BASE_DIR/"
        print_success "Scripts restored"
    fi
    
    # استعادة الثيمات
    if [ -d "$backup_path/themes" ]; then
        rm -rf "$MY_APPS_BASE_DIR/themes"
        cp -r "$backup_path/themes" "$MY_APPS_BASE_DIR/"
        print_success "Themes restored"
    fi
    
    print_completed "Restore completed successfully!"
}

# دالة لعرض النسخ الاحتياطية المتاحة
list_backups() {
    print_subheader " Available backups:"
    if [ -d "$BACKUP_DIR" ]; then
        for backup in "$BACKUP_DIR"/*; do
            if [ -d "$backup" ]; then
                backup_name=$(basename "$backup")
                backup_date=$(stat -c %y "$backup" 2>/dev/null | cut -d' ' -f1 || echo "Unknown")
                print_list_item "$backup_name (Created: $backup_date)"
            fi
        done
    else
        print_warning "No backups found."
    fi
}

# معالجة الأوامر
case "$1" in
    create)
        create_backup
        ;;
    restore)
        if [ -z "$2" ]; then
            print_error "Please specify backup name to restore"
            echo "Usage: $0 restore <backup_name>"
            list_backups
            exit 1
        fi
        restore_backup "$2"
        ;;
    list)
        list_backups
        ;;
    *)
        echo "Usage: $0 {create|restore|list}"
        echo
        print_commands
        echo "  create  - Create a new backup"
        echo "  restore - Restore from backup (specify backup name)"
        echo "  list    - List available backups"
        echo
        echo "Examples:"
        echo "  $0 create"
        echo "  $0 restore groups_backup_20240101_120000"
        echo "  $0 list"
        exit 1
        ;;
esac
