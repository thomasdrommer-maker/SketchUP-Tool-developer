"""Reproduzierbarer RBZ-Bau: python scripts/build.py (Python 3, Standardbibliothek)."""
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED
import hashlib
ROOT = Path(__file__).resolve().parents[1]
files = sorted(p for p in (ROOT / 'src').rglob('*') if p.is_file())
output = ROOT / 'downloads' / 'SU_Productivity_Tools_v0.3.3_dev01.rbz'
output.parent.mkdir(exist_ok=True)
with ZipFile(output, 'w', compression=ZIP_DEFLATED) as archive:
    for source in files:
        info = ZipInfo(source.relative_to(ROOT / 'src').as_posix(), (2026, 11, 18, 0, 0, 0))
        info.compress_type = ZIP_DEFLATED
        info.external_attr = 0o100644 << 16
        archive.writestr(info, source.read_bytes())
with ZipFile(output) as archive:
    assert archive.testzip() is None
    assert 'td_productivity_tools.rb' in archive.namelist()
    assert all(name == 'td_productivity_tools.rb' or name.startswith('td_productivity_tools/') for name in archive.namelist())
    assert all(archive.read(p.relative_to(ROOT / 'src').as_posix()) == p.read_bytes() for p in files)
digest = hashlib.sha256(output.read_bytes()).hexdigest()
output.with_suffix('.rbz.sha256').write_text(f'{digest}  {output.name}\n', encoding='utf-8')
print(f'{output.name}: {len(files)} Dateien; SHA-256 {digest}')
