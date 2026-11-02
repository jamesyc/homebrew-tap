cask "timecapsulesmb" do
  version "3.8.2"
  sha256 "c1ddef6bdd2fc1a2cf4cd0ad5c5433d9e482b0f304e52570af779ea612289321"

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
