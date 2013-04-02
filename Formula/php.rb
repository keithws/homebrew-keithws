require 'formula'

class Php < Formula
  url 'http://us.php.net/distributions/php-5.4.13.tar.bz2'
  homepage 'http://php.net/'
  sha1 '5c229046b5f1d5c1dcd8df6e9cb388aa11504236'

  depends_on 'gettext'
  depends_on 'jpeg'
  depends_on 'libxml2' unless MacOS.version >= :mountain_lion
  depends_on 'mcrypt'

  # required to find freetype
  depends_on :x11

  def install
    ENV.deparallelize
    ENV.no_optimization

    args = [
      "--disable-debug",
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--infodir=#{share}/info",
      "--sysconfdir=#{etc}",
      "--with-config-file-path=#{etc}",
    ]

    # Enable PHP FPM
    args << "--enable-fpm"
    args << "--with-fpm-user=kshaw"
    args << "--with-fpm-group=kshaw"

    # options to match corpweb'
    args << "--with-curl"
    args << "--with-gd"
    args << "--with-jpeg-dir=#{Formula.factory('jpeg').prefix}" # required by gd
    args << "--with-png-dir=/opt/X11" # required by gd
    args << "--with-zlib" # required by png
    args << "--with-gettext=#{Formula.factory('gettext').prefix}"
    args << "--enable-mbstring"
    # args << "--enable-mbregex"
    args << "--with-openssl"
    # args << "--enable-dba=shared --with-gdbm --with-cdb --with-cdb_make --with-inifile --with-flatfile" # not used as of 2012-05-16
    # args << "--enable-shmop" # not used as of 2012-05-16
    # args << "--enable-sysvsem" # not used as of 2012-05-16
    # args << "--enable-sysvshm" # not used as of 2012-05-16

    # additions for Yii
    args << "--with-pdo-pgsql=#{Formula.factory('postgresql').prefix}"
    args << "--with-mcrypt=#{Formula.factory('mcrypt').prefix}"
    args << "--with-freetype-dir=/opt/X11"
    args << "--enable-gd-native-ttf"
    args << "--enable-soap"

    # additions for Quazam
    args << "--with-ldap"
    args << "--with-ldap-sasl"

    # Use libedit instead of readline for php 5.4 (recommend by Jose Gonzalez)
    args << "--with-libedit"

    # options of unknown orgin (not on corpweb)
    # args << "--enable-bcmath"
    # args << "--with-bz2"
    # args << "--enable-calendar"
    # args << "--enable-exif"
    # args << "--enable-ftp"
    # args << "--with-iodbc"
    # args << "--with-snmp"
    # args << "--enable-sockets"
    # args << "--enable-sysvmsg"
    # args << "--enable-wddx"
    # args << "--with-xmlrpc"
    # args << "--with-xsl"
    # args << "--enable-zip"

    # options of unknown orgin (that match corpweb)
    # args << "--with-libxml-dir"
    # args << "--with-kerberos"
    # args << "--with-iconv"
    # args << "--with-pcre-regex"

    # configure, make, and install
    system "./configure", *args
    system "make"
    system "make install"

    etc.install "./php.ini-development" => "php.ini" unless File.exists? etc+"php.ini"

    # fix the default PEAR permissions and config
    # chmod_R 0775, lib+"php"
    # system bin+"pear", "config-set", "php_ini", etc+"php.ini"
  end

  def caveats; <<-EOS.undent
    The php.ini file can be found in:
      #{etc}/php.ini

    You'll also need to reinstall packages built against php like:
      brew uninstall php-apc php-svn
      brew install php-apc php-svn
    EOS
  end

  def test
    system "php --version | grep 'PHP #{version}'"
  end
end
