require "formula"

# Documentation: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Zfs < Formula
  homepage "https://github.com/zfs-osx/zfs"
  head "https://github.com/zfs-osx/zfs.git"

  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "spl"

  def fixInstallPaths
    files = ["Makefile.am", "include/Makefile.am", "include/linux/Makefile.am", "include/sys/Makefile.am", "include/sys/fm/Makefile.am", "include/sys/fm/fs/Makefile.am", "include/sys/fs/Makefile.am"]
    
    files.each do |file|
      inreplace "#{file}", "/usr/src/zfs-", "#{prefix}/src/zfs-"
    end
    
    inreplace "module/zfs/Makefile.am" do |s|
      s.gsub! "@KERNEL_MODPREFIX@", "#{kext_prefix}"
      s.gsub! "chown -R root:wheel", "chown -R keithws:staff"
    end
    
    inreplace "cmd/mount_zfs/Makefile.am", "/sbin", "#{prefix}/sbin"
    inreplace "config/user-systemd.m4", "/usr/lib", "#{prefix}/lib"
  end

  def install
    fixInstallPaths
    
    # zfs requires a configured copy of the full SPL source
    configureSpl

    system "./autogen.sh"

    system "./configure", "CC=clang", "CXX=clang++", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--with-spl=#{getwd}/spl--git",
                          "--prefix=#{prefix}",
                          "--oldincludedir=#{prefix}/include"
    system "make"
    system "make install"
  end

  def configureSpl
    system "git clone https://github.com/zfs-osx/spl.git spl--git"
    cd "spl--git"
    system "./autogen.sh"
    system "./configure CC=clang CXX=clang++ --prefix=#{HOMEBREW_PREFIX}/Cellar/spl/HEAD"
    cd ".."
  end

  def caveats
    return <<-EOS.undent
      If upgrading from a previous version of ZFS, the old kernel extensions
      will need to be unloaded before performing the steps listed below. First,
      check if ZFS filesystems are mounted:

        mount -t zfs

      Unmount all ZFS filesystems and then unload the kernel extensions:

        sudo kextunload -b net.lundman.zfs

      In order for ZFS to work, the ZFS kernel extension
      must be installed and loaded by the root user:

        sudo rsync -ar --delete #{kext_prefix}/zfs.kext /System/Library/Extensions
        sudo chown -R root:wheel /System/Library/Extensions/zfs.kext
        sudo kextload -r /System/Library/Extensions/ -v /System/Library/Extensions/zfs.kext

    EOS
  end
  
  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test zfs`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
