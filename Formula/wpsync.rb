class Wpsync < Formula
  desc "WordPress Live → Lokal: zieht Sites schonend in DDEV-Projekte"
  homepage "https://github.com/UserMind2018/wpsync"
  url "https://github.com/UserMind2018/wpsync/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "71f23f6654a57874d9af1a85d8d6ca2d6796b78323d8513cfec7b91226ce620c"
  head "https://github.com/UserMind2018/wpsync.git", branch: "main"

  depends_on "go" => :build
  depends_on :macos

  def install
    cd "cli" do
      ldflags = "-s -w -X github.com/usermind/wpsync/internal/agentapi.Version=#{version}"
      system "go", "build", *std_go_args(ldflags:), "./cmd/wpsync"
    end

    # Agent-Plugin-ZIP wie agent/build.sh, ohne PHP-Lint (PHP ist keine Build-Abhängigkeit)
    cd "agent" do
      mkdir_p "pkg/wpsync-agent/src"
      mkdir_p "pkg/wpsync-agent/staging"
      cp ["wpsync-agent.php", "rescue.php"], "pkg/wpsync-agent/"
      cp Dir["src/*.php"], "pkg/wpsync-agent/src/"
      cp Dir["staging/*.php"], "pkg/wpsync-agent/staging/" # Riegel der Staging-Kopie (seit 0.4.0)
      cp "../LICENSE", "pkg/wpsync-agent/LICENSE"
      cd "pkg" do
        system "zip", "-qr", "wpsync-agent.zip", "wpsync-agent"
        pkgshare.install "wpsync-agent.zip"
      end
    end
  end

  def caveats
    <<~EOS
      wpsync braucht Docker (≥ 25, z. B. OrbStack) und DDEV – beides installiert der Tap nicht mit.
      Einmal pro Mac:
        wpsync setup

      Agent-Plugin für die Live-Site (WP-Admin → Plugins → Plugin hochladen):
        #{opt_pkgshare}/wpsync-agent.zip
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wpsync version")
    assert_path_exists pkgshare/"wpsync-agent.zip"
    assert_match "wpsync-agent/staging/00-wpsync-staging.php", shell_output("unzip -l #{pkgshare}/wpsync-agent.zip")
  end
end
