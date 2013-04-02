require 'formula'

class Wit < Formula
  url 'http://wit.wiimm.de/download/wit-v2.13a-r4298-mac.tar.gz'
  sha1 'deb2d7b4daaadab9e096799d428627bcb64b53f7'
  version '2.13a'
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
