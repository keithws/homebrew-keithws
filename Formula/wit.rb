require 'formula'

class Wit < Formula
  url 'http://wit.wiimm.de/download/wit-v2.24a-r4723-mac.tar.gz'
  sha1 '57f1eb2973aa0fdd27e67b11e8dd3a1c54a38e7a'
  version '2.24a'
  homepage 'http://wit.wiimm.de/'

  def install
    bin.install 'bin/wdf'
    bin.install 'bin/wdf-cat'
    bin.install 'bin/wdf-dump'
    bin.install 'bin/wfuse'
    bin.install 'bin/wit'
    bin.install 'bin/wwt'
    mv 'share', 'wit'
    share.install 'wit'
  end
end
