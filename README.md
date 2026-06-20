# Knowledge Dump (Patch 12.0.7)

A lightweight, stand-alone World of Warcraft addon built on the **WoWAce3** framework. Designed for alt-army crafters looking to quickly verify expansion-specific profession thresholds directly from their chat box without wasting time traveling across capital hubs.

## 🌟 Features
* **Multi-Expansion Tracking:** Spans *Dragonflight*, *The War Within*, and *Midnight*.
* **Smart Account Omissions:** Automatically filters out hidden data strings for expansions your account does not yet own.
* **LibDataBroker & LibDBIcon Native Support:** Includes a minimal, togglable minimap icon that integrates seamlessly into modern bar layouts (Titan Panel, ElvUI).
* **Slash Command Control:** Clear variables on the fly using `/kd` or hide the button using `/kd toggle`.
* **Zero Dependencies:** Fully embedded structure works out of the box for non-developer installations.

## ⚙️ Installation
1. Download the latest release repository bundle.
2. Unzip and drop the folder structure into your game folder:
   `World of Warcraft/_retail_/Interface/AddOns/KnowledgeDump/`
3. Launch the game client!

## 🤝 Credits & Acknowledgments
* Data arrays and tracker limits inspired by the excellent catch-up mapping tables found in the `WeeklyKnowledge` addon by **Liquidor / DennisRas**.
* Architecture guidelines, WoWAce integration frameworks, database persistence protocols, and modern web-resolvable XML schemas designed in collaboration with **Gemini, an AI Collaborator by Google**.
