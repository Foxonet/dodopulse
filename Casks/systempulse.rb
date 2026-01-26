cask "systempulse" do
  version "1.0.1"
  sha256 "c8af7c84aa6c7a05838bd09b89eb17075a2b82f8505a800d365d2bc8d8bb3e70"

  url "https://github.com/bluewave-labs/systempulse/releases/download/v#{version}/SystemPulse-#{version}.dmg"
  name "SystemPulse"
  desc "Lightweight macOS menu bar system monitor"
  homepage "https://github.com/bluewave-labs/systempulse"

  # Requires macOS 12.0 Monterey or later
  depends_on macos: ">= :monterey"

  app "SystemPulse.app"

  zap trash: [
    "~/Library/Preferences/com.bluewave-labs.systempulse.plist",
  ]

  caveats <<~EOS
    SystemPulse is not notarized. On first launch, you may need to:
    1. Right-click the app and select "Open"
    2. Click "Open" in the security dialog

    Or run: xattr -cr /Applications/SystemPulse.app
  EOS
end
