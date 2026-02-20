{ config, pkgs, lib, ... }:

let
  winapps-src = pkgs.fetchFromGitHub {
    owner = "winapps-org";
    repo = "winapps";
    rev = "860710bb26e5afb040dd83b312a5a7afeee2d0bb";
    hash = "sha256-TlN8gw6C8csT875yTpUC31AKSVM2pVHXzA26Eo0tcEM=";
  };

  winapps = pkgs.writeShellApplication {
    name = "winapps";
    runtimeInputs = with pkgs; [
      freerdp
      dialog
      libnotify
      iproute2
      netcat-gnu
    ];
    text = builtins.readFile "${winapps-src}/bin/winapps";
    checkPhase = ""; # 外部スクリプトのため shellcheck を無効化
  };

  winapps-setup = pkgs.writeShellApplication {
    name = "winapps-setup";
    runtimeInputs = with pkgs; [ freerdp dialog libnotify iproute2 netcat-gnu ];
    text = builtins.readFile "${winapps-src}/setup.sh";
    checkPhase = ""; # 外部スクリプトのため shellcheck を無効化
  };

  # Windows 11 VM 起動スクリプト
  # OVMF_VARS は書き込み可能コピーが必要なため ~/.vm/ に置く
  start-windows-vm = pkgs.writeShellApplication {
    name = "start-windows-vm";
    runtimeInputs = with pkgs; [ qemu_kvm swtpm ];
    text = ''
      VM_DIR="$HOME/.vm"
      OVMF_CODE="${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd"
      OVMF_VARS="$VM_DIR/OVMF_VARS.fd"
      DISK="$VM_DIR/windows11.qcow2"

      # 初回: OVMF_VARS のユーザーコピーを作成
      if [ ! -f "$OVMF_VARS" ]; then
        cp "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd" "$OVMF_VARS"
        chmod 600 "$OVMF_VARS"
      fi

      # swtpm (TPM 2.0) の起動
      mkdir -p "$VM_DIR/tpm"
      swtpm socket \
        --tpmstate dir="$VM_DIR/tpm" \
        --ctrl type=unixio,path="$VM_DIR/tpm/swtpm.sock" \
        --tpm2 --daemon

      # QEMU 起動（KVM + UEFI + RDP ポートフォワーディング）
      exec qemu-system-x86_64 \
        -enable-kvm \
        -machine type=q35,accel=kvm \
        -cpu host \
        -m 8192 \
        -smp cores=4,threads=2 \
        -drive if=pflash,format=raw,unit=0,file="$OVMF_CODE",readonly=on \
        -drive if=pflash,format=raw,unit=1,file="$OVMF_VARS" \
        -device virtio-scsi-pci \
        -drive file="$DISK",if=none,id=drive0,format=qcow2 \
        -device scsi-hd,drive=drive0 \
        -chardev socket,id=chrtpm,path="$VM_DIR/tpm/swtpm.sock" \
        -tpmdev emulator,id=tpm0,chardev=chrtpm \
        -device tpm-tis,tpmdev=tpm0 \
        -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:3389-:3389 \
        -device virtio-vga \
        -device virtio-balloon \
        -chardev socket,path="$VM_DIR/qmp.sock",server=on,wait=off,id=qmp \
        -mon chardev=qmp,mode=control \
        -display gtk,grab-on-hover=on \
        "$@"
    '';
  };

in {
  environment.systemPackages = [ winapps winapps-setup start-windows-vm ];
}
