import os
import json

def update_json_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
        
        modified = False  # Voeg een vlag toe om bij te houden of het bestand gewijzigd is
        
        # Navigeer door de structuur zoals benodigd om je waarden te vinden en bij te werken
        for instrument in data.get("instrumentsConfig", []):
            for part in instrument.get("instrumentParts", []):
                node_settings = part.get("damperTarget", {}).get("nodeSettings", {})
                if "rampSpeed" in node_settings and node_settings["rampSpeed"] != 0.79:
                    node_settings["rampSpeed"] = 0.79
                    modified = True
                if "rampSpeedDown" in node_settings and node_settings["rampSpeedDown"] != 0.79:
                    node_settings["rampSpeedDown"] = 0.79
                    modified = True

    if modified:  # Controleer of het bestand gewijzigd is
        # Sla de aangepaste data op in hetzelfde bestand
        with open(file_path, 'w', encoding='utf-8') as file:
            json.dump(data, file, ensure_ascii=False, indent=2)
        print(f"Bestand bijgewerkt: {file_path}")  # Print de naam van het bijgewerkte bestand

def update_directory(directory_path):
    for root, dirs, files in os.walk(directory_path):
        for file in files:
            if file.endswith('.json'):
                update_json_file(os.path.join(root, file))

# Vervang '/pad/naar/jouw/map' met het werkelijke pad naar de map met je JSON-bestanden
directory_path = 'Symphonic eMotions/Source/Sets'
update_directory(directory_path)

print("Klaar met bijwerken van JSON bestanden.")
