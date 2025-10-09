#!/usr/bin/env python3

# 读取所有定义的字符串
defined_strings = set()
with open('/Users/arkobot/Desktop/git/flutter-3/lib/l10n/app_strings.dart', 'r') as f:
    for line in f:
        if 'static const String' in line:
            # 提取字符串名称
            parts = line.split()
            for i, part in enumerate(parts):
                if part == 'String' and i + 1 < len(parts):
                    name = parts[i + 1].rstrip('=')
                    defined_strings.add(name)

# 读取所有使用的字符串
used_strings = set()
with open('/tmp/used_strings.txt', 'r') as f:
    for line in f:
        line = line.strip()
        if line.startswith('AppStrings.'):
            name = line.split('.')[1]
            used_strings.add(name)

# 找出未使用的字符串
unused_strings = defined_strings - used_strings

print("未使用的字符串:")
for string in sorted(unused_strings):
    print(f"  {string}")

print(f"\n总共定义了 {len(defined_strings)} 个字符串")
print(f"使用了 {len(used_strings)} 个字符串")
print(f"未使用 {len(unused_strings)} 个字符串")
