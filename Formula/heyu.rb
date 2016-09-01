require 'formula'

class Heyu < Formula
  homepage 'http://www.heyu.org/'
  url 'http://www.heyu.org/download/heyu-2.10.tar.gz'
  sha256 'ac8127fb412ce1bdb88e70960aba6d33617092af6579e95abde33993040d7feb'
  
  devel do
    url 'http://www.heyu.org/download/heyu-2.11-rc1.tar.gz'
    sha256 '97b49f0925194beb753f4549360ca12ef848c1022132b388b72009c36e1ff502'
  end
  
  # patch the configure script to respect the homebrew prefix
  # and to put the man files under the share directory
  # and install files as the current user (instead of as root)
  # and do not run the interactive install shell script
  def patches; DATA; end

  def install
    # stop the current running deamons
    # TODO only if heyu command available and running
    # system "heyu stop"

    system "sh ./Configure"

    system "make"
    
    bin.install "heyu"

    # manually do what the install.sh was trying todo
    # install a sample config files unless the config files already exist
    etc.install "x10config.sample" => "heyu/x10.conf" unless File.exists? etc+"heyu/x10.conf"
    etc.install "x10.sched.sample" => "heyu/x10.sched" unless File.exists? etc+"heyu/x10.sched"

    # create spool and lock directories with the correct permissions
    # when necessary
    spool = "/usr/local/var/tmp/heyu"
    lock = "/usr/local/var/spool/lock"
    FileUtils.mkdir_p(spool, :mode => 777) unless File.exists? spool
    FileUtils.mkdir_p(lock, :mode => 1777) unless File.exists? lock
  end

  def caveats;  <<-EOS.undent

    Note: If you're upgrading from a previous version of Heyu, run 'heyu stop'
    under that version before proceeding.

    EOS
  end

  def test
    system "heyu info"
  end
end
__END__
diff --git a/Configure b/Configure
index fc3204a..c824dc6 100755
--- a/Configure
+++ b/Configure
@@ -31,9 +31,9 @@ EoF

 # paths:
 cat >> Makefile <<EoF
-BIN = /usr/local/bin
-MAN = /usr/local/man/man1
-MAN5 = /usr/local/man/man5
+BIN = HOMEBREW_PREFIX/bin
+MAN = HOMEBREW_PREFIX/share/man/man1
+MAN5 = HOMEBREW_PREFIX/share/man/man5

 #       set DFLAGS equal to:
 #          -DSYSV       if using SYSTEM V
@@ -250,9 +250,9 @@ EoF
 	;;
     darwin)
 	cat >> Makefile <<-EoF
-	OWNER = root
-	GROUP = wheel
-	DFLAGS = -DPOSIX -DDARWIN -DHASSELECT $CM17AFLAG $EXT0FLAG $RFXSENFLAG $RFXMETFLAG $DMXFLAG $OREFLAG $KAKUFLAG $FLAGS_FLAG $TIMERS_FLAG $COUNTERS_FLAG
+	OWNER = `whoami`
+	GROUP = `groups | awk '//{print $1}'`
+	DFLAGS = -DPOSIX -DDARWIN -DHASSELECT -DLOCKDIR=\"HOMEBREW_PREFIX/var/spool/lock\" -DSYSBASEDIR=\"HOMEBREW_PREFIX/etc/heyu\" -DSPOOLDIR=\"HOMEBREW_PREFIX/var/tmp/heyu\" $CM17AFLAG $EXT0FLAG $RFXSENFLAG $RFXMETFLAG $DMXFLAG $OREFLAG $KAKUFLAG $FLAGS_FLAG $TIMERS_FLAG $COUNTERS_FLAG
 	CC = gcc
 	CFLAGS = -g -O \$(DFLAGS) -Wall
 	LIBS = -lm -lc
diff --git a/Makefile.in b/Makefile.in
index 84ea379..227b65b 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -47,8 +47,6 @@ heyu:	$(OBJS) version.h
 	@echo `id` >usergroup.tmp
 	@echo ${HOME}  >userhome.tmp
 	@echo ""
-	@echo "** Now become root and run 'make install' **"
-	@echo ""

 $(OBJS): x10.h process.h sun.h Makefile

@@ -93,7 +91,6 @@ $(BIN)/heyu:	heyu
 	chgrp $(GROUP) $(BIN)/heyu
 	chmod 755 $(BIN)/heyu
 	chown $(OWNER) $(BIN)/heyu
-	./install.sh

 $(MAN)/heyu.1: heyu.1
 	mkdir -p -m 755 $(MAN)
