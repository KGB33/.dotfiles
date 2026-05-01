{ vm, ... }:
{
  vm.base.provides = {
    gui.includes = [
      vm.base
      vm.bootable.provides.gui
    ];

    tui.includes = [
      vm.base
      vm.bootable.provides.tui
    ];
  };
}
