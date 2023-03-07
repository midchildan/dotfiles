set print pretty on
set pagination off

define gef
  source ~/.local/opt/gef/gef.py
end

define peda
  source ~/.local/opt/peda/peda.py
end

python
import os
plugins = [ x for x in os.environ.get('GDB_PLUGINS', '').split(':') if x ]
framework = next(x for x in plugins if x in ['gef', 'peda'])
if framework == 'gef':
    gdb.execute('gef')
elif framework == 'peda':
    gdb.execute('peda')
del plugins, framework
end
