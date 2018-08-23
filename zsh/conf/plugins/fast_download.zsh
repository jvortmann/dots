# vim: ft=zsh

fast_download() {
  for url in $@; do
    aria2c -j 16 -s 16 -x 16 --file-allocation=none -c $url
  done
}
