# સત્સંગ LT — iPad app (GitHub થી .ipa)

GitHub આ કોડને પોતાના Mac પર build કરીને **SatsangLT.ipa** ફાઇલ આપે છે.
એ .ipa ને AltStore થી iPad માં install કરવાની છે.

## ૧. satsang.html મૂકો
`SatsangLT` folder માં **satsang.html** મૂકો (વિગત: `satsang.html.અહીં_મૂકો.txt`).

## ૨. GitHub પર upload
1. github.com પર મફત account બનાવો.
2. ઉપર જમણે **+ → New repository** → નામ `SatsangLT` → **Private** પસંદ કરો → Create.
3. "uploading an existing file" link પર click કરો.
4. આ zip ખોલ્યા પછી અંદરનું **બધું** (`.github`, `SatsangLT`, `project.yml`, `README.md`) એકસાથે ખેંચીને મૂકો.
5. નીચે **Commit changes** દબાવો.

`.github` folder upload ન થયું હોય તો: **Add file → Create new file** → નામમાં
`.github/workflows/build-ipa.yml` લખો → zip માંની એ ફાઇલનું લખાણ paste કરો → Commit.

## ૩. .ipa download
1. repository માં ઉપર **Actions** tab.
2. ડાબે **"SatsangLT .ipa બનાવો"** → જમણે **Run workflow** (upload પછી આપોઆપ પણ ચાલે).
3. ૫–૧૦ મિનિટમાં લીલું ✔ આવે → એના પર click → નીચે **Artifacts** માં **SatsangLT-ipa** download.
4. એ zip ખોલો → અંદર **SatsangLT.ipa** મળશે.

લાલ ✖ આવે તો એનો screenshot મોકલજો.

## નવો ફેરફાર કરવો હોય ત્યારે
નવી satsang.html upload કરો (જૂની પર જ) → Commit → Actions ફરી આપોઆપ નવી .ipa બનાવશે.
