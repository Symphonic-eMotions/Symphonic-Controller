import os
import json

def update_json_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)
        
        # Controleer of 'smootherVersion' bestaat in het hoofdniveau van de JSON-structuur
        if "smootherVersion" in data:
            del data["smootherVersion"]  # Verwijder 'smootherVersion'
            # Sla de aangepaste data op in hetzelfde bestand
            with open(file_path, 'w', encoding='utf-8') as file:
                json.dump(data, file, ensure_ascii=False, indent=2)
            print(f"Bestand bijgewerkt: {file_path}")  # Print de naam van het bijgewerkte bestand

def update_directory(directory_path):
    for root, dirs, files in os.walk(directory_path):
        for file in files:
            if file.endswith('.json'):
                update_json_file(os.path.join(root, file))

# Vervang 'Symphonic eMotions/Source/Sets' met het werkelijke pad naar de map met je JSON-bestanden
directory_path = 'Symphonic eMotions/Source/Sets'
update_directory(directory_path)

print("Klaar met bijwerken van JSON bestanden.")
