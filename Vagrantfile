Vagrant.configure(2) do |config|
  config.vm.box = "dreamscapes/archlinux"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    [ ! -d ~/.gnupg ] && dirmngr < /dev/null
    pacman-key --refresh-keys
    pacman --needed --noconfirm -Syu base-devel bc help2man wget gperf vim quilt
  SHELL

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    curl https://aur.archlinux.org/cgit/aur.git/snapshot/crosstool-ng.tar.gz | tar xzf -
    (
      cd crosstool-ng
      makepkg -i --noconfirm
    )
    rm -rf crosstool-ng
  SHELL
end
