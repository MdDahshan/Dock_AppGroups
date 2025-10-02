

#  Dock_AppGroups

Easily **organize, manage, and launch curated app groups** on Linux using simple Bash scripts and `.desktop` entries.
Perfect for keeping your dock clean and having quick access to related apps under one launcher.



https://github.com/user-attachments/assets/1015e210-a2fa-49eb-baf3-4c2e5aa64260



---

##  Installation & Usage

1. **Run the setup script**

   ```bash
   bash create_group.sh
   ```

   This will automatically install all requirements.

2. **Create your first group**

   * The script will ask for:

     * **Group name** (e.g., "Browsers", "Editors")
     * **Group icon** (any image path or icon name)
   * Once confirmed, a new app group will be created.

3. **Find your groups**

   * Groups are stored in the `my_groups` folder.
   * Each group has its own subfolder created during step 2.

4. **Add applications to a group**

   * Copy `.desktop` files into your group’s folder.
   * Most `.desktop` files can be found in:

     ```
     /usr/share/applications
     ```
   * If you can’t find one, search for it:

     ```bash
     find / -name "*.desktop" 2>/dev/null | grep -i {app-name}
     ```

5. **Pin your group to the dock**

   * Once your group is ready, simply pin it to your dock for quick access.

 Done! Now clicking your group opens a launcher with all the apps you added.


---

##  Advanced Options

* **Change the theme**
  Edit the theme file inside the `theme/` folder, then run:

  ```bash
  ./scripts/update_theme.sh
  ```

* **Manage groups**
  You can **remove** one of your groups by running:

  ```bash
  ./scripts/remove_group.sh
  ```
  You can **list**  your groups by running:

  ```bash
  ./scripts/list_groups.sh
  ```	
  You can **backup**  your groups by running:

  ```bash
  ./scripts/backup_groups.sh
  ```	
---
