require "formula"

# Documentation: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Spl < Formula
  homepage "https://github.com/zfs-osx/spl"
  head "https://github.com/zfs-osx/spl.git"

  depends_on "automake" => :build
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
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test spl`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
