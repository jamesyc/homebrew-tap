class Acp < Formula
  include Language::Python::Virtualenv

  desc "AirPyrt Tools for Apple AirPort and Time Capsule ACP"
  homepage "https://github.com/jamesyc/airpyrt-tools"
  url "https://github.com/jamesyc/airpyrt-tools/releases/download/v1.0.0/acp-1.0.0.tar.gz"
  sha256 "2aecae1c546c968d6ec62b19cd6d1e43b3958faa7b8fb4a9336ef4a5bcc48f03"
  license "MIT"

  depends_on "python@3.14"

  resource "pycryptodomex" do
    url "https://files.pythonhosted.org/packages/c9/85/e24bf90972a30b0fcd16c73009add1d7d7cd9140c2498a68252028899e41/pycryptodomex-3.23.0.tar.gz"
    sha256 "71909758f010c82bc99b0abf4ea12012c98962fbf0583c2164f8b84533c2e4da"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage: acp", shell_output("#{bin}/acp --help")
    assert_match "Supported properties", shell_output("#{bin}/acp --listprop")
  end
end
