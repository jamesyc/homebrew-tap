class Tcapsule < Formula
  include Language::Python::Virtualenv

  desc "Install Samba 4 on Apple Time Capsules and AirPort Extremes"
  homepage "https://github.com/jamesyc/TimeCapsuleSMB"
  url "https://github.com/jamesyc/TimeCapsuleSMB/archive/refs/tags/v3.8.4.tar.gz"
  sha256 "ebcd29580022dc0b32dcc47e384d03270421dd21caac9c5694f12936d05dcda5"
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
    url "https://files.pythonhosted.org/packages/61/52/6bf92ead9cfcfc788d9f07f2f8dad4592b190d36ed3d26a5985bbf95ff5d/pycryptodome-4.3.0.tar.gz"
    sha256 "663fc5e1c4a3562d00c3a9b265fb94ef5f68c6085d982638b83e713af5487c06"
  end

  resource "zeroconf" do
    url "https://files.pythonhosted.org/packages/c2/ad/e321ee148e871fdb257e9fd5840748d06a72db132815ecb47d42d13b1a3a/zeroconf-0.153.0.tar.gz"
    sha256 "28bd0baa208f4ea481a386e9eefdd3a65663fada34233432301a0c221d741d1d"
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
