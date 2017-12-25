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
plugins = [ x for x in os.environ.get('GDB_PLUGINS', '').split(':') if x ]
framework = next(x for x in plugins if x in ['gef', 'peda', 'pwndbg'])
if framework == 'gef':
    gdb.execute('gef')
elif framework == 'peda':
    gdb.execute('peda')
elif framework == 'pwndbg':
    gdb.execute('pwndbg')
del plugins, framework
end
