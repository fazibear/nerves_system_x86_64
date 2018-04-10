defmodule Example do
  @moduledoc """
  Documentation for Example.
  """

  def init do
  end

  def startx do
    spawn(fn -> MuonTrap.cmd("X", []) end)
    |> Process.register(Xorg)
    System.put_env("DISPLAY", ":0")
  end

  def xeyes do
    spawn(fn -> MuonTrap.cmd("", []) end)
    |> Process.register(Xeyes)
  end
end
