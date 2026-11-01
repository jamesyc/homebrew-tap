class Tcapsule < Formula
  include Language::Python::Virtualenv

  desc "Install Samba 4 on Apple Time Capsules and AirPort Extremes"
  homepage "https://github.com/jamesyc/TimeCapsuleSMB"
  url "https://github.com/jamesyc/TimeCapsuleSMB/archive/refs/tags/v3.8.1.tar.gz"
  sha256 "486778b0db548e15a4ad732e62a004a1a0f83e86667b2b145d9f27a7a3a7322b"
  license "GPL-3.0-only"

  depends_on arch: :arm64
  depends_on :macos
  depends_on "python@3.15"

  # The Python resources are written for each release by
  # `brew update-python-resources`.

  resource "ifaddr" do
    url "https://files.pythonhosted.org/packages/e8/ac/fb4c578f4a3256561548cd825646680edcadb9440f3f68add95ade1eb791/ifaddr-0.2.0.tar.gz"
    sha256 "cc0cbfcaabf765d44595825fb96a99bb12c79716b73b44330ea38ee2b0c4aed4"
  end

  resource "pycryptodome" do
    url "https://files.pythonhosted.org/packages/33/c7/f9374c8939560ab22db1dd9dbe215b62d20f32634aeb7f259dc03c807b44/pycryptodome-4.2.0.tar.gz"
    sha256 "21d7fdba239d6ef863d3d08388801c683453a3bb4897c2b27f27847aad89bdf7"
  end

  resource "zeroconf" do
    url "https://files.pythonhosted.org/packages/29/94/0fe7b7361a22a1a31017d3c7f112fc35a7b9df1fc25ed9bf1e3cd3d01b73/zeroconf-0.151.6.tar.gz"
    sha256 "496fc3355e88b8e312705916955245fc261aab03e73cb3022536380d42e4d406"
  end

  resource "zopfli" do
    url "https://files.pythonhosted.org/packages/74/21/3b6af43a663b22b00e738bb0642931a2579e15da6852613d56c6aa535d28/zopfli-0.4.3.tar.gz"
    sha256 "d3a50f91a13cea9bafe025de8fd87a005eb26de02a4f0c193127ddbf23ac8ebe"
  end

  def install
    virtualenv_install_with_resources
    # The device payloads deploy copies to the Time Capsule.
    (libexec/"distribution").install "bin"
    # Homebrew's own command: its messages say `tcapsule`, and it finds the
    # payloads above. Its settings live in the user's folder, apart from the
    # Mac app's, since every upgrade replaces this versioned Cellar folder.
    # A TCAPSULE_CONFIG or TCAPSULE_STATE_DIR the user sets still wins.
    settings = "$HOME/Library/Application Support/TimeCapsuleSMB/CLI"
    rm bin/"tcapsule"
    (bin/"tcapsule").write_env_script libexec/"bin/tcapsule",
      TCAPSULE_CLIENT:            "homebrew",
      TCAPSULE_DISTRIBUTION_ROOT: libexec/"distribution",
      TCAPSULE_STATE_DIR:         "${TCAPSULE_STATE_DIR:-#{settings}}",
      TCAPSULE_CONFIG:            "${TCAPSULE_CONFIG:-#{settings}/.env}"
  end

  test do
    assert_equal "tcapsule #{version}", shell_output("#{bin}/tcapsule --version").strip
    # The Python packages import, and every payload deploy copies is where the
    # wrapper points with the hash the release lists. An empty token keeps the
    # test out of telemetry.
    ENV["TCAPSULE_TELEMETRY_TOKEN"] = ""
    # The wrapper's TCAPSULE_CLIENT reaches Python: Homebrew needs no bootstrap.
    assert_match "nothing to bootstrap", shell_output("#{bin}/tcapsule bootstrap")
    assert JSON.parse(shell_output("#{bin}/tcapsule validate-install --json"))["ok"]
    # Its settings are in the user's folder, not the Cellar.
    paths = JSON.parse(shell_output("#{bin}/tcapsule paths --json"))
    assert_equal "#{Dir.home}/Library/Application Support/TimeCapsuleSMB/CLI/.env", paths["config_path"]
  end
end
