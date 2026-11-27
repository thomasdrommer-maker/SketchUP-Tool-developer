"""Standalone package integrity check; no SketchUp runtime claims."""
from pathlib import Path
from zipfile import ZipFile
import hashlib
ROOT=Path(__file__).resolve().parents[1]
p=ROOT.parents[1]/'downloads/SU_GFA_BSV_Creator_v0.1.0_dev03.rbz'
with ZipFile(p) as z:
    assert z.testzip() is None
    assert {n.split('/')[0] for n in z.namelist()} == {'td_gfa_bsv_creator.rb','td_gfa_bsv_creator'}
    files={f.relative_to(ROOT/'src').as_posix():f.read_bytes() for f in (ROOT/'src').rglob('*') if f.is_file()}
    assert set(files)==set(z.namelist())
    for name,data in files.items():
        assert data==z.read(name)
        if name.endswith(('.rb','.js','.html')):
            assert b'ProductivityTools' not in data and b'td_productivity_tools' not in data
    loader=z.read('td_gfa_bsv_creator.rb').decode()
    assert "SketchupExtension.new('GFA / BSV Creator', 'td_gfa_bsv_creator/main')" in loader
    assert "require_relative" not in loader
assert p.with_suffix('.rbz.sha256').read_text().split()[0] == hashlib.sha256(p.read_bytes()).hexdigest()
print('Standalone root, loader, source identity, dependency isolation, CRC and SHA-256: PASS')
