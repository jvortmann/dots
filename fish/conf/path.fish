# add basher to path when present
if test -d ~/.basher
  set basher ~/.basher/bin
end

set -gx PATH $basher $PATH
