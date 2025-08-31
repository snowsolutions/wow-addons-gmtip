# GMTip Addon

**GMTip** is a utility addon built for Game Masters (GMs) to streamline item and spell management.  
It provides quick access to item creation tools, customizable item templates, and enhanced tooltips that display critical IDs for both items and spells.

---

## ✨ Features
- **Create Item Panel**  
  - Enter one or more item IDs to instantly receive items using the `.additem` GM command.  
  - Supports batch creation by entering multiple IDs at once.

- **Item Templates**  
  - Save frequently used sets of item IDs as templates.  
  - Reuse templates with a single click—no need to re-enter IDs.

- **Enhanced Tooltips**  
  - Displays **Item ID** when hovering over an item.  
  - Displays **Spell ID** when hovering over a spell.  

- **Quick Copy Shortcut**  
  - **ALT + Left Click** an item to copy its ID directly into the **Create Item** text box.  
  - Speeds up the process of spawning items you just inspected.

---

## 📦 Installation
1. Download or clone this repository.  
2. Copy the `GMTip` folder into your World of Warcraft `Interface/AddOns/` directory.  
   - Example:  
     ```
     World of Warcraft/_classic_/Interface/AddOns/GMTip
     ```
3. Restart or reload your WoW client with `/reload`.

---

## ⚙️ Usage
- **Create Item**  
  - Open the GMTip panel and type/paste item IDs.  
  - Press **Create Item** to spawn them (requires GM access).  

- **Save & Use Templates**  
  - Enter a list of IDs and save them as a template.  
  - Select a template later to quickly re-create the same set of items.

- **Tooltip Enhancements**  
  - Hover any item → shows **Item ID**.  
  - Hover any spell → shows **Spell ID**.

- **Quick Copy Shortcut**  
  - Hold **ALT** and **Left Click** an item.  
  - The item’s ID is copied directly into the **Create Item** field.  

---

## 🛠 Requirements
- **Client:** TrinityCore 3.3.5a or compatible retail/private server.  
- **Permissions:** Requires GM access to use `.additem` command.  

---

## 🔮 Roadmap
Planned improvements:
- Support for `.additemset` or `.learn` commands.  
- Option to export/import templates between characters.  
- Search bar with auto-complete for templates.  

---

## 📜 License
This project is released under the [MIT License](LICENSE).  
Feel free to use, modify, and share.

---

## 🙌 Credits
- Developed by Frank Nguyen
- Built to simplify GM item and spell testing.
