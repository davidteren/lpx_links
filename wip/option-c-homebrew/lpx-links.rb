# Homebrew formula for lpx_links
# Place this in a homebrew-tap repo as Formula/lpx-links.rb
class LpxLinks < Formula
  desc "Download links for Logic Pro, MainStage, and GarageBand content"
  homepage "https://github.com/davidteren/lpx_links"
  url "https://github.com/davidteren/lpx_links/archive/refs/tags/v1.0.0.tar.gz"
  # TODO: Update sha256 after creating the v1.0.0 tag/release
  sha256 "PLACEHOLDER"
  license "MIT"

  depends_on "aria2" => :recommended

  def install
    libexec.install "lpx_links.rb", "lib"
    (bin/"lpx-links").write <<~EOS
      #!/bin/bash
      exec ruby "#{libexec}/lpx_links.rb" "$@"
    EOS
  end

  test do
    assert_match "Logic", shell_output("#{bin}/lpx-links --help")
  end
end
