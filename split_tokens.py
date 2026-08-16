import os

with open('lib/tokens.dart', 'r') as f:
    content = f.read()
    lines = content.splitlines(keepends=True)

shared_imports = "import 'package:flutter/material.dart';\nimport 'package:google_fonts/google_fonts.dart';\nimport 'package:remixicon/remixicon.dart';\n\n"

# Create ds_icons.dart (lines 1-306)
with open('lib/ds_icons.dart', 'w') as f:
    f.write(shared_imports)
    f.writelines(lines[4:306])

# Create ds_colors.dart (lines 308-428)
with open('lib/ds_colors.dart', 'w') as f:
    f.write(shared_imports)
    f.writelines(lines[307:428])

# Create ds_typography.dart (lines 430-504)
with open('lib/ds_typography.dart', 'w') as f:
    f.write(shared_imports)
    f.writelines(lines[429:504])

# Create ds_geometry.dart (lines 506-732)
with open('lib/ds_geometry.dart', 'w') as f:
    f.write(shared_imports)
    f.writelines(lines[505:732])

# Create ds_foundation.dart (lines 648-863)
with open('lib/ds_foundation.dart', 'w') as f:
    f.write(shared_imports)
    f.writelines(lines[647:863])

print('Files created successfully')
print(f'Tokens file has {len(lines)} lines')
for i, fname in enumerate(['ds_icons.dart', 'ds_colors.dart', 'ds_typography.dart', 'ds_geometry.dart', 'ds_foundation.dart']):
    fpath = f'lib/{fname}'
    if os.path.exists(fpath):
        with open(fpath) as f2:
            print(f'{fname}: {len(f2.read().splitlines())} lines')
