filepath = r"lib/core/widgets/astra_fill_display.dart"
content = open(filepath, 'r', encoding='utf-8').read()

# Replace Colors.AyurezeTheme.*
content = content.replace("Colors.AyurezeTheme.warning", "AyurezeTheme.warning")
content = content.replace("Colors.AyurezeTheme.healingGreen50.shade50", "AyurezeTheme.healingGreen10")
content = content.replace("Colors.AyurezeTheme.healingGreen50.shade700", "AyurezeTheme.healingGreen100")
content = content.replace("Colors.AyurezeTheme.healingGreen50", "AyurezeTheme.healingGreen50")
content = content.replace("Colors.AyurezeTheme.danger", "AyurezeTheme.danger")

# Replace purple as a variable
content = content.replace("color: purple", "color: AyurezeTheme.purple")
content = content.replace("[purple", "[AyurezeTheme.purple")
content = content.replace("purple.withOpacity", "AyurezeTheme.purple.withOpacity")

open(filepath, 'w', encoding='utf-8').write(content)
print("Done fixing astra_fill_display.dart!")
