class Canonshuttercount < Formula
  include Language::Python::Virtualenv

  desc "Read the original Canon EOS 5D shutter count over USB"
  homepage "https://github.com/jamesyc/CanonShutterCount"
  url "https://github.com/jamesyc/CanonShutterCount/releases/download/v0.1.0/canonshuttercount-0.1.0.tar.gz"
  sha256 "1552c1b07b6985067dce04e699de0018e820fd8e2184415aebe22d8f6cae9193"
  license "GPL-3.0-only"

  depends_on "python-setuptools" => :build
  depends_on "libusb"
  depends_on "python@3.14"

  resource "pyusb" do
    url "https://files.pythonhosted.org/packages/00/6b/ce3727395e52b7b76dfcf0c665e37d223b680b9becc60710d4bc08b7b7cb/pyusb-1.3.1.tar.gz"
    sha256 "3af070b607467c1c164f49d5b0caabe8ac78dbed9298d703a8dbf9df4052d17e"
  end

  def install
    venv = virtualenv_create(libexec, "python3.14")
    venv.pip_install resources, build_isolation: false
    venv.pip_install buildpath, build_isolation: false
    (bin/"canonshuttercount").write_env_script libexec/"bin/canonshuttercount",
      CANONSHUTTERCOUNT_LIBUSB: formula_opt_lib("libusb")/shared_library("libusb-1.0")
    doc.install "src/canonshuttercount/OWNER_RECOVERY.md"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/canonshuttercount --version").strip
    (testpath/"counter.bin").binwrite ["ffffff557305fd190a3c56002cdffef2ff24fcfff2ffffff"].pack("H*")
    result = shell_output("#{bin}/canonshuttercount --decode #{testpath}/counter.bin --json")
    assert_equal 11300, JSON.parse(result).fetch("shutter_count")
    assert_path_exists doc/"OWNER_RECOVERY.md"

    ENV["CANONSHUTTERCOUNT_LIBUSB"] = formula_opt_lib("libusb")/shared_library("libusb-1.0")
    system libexec/"bin/python", "-c", <<~PYTHON
      from importlib.resources import files
      from canonshuttercount.transport import USBBus
      assert USBBus().backend is not None
      assert files("canonshuttercount").joinpath("OWNER_RECOVERY.md").is_file()
    PYTHON
  end
end
