Vagrant.configure(2) do |config|
  config.vm.box = "dreamscapes/archlinux"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.synced_folder "linux/", "/linux"

  config.vm.provision "shell", inline: <<-SHELL
    [ ! -d ~/.gnupg ] && dirmngr < /dev/null
    pacman-key --refresh-keys
    pacman --needed --noconfirm -Syu base-devel bc help2man wget gperf vim quilt cmake
  SHELL
end
