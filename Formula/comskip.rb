require 'formula'

class Comskip < Formula
  homepage 'http://www.kaashoek.com/comskip/'
  head 'https://github.com/erikkaashoek/Comskip.git'

  # TODO find a tar ball that works or make my own
  # url 'https://github.com/erikkaashoek/Comskip/archive/v0.81.089.tar.gz'
  # sha256 'f66e6c534a65766bf8f67191a688c1df4a1d1610c3dbff59e39b552ac45f8eb8'

  option "without-donator", "Build without donator features"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconfig" => :build
  depends_on "argtable"
  depends_on "ffmpeg"
  depends_on "sdl" => :optional

  # only offical place I found to get an INI file
  resource "additional_files" do
    url "http://www.kaashoek.com/files/comskip81_092.zip"
    sha256 "71e8b9458c7dc1237faed9d48e3c2790df08071351d83e02cc3627db04e92c68"
  end

  def install

    if build.head?
      system "./autogen.sh"
    end

    args = [
      #"CC=gcc",
      #"CXX=g++",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
    ]

    if build.without? "donator"
      args << "--disable-donator"
    end

    system "./configure", *args
    system "make"
    bin.install 'comskip'

    # download sample config file
    resource("additional_files").stage { etc.install "comskip.ini" => "comskip.ini" unless File.exists? etc+"comskip.ini" }

  end

  def test
    system "comskip"
  end
end
