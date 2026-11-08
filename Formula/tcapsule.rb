class Tcapsule < Formula
  include Language::Python::Virtualenv

  desc "Install Samba 4 on Apple Time Capsules and AirPort Extremes"
  homepage "https://github.com/jamesyc/TimeCapsuleSMB"
  url "https://github.com/jamesyc/TimeCapsuleSMB/archive/refs/tags/v3.8.5.tar.gz"
  sha256 "baf99eef0334bbe2e6d75ba03bc64b1aa04277758997e48ad0b5961dc1659093"
  license "GPL-3.0-only"

  depends_on "python@3.15"

  # On Linux, doctor's SMB checks use smbclient; on macOS they use smbutil.
  on_linux do
    depends_on "samba"
  end

  # The Python resources are written for each release by
  # `brew update-python-resources`.

  resource "ifaddr" do
    url "https://files.pythonhosted.org/packages/e8/ac/fb4c578f4a3256561548cd825646680edcadb9440f3f68add95ade1eb791/ifaddr-0.2.0.tar.gz"
    sha256 "cc0cbfcaabf765d44595825fb96a99bb12c79716b73b44330ea38ee2b0c4aed4"
  end

  resource "pycryptodome" do
    url "https://files.pythonhosted.org/packages/51/f2/ccbeb91d186b2323fc99986499d2da3caab2151b1c2fb2ef74f7488d8934/pycryptodome-4.4.0.tar.gz"
    sha256 "eab7620c60c85f3fa251d026ec06e094f036d96187bebb9752e46fbcebabbb55"
  end

  resource "zeroconf" do
    url "https://files.pythonhosted.org/packages/d6/dd/b1eb6a87dc0376289fb78c13231c4702797da49dd0da062c5d46a4cff865/zeroconf-0.154.0.tar.gz"
    sha256 "830315497af9bbd75924c2218cd3b64f0bde0e808ee316aabb5d9288836c0c43"
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
    # payloads above. Its settings live in the user's data folder, the one
    # its flash backups use, since every upgrade replaces this versioned
    # Cellar folder; on macOS they sit apart from the Mac app's.
    # A TCAPSULE_CONFIG or TCAPSULE_STATE_DIR the user sets still wins.
    settings = if OS.mac?
      "$HOME/Library/Application Support/TimeCapsuleSMB/CLI"
    else
      "${XDG_DATA_HOME:-$HOME/.local/share}/timecapsulesmb/CLI"
    end
    rm bin/"tcapsule"
    (bin/"tcapsule").write_env_script libexec/"bin/tcapsule",
      TCAPSULE_CLIENT:            "homebrew",
      TCAPSULE_DISTRIBUTION_ROOT: libexec/"distribution",
      TCAPSULE_STATE_DIR:         "${TCAPSULE_STATE_DIR:-#{settings}}",
      TCAPSULE_CONFIG:            "${TCAPSULE_CONFIG:-#{settings}/.env}"
  end

  test do
    assert_equal "tcapsule #{version}", shell_output("#{bin}/tcapsule --version").strip
    # An empty token keeps the test out of telemetry.
    ENV["TCAPSULE_TELEMETRY_TOKEN"] = ""
    # The wrapper's TCAPSULE_CLIENT reaches Python: Homebrew needs no bootstrap.
    assert_match "nothing to bootstrap", shell_output("#{bin}/tcapsule bootstrap")
    assert JSON.parse(shell_output("#{bin}/tcapsule validate-install --json"))["ok"]
    # Its settings are in the user's folder, not the Cellar.
    paths = JSON.parse(shell_output("#{bin}/tcapsule paths --json"))
    settings = if OS.mac?
      "#{Dir.home}/Library/Application Support/TimeCapsuleSMB/CLI"
    else
      "#{ENV.fetch("XDG_DATA_HOME", "").presence || "#{Dir.home}/.local/share"}/timecapsulesmb/CLI"
    end
    assert_equal "#{settings}/.env", paths["config_path"]
  end
end
