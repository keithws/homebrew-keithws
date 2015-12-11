require 'formula'

class Php < Formula
  url 'http://us.php.net/distributions/php-5.6.16.tar.bz2'
  homepage 'http://php.net/'
  sha256 '4fe6f40964c1bfaba05fc144ba20a2cdad33e11685f4f101ea5a48b98bbcd2ae'

  depends_on 'postgresql'

  def install
    # Not removing all pear.conf and .pearrc files from PHP path results in
    # the PHP configure not properly setting the pear binary to be installed
    File.delete "#{etc}/pear.conf" if File.exists? "#{etc}/pear.conf"
    File.delete "~/.pearrc" if File.exists? "~/.pearrc"

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
    args << "--with-fpm-user=nobody"
    args << "--with-fpm-group=nobody"

    # additions to match PROD
    # cURL is used to talk to other HTTP APIs like GeoLearning and DemandBase
    args << "--with-curl"

    # multi byte strings are used for foreign languages
    args << "--enable-mbstring"

    # openssl is used to make secure HTTPS API calls with cURL
    # includes StrictTransport by default in cURL

    # because who doesn't want Perl compatible regular expressions
    args << "--with-pcre-regex"

    # need SOAP to talk to SOA
    args << "--enable-soap"

    # compress config files into an attachment in info action
    # (otherwise unknown)
    args << "--with-zlib=/usr"

    # additions to match PROD but with unknown use cases
    # args << "--enable-bcmath" # unknown use case
    # args << "--enable-calendar" # unknown use case
    # args << "--with-mysql" # unknown use case
    # args << "--with-mysqlnd" # deprecated
    # args << "--enable-shmop" # unknown use case
    # args << "--with-snmp" # unknown use case
    # args << "--enable-sockets" # unknown use case
    # args << "--enable-sysvmsg" # unknown use case
    # args << "--enable-sysvsem" # unknown use case
    # args << "--enable-sysvshm" # unknown use case

    # additions to meet Quazam dependancies
    args << "--enable-pcntl"
    args << "--enable-zip"
    args << "--with-config-file-scan-dir=#{etc}/php.d"
    args << "--with-ldap-sasl"
    args << "--with-ldap=shared"
    args << "--with-pdo-pgsql=shared,#{Formula.factory("postgresql").prefix}"

    # configure, make, and install
    system "./configure", *args
    system "make"
    system "make install"

    etc.install "./php.ini-development" => "php.ini" unless File.exists? etc + "php.ini"
  end

  def caveats; <<-EOS.undent
    The php.ini file can be found in:
      #{etc}/php.ini

    EOS
  end

  def test
    system "php -r 'echo \"Testing PHP execution on \" . date('r') . \"\\n\";'"
  end
end

