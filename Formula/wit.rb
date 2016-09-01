require 'formula'

class Wit < Formula
  url 'http://wit.wiimm.de/download/wit-v2.24a-r4723-mac.tar.gz'
  sha256 'f875dce5904ebb99c6197662272d016e1fd45502a079ee5005083d339074ef3d'
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
