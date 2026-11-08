cask "timecapsulesmb" do
  version "3.8.5"
  sha256 "43ef1d62f2e35ef5e5a4787fc2fbaf1918cd6a1ea944c628e6f753bf00162b9d"

  url "https://github.com/jamesyc/TimeCapsuleSMB/releases/download/v#{version}/TimeCapsuleSMB.dmg"
  name "TimeCapsuleSMB"
  desc "Install Samba 4 on Apple Time Capsules and AirPort Extremes"
  homepage "https://github.com/jamesyc/TimeCapsuleSMB"

  # The app updates itself with Sparkle.
  auto_updates true
  depends_on macos: :sonoma

  app "TimeCapsuleSMB.app"

  # Application Support/TimeCapsuleSMB stays: it holds the flash backups the
  # tcapsule CLI writes too.
  zap trash: [
    "~/Library/Caches/com.timecapsulesmb.TimeCapsuleSMB",
    "~/Library/HTTPStorages/com.timecapsulesmb.TimeCapsuleSMB",
    "~/Library/HTTPStorages/com.timecapsulesmb.TimeCapsuleSMB.binarycookies",
    "~/Library/Preferences/com.timecapsulesmb.TimeCapsuleSMB.plist",
    "~/Library/Saved Application State/com.timecapsulesmb.TimeCapsuleSMB.savedState",
  ]
end
