defmodule Example do
  @moduledoc """
  Documentation for Example.
  """

  def init do
    :os.cmd('udevd -d');
    :os.cmd('udevadm trigger --type=subsystems --action=add');
    :os.cmd('udevadm trigger --type=devices --action=add');
    :os.cmd('udevadm settle --timeout=30');
  end

  def startx do
    spawn(fn -> MuonTrap.cmd("X", []) end)
    |> Process.register(Xorg)

    System.put_env("DISPLAY", ":0")
  end

  def xeyes do
    spawn(fn -> MuonTrap.cmd("xeyes", []) end)
    |> Process.register(Xeyes)
  end

  def xlog do
    exec('cat /tmp/Xorg.0.log')
  end

  defp exec(cmd) do
    cmd
    |> :os.cmd
    |> IO.puts
  end
end
