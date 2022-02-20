defmodule Shapt.MockTest do
  use ExUnit.Case, async: true
  doctest Shapt.Mock

  describe "full test cycle using Shapt.Mock" do
    test "toggle was set" do
      assert :ok == Shapt.Mock.cleanup()
      assert :ok == Shapt.Mock.set(A, %{toggle_x: true, toggle_y: false})

      assert Shapt.Mock.enabled?(A, :toggle_x)
      assert false == Shapt.Mock.enabled?(A, :toggle_y)

      assert :ok == Shapt.Mock.cleanup()
      refute Process.get(Shapt.Mock)
    end

    test "toggle wasn't set" do
      assert :ok == Shapt.Mock.cleanup()
      assert false == Shapt.Mock.enabled?(A, :toggle_x)
    end

    test "setup for 2 toggle modules" do
      assert :ok == Shapt.Mock.cleanup()
      assert :ok == Shapt.Mock.set(A, %{toggle_x: true, toggle_y: false})
      assert :ok == Shapt.Mock.set(B, %{toggle_x: false, toggle_y: true})

      assert true == Shapt.Mock.enabled?(A, :toggle_x)
      assert false == Shapt.Mock.enabled?(A, :toggle_y)
      assert false == Shapt.Mock.enabled?(B, :toggle_x)
      assert true == Shapt.Mock.enabled?(B, :toggle_y)

      assert :ok == Shapt.Mock.cleanup()
      refute Process.get(Shapt.Mock)
    end
  end
end 
