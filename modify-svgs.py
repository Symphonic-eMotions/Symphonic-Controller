import os
from xml.etree import ElementTree as ET

def adjust_viewbox_and_save(input_dir, padding=10):
    for filename in os.listdir(input_dir):
        if filename.endswith(".svg"):
            file_path = os.path.join(input_dir, filename)
            tree = ET.parse(file_path)
            root = tree.getroot()
            viewBox = root.get('viewBox')
            if viewBox:
                values = list(map(float, viewBox.split()))
                # Pas de viewBox waarden aan om padding toe te voegen
                values[0] -= padding
                values[1] -= padding
                values[2] += 2 * padding
                values[3] += 2 * padding
                root.set('viewBox', ' '.join(map(str, values)))
                
                # Pas de breedte en hoogte aan, indien aanwezig
                width = root.get('width')
                height = root.get('height')
                if width and height:
                    root.set('width', str(float(width) + 2 * padding))
                    root.set('height', str(float(height) + 2 * padding))
                
                # Sla het aangepaste bestand op
                tree.write(file_path, encoding='utf-8', xml_declaration=True)

# Pas dit aan naar je input map
input_dir = '/Users/fjw/Desktop/SVGView/modify'
adjust_viewbox_and_save(input_dir)
