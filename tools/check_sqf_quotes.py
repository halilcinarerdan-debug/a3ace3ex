#!/usr/bin/env python3
"""SQF / config dosyalarinda kacissiz cift tirnak (dize icine "..." yazilmasi) sezgisel denetimi.

Bu hata dosyayi DERLENMEZ yapar: islev tanimsiz kalir, CBA ayarlari kaydolmaz, XEH_preInit yarida kesilir.
Kural: kapanan tirnagi hemen bir harf izliyorsa ya da acilan tirnak hemen bir harf / rakamdan sonra geliyorsa
(ornek: "... nisan "kilitlenebilir" (...") isaretlenir. Dize icinde tirnak gerekiyorsa tek tirnak ('...') kullan.

Kullanim:  python3 tools/check_sqf_quotes.py            (cikis kodu 1 = sorun var)
"""
import glob
import sys


def scan(path):
    s = open(path, encoding="utf-8").read()
    i, n, line, out = 0, len(s), 1, []
    while i < n:
        c = s[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        if s.startswith("//", i):
            while i < n and s[i] != "\n":
                i += 1
            continue
        if s.startswith("/*", i):
            j = s.index("*/", i + 2)
            line += s.count("\n", i, j)
            i = j + 2
            continue
        if c == "'":
            j = i + 1
            while j < n and not (s[j] == "'" and not (j + 1 < n and s[j + 1] == "'")):
                if s[j] == "\n":
                    line += 1
                j += 1
            i = j + 1
            continue
        if c == '"':
            st = line
            if i > 0 and (s[i - 1].isalnum() or s[i - 1] == "_"):
                out.append((st, "acilan tirnak harfe bitisik"))
            j = i + 1
            while j < n:
                if s[j] == '"':
                    if j + 1 < n and s[j + 1] == '"':
                        j += 2
                        continue
                    break
                if s[j] == "\n":
                    line += 1
                j += 1
            if j + 1 < n and (s[j + 1].isalpha() or s[j + 1] == "_"):
                out.append((st, "kapanan tirnagi harf izliyor"))
            i = j + 1
            continue
        i += 1
    return out


bad = False
for ext in ("sqf", "hpp", "cpp"):
    for p in sorted(glob.glob("addons/**/*." + ext, recursive=True)):
        for ln, msg in scan(p):
            print("%s:%d: %s" % (p, ln, msg))
            bad = True

print("SORUN VAR" if bad else "temiz")
sys.exit(1 if bad else 0)
