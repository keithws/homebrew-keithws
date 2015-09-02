require "formula"

class Spl < Formula
  homepage "https://github.com/zfs-osx/spl"
  head "https://github.com/zfs-osx/spl.git"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gawk" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "CC=clang", "CXX=clang++", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    kext_prefix.install "module/spl/spl.kext"
  end

  def caveats
    return <<-EOS.undent
      If upgrading from a previous version of SPL, the old kernel extension
      will need to be unloaded before performing the steps listed below.

        sudo kextunload -b net.lundman.spl

      In order for Solaris Portability Layer (SPL) to work, the SPL kernel extension
      must be installed and loaded by the root user:

        sudo rsync -ar --delete #{prefix}/Library/Extensions/spl.kext /System/Library/Extensions
        sudo chown -R root:wheel /System/Library/Extensions/spl.kext
        sudo kextload -r /System/Library/Extensions/ -v /System/Library/Extensions/spl.kext

    EOS
  end
  
  test do
    system "false"
  end
end
