import os
import re

EMOJI_REPLACEMENTS = {
    # Badges / Crests
    '🛡️': 'SHIELD',
    '⚡': 'BOLT',
    '🦁': 'LION',
    '🦅': 'EAGLE',
    '🐯': 'TIGER',
    '⚓': 'ANCHOR',
    '⭐': 'STAR',
    '🌟': 'STAR',
    '🔥': 'FLAME',
    '👑': 'CROWN',
    '🏰': 'CASTLE',
    '💎': 'DIAMOND',
    '🐂': 'BULL',
    '⚔️': 'SWORDS',
    '🐴': 'PEGASUS',
    '☀️': 'SUN',
    '🐺': 'WOLF',
    '🐉': 'DRAGON',
    '🌙': 'CRESCENT',
    '🔴': '[KIRMIZI]',
    '🔵': '[MAVİ]',
    '🟡': '[SARI]',
    '🟢': '[YEŞİL]',
    '⚪': '[BEYAZ]',
    '🟣': '[MOR]',
    '🟠': '[TURUNCU]',
    
    # Common UI & Metas
    '⚽': '[GOL]',
    '💰': '[KASA]',
    '💵': '[TL]',
    '💸': '[FON]',
    '👥': '[TARAFTAR]',
    '👤': '[OYUNCU]',
    '👕': '[KADRO]',
    '🏛️': '[YÖNETİM]',
    '🏢': '[KULÜP]',
    '🏆': '[KUPA]',
    '💼': '[MENAJER]',
    '🎙️': '[BASIN]',
    '📺': '[TV]',
    '⚖️': '[HUKUK]',
    '🕵️': '[SCOUT]',
    '🔍': '[ARAMA]',
    '🏥': '[REVİR]',
    '🚑': '[SAĞLIK]',
    '🔨': '[İNŞAAT]',
    '🏗️': '[TESİS]',
    '⚠️': '[UYARI]',
    '✅': '[ONAY]',
    '❌': '[RED]',
    '🧠': '[AI]',
    '📈': '[ARTIS]',
    '📉': '[DUSUS]',
    '📋': '[RAPOR]',
    '🎫': '[BİLET]',
    '🤝': '[ANLASMA]',
    '🚌': '[OTOBUS]',
    '🗿': '[HEYKEL]',
    '🥇': '1.',
    '🥈': '2.',
    '🥉': '3.',
    '🥊': '[DUELLO]',
    '🚨': '[ACIL]',
    '💬': '[MESAJ]',
    '🎯': '[HEDEF]',
    '🚀': '[HUCUM]',
    '🎩': '[VIP]',
    '🎉': '[KUTLAMA]',
    '✨': '[ETKI]',
    '🔒': '[KILITLI]',
    '🔓': '[ACIK]',
    '🔑': '[ANAHTAR]',
    '📢': '[DUYURU]',
    '🗞️': '[HABER]',
    '📰': '[MANSET]',
    '⏱️': '[SURE]',
    '⏳': '[BEKLEME]',
    '📊': '[GRAFIK]',
    '📌': '[SABIT]',
    '📍': '[KONUM]',
    '🏷️': '[ETIKET]',
    '🎁': '[ODUL]',
    '🎖️': '[MADALYA]',
    '🩺': '[DOKTOR]',
    '💉': '[TEDAVI]',
    '💊': '[ILAC]',
    '🧨': '[PATLAMA]',
    '💣': '[RISK]',
    '🛑': '[DUR]',
    '⛔': '[YASAK]',
    '🚫': '[ENGEL]',
    '💯': '100',
    '👀': '[GOZ]',
    '🔥': '[FORM]',
    '👏': '[ALKIS]',
    '💪': '[GUC]',
    '🕶️': '[AJAN]',
    '🕵': '[SCOUT]',
}

# Regex to catch any remaining unicode emoji
EMOJI_PATTERN = re.compile(
    r'[\U00010000-\U0010ffff]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50]|[\u2B06]|[\u2194-\u21AA]|[\u200D]|[\uFE0F]'
)

TARGET_DIRS = ['lib', 'test']
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

total_replaced = 0
files_modified = 0

for target_dir in TARGET_DIRS:
    full_path = os.path.join(BASE_DIR, target_dir)
    for root, _, files in os.walk(full_path):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()

                new_content = content
                # 1. Apply explicit mappings
                for emoji, repl in EMOJI_REPLACEMENTS.items():
                    if emoji in new_content:
                        new_content = new_content.replace(emoji, repl)

                # 2. Cleanup any remaining unmatched unicode emojis
                def remove_unmatched(match):
                    return ''
                
                new_content = EMOJI_PATTERN.sub(remove_unmatched, new_content)

                if new_content != content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    files_modified += 1
                    print(f"Cleaned emojis from: {os.path.relpath(file_path, BASE_DIR)}")

print(f"\nDone! Modified {files_modified} files.")
