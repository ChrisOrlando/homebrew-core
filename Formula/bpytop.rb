class Bpytop < Formula
  include Language::Python::Virtualenv

  desc "Linux/OSX/FreeBSD resource monitor"
  homepage "https://github.com/aristocratos/bpytop"
  url "https://files.pythonhosted.org/packages/8d/6a/506756ced98883e2016681da1719156cb9a41a456cd0b2e4449c2b734e0f/bpytop-1.0.56.tar.gz"
  sha256 "ac8dd7f69ff590ec22049df293899bf9e6eea297e8ccf5c84e849158f9dc2c2f"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "f6b7bac9098bfb473522e887da0bc86dbe7034312e82f67a4ab80044cac4d4b0" => :big_sur
    sha256 "11821985c646b976851a88eb90735a8131a36f7de0df46c383194517dfb09488" => :arm64_big_sur
    sha256 "98335a3bd72380b75612e81a9f8cbf105e20f95fba2fb9a20c61c933741c5d78" => :catalina
    sha256 "6aa06be2e6cba56d365cdb8e5581fb3226369450840eb1c0e9ceb3dae9d7e9dd" => :mojave
  end

  depends_on "python@3.9"
  on_macos do
    depends_on "osx-cpu-temp"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/e1/b0/7276de53321c12981717490516b7e612364f2cb372ee8901bd4a66a000d7/psutil-5.8.0.tar.gz"
    sha256 "0c9ccb99ab76025f2f0bbecf341d4656e9c1351db8cc8a03ccd62e318ab4b5c6"
  end

  def install
    virtualenv_install_with_resources
    pkgshare.install "bpytop-themes" => "themes"
  end

  test do
    config = (testpath/".config/bpytop")
    (config/"bpytop.conf").write <<~EOS
      #? Config file for bpytop v. #{version}

      update_ms=2000
      log_level=DEBUG
    EOS

    require "pty"
    require "io/console"

    r, w, pid = PTY.spawn("#{bin}/bpytop")
    r.winsize = [80, 130]
    sleep 5
    w.write "\cC"

    log = (config/"error.log").read
    assert_match "bpytop version #{version} started with pid #{pid}", log
    assert_not_match /ERROR:/, log
  ensure
    Process.kill("TERM", pid)
  end
end
