class Wpsync < Formula
  desc "WordPress Live → Lokal: zieht Sites schonend in DDEV-Projekte"
  homepage "https://github.com/UserMind2018/wpsync"
  url "https://github.com/UserMind2018/wpsync/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "d184ace3b32187e7b59c91f2bf00f0ea630e92f169e5c58efa0fe39c86bb434f"
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
      cp "wpsync-agent.php", "pkg/wpsync-agent/"
      cp Dir["src/*.php"], "pkg/wpsync-agent/src/"
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
  end
end
