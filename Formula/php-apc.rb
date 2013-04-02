require 'formula'

class PhpApc < Formula
  homepage 'http://pecl.php.net/package/apc'
  url 'http://pecl.php.net/get/APC-3.1.9.tgz'
  sha1 '417b95e63496de7f785b4917166098c6ac996008'
  head 'http://pecl.php.net/get/APC'

  depends_on 'autoconf' => :build
  depends_on 'php'

  def install
    if not build.head?
      Dir.chdir "APC-#{version}"
    end

    system "phpize"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    prefix.install 'modules/apc.so'
  end

  def caveats; <<-EOS.undent
     To finish installing apc-php:
       * Add the following line to #{etc}/php.ini:
         [example]
         extension="#{prefix}/apc.so"
       * Restart your webserver.
       * Write a PHP page that calls "phpinfo();"
       * Load it in a browser and look for the info on the example module.
       * If you see it, you have been successful!
     EOS
  end
end