require 'formula'

class PhpSvn < Formula
  homepage 'http://pecl.php.net/package/svn'
  url 'http://pecl.php.net/get/svn-1.0.2.tgz'
  sha1 '32c3da0844f04921482225d01e8eaf7acfcf0e94'
  head 'http://pecl.php.net/get/svn'

  depends_on 'autoconf' => :build
  depends_on 'subversion'
  depends_on 'php'

  def modules
    prefix+'lib/php/modules'
  end

  def install
    if not build.head?
      Dir.chdir "svn-#{version}"
    end

    system "phpize"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    modules.install 'modules/svn.so'
  end

  def caveats; <<-EOS.undent
     To finish installing svn-php:
       * Add the following line to #{etc}/php.ini:
         [example]
         extension="#{modules}/svn.so"
       * Restart your webserver.
       * Write a PHP page that calls "phpinfo();"
       * Load it in a browser and look for the info on the example module.
       * If you see it, you have been successful!
     EOS
  end

  def test
    system "php --modules | grep svn"
  end
end
