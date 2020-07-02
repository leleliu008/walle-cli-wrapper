class WalleCli < Formula
  desc     "Android Signature V2 Scheme签名下的新一代渠道包打包神器"
  homepage "https://github.com/Meituan-Dianping/walle"
  url      "https://raw.githubusercontent.com/leleliu008/walle-cli-wrapper/master/walle-cli-1.1.6.tar.gz"
  sha256   "e041c4e3fd2bb4e3d8c6a61f3ef81581c7444bd919a1a3ac5c6279e13b44e9ce"
  
  def install
    bin.install "bin/walle"
    lib.install "lib/walle-cli-all.jar"
    zsh_completion.install "zsh-completion/_walle" => "_walle"
  end

  test do
    system "#{bin}/walle", "--help"
  end
end
