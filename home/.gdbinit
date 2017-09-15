define gef
  source ~/.local/opt/gef/gef.py
end

define peda
  source ~/.local/opt/peda/peda.py
end

define pwndbg
  source ~/.local/opt/pwndbg/gdbinit.py
end

python
import os
use_gef = os.environ.get('GDB_USE_GEF', 0)
use_peda = os.environ.get('GDB_USE_PEDA', 0)
use_pwndbg = os.environ.get('GDB_USE_PWNDBG', 0)
gdb.execute('set $USE_GEF = {}'.format(use_gef))
gdb.execute('set $USE_PEDA = {}'.format(use_peda))
gdb.execute('set $USE_PWNDBG = {}'.format(use_pwndbg))
del use_gef, use_peda, use_pwndbg
end

if $USE_GEF == 1
  gef
end
if $USE_PEDA == 1
  peda
end
if $USE_PWNDBG == 1
  pwndbg
end
