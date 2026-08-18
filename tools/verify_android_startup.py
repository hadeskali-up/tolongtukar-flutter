#!/usr/bin/env python
"""Fail when the launch activity declared by an APK is absent from its DEX."""
from pathlib import Path
import sys
from loguru import logger
logger.remove()
from androguard.core.apk import APK
from androguard.core.dex import DEX

apk_path = Path(sys.argv[1])
apk = APK(str(apk_path))
package = apk.get_package()
main = apk.get_main_activity()
classes = set()
for dex_blob in apk.get_all_dex():
    dex = DEX(dex_blob)
    classes.update(cls.get_name() for cls in dex.get_classes())
descriptor = 'L' + main.replace('.', '/') + ';'
print(f'package={package}')
print(f'main_activity={main}')
print(f'main_descriptor={descriptor}')
print(f'main_class_in_dex={descriptor in classes}')
for candidate in sorted(c for c in classes if 'MainActivity' in c):
    print(f'dex_main_candidate={candidate}')
if descriptor not in classes:
    raise SystemExit(f'Launch activity {main} is missing from DEX')
