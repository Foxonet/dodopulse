cask "dodopulse" do
  version "1.1.1"
  sha256 "669812429370ba6e6fb3f0d8224bb59a18d29c6b50440483dc999fe47045d040"

  url "https://github.com/dodoapps/dodopulse/releases/download/v#{version}/DodoPulse-#{version}.dmg"
  name "DodoPulse"
  desc "Lightweight macOS menu bar system monitor"
  homepage "https://github.com/dodoapps/dodopulse"

  # Requires macOS 12.0 Monterey or later
  depends_on macos: ">= :monterey"

  app "DodoPulse.app"

  zap trash: [
    "~/Library/Preferences/com.bluewave-labs.dodopulse.plist",
  ]

  caveats <<~EOS
    DodoPulse is not notarized. On first launch, you may need to:
    1. Right-click the app and select "Open"
    2. Click "Open" in the security dialog

    Or run: xattr -cr /Applications/DodoPulse.app
  EOS
end
