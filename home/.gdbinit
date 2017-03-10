define peda
  source ~/.local/opt/peda/peda.py
end

define pwndbg
  source ~/.local/opt/pwndbg/gdbinit.py
end

python
import os
use_peda = os.environ.get('GDB_USE_PEDA', 0)
use_pwndbg = os.environ.get('GDB_USE_PWNDBG', 0)
gdb.execute('set $USE_PEDA = {}'.format(use_peda))
gdb.execute('set $USE_PWNDBG = {}'.format(use_pwndbg))
del use_peda, use_pwndbg
end

if $USE_PEDA == 1
  peda
end
if $USE_PWNDBG == 1
  pwndbg
end
