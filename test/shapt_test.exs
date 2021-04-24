defmodule ShaptTest do
  use ExUnit.Case

  describe "__using__ macro has been applied to module" do
    test "module includes all functions" do
      expected_functions = [
        child_spec: 1,
        start_link: 1,
        all_values: 0,
        reload: 0,
        enabled?: 1,
        expired?: 1,
        expired_toggles: 0,
        template: 0,
        toggle: 2,
        feature_x: 0,
        feature_y: 0
      ]

      functions = TestShapt.__info__(:functions)

      assert [] == functions -- expected_functions
    end
  end

  describe "expired?/1" do
    test "delegates to helper with no worker running" do
      refute TestShapt.expired?(:feature_x)
    end
  end

  describe "expired_toggles/0" do
    test "delegates to helper with no worker running" do
      assert [] == TestShapt.expired_toggles()
    end
  end

  describe "template/0" do
    test "delegates to helper with no worker running" do
      assert "A=false\nB=false" == TestShapt.template()
    end
  end

  describe "worker tests" do
    test "start_link/1" do
      assert {:ok, pid} = TestShapt.start_link([])
      GenServer.stop(pid, :normal)
    end

    test "all_values/0" do
      assert {:ok, pid} = TestShapt.start_link([])
      assert %{feature_x: false, feature_y: false} == TestShapt.all_values()

      GenServer.stop(pid, :normal)
    end

    test "enabled?/1" do
      assert {:ok, pid} = TestShapt.start_link([])
      assert false == TestShapt.enabled?(:feature_x)

      GenServer.stop(pid, :normal)
    end

    test "toggle/2" do
      assert {:ok, pid} = TestShapt.start_link([])
      assert 1 == TestShapt.toggle(:feature_x, off: 1)

      GenServer.stop(pid, :normal)
    end

    test "feature_x/0" do
      assert {:ok, pid} = TestShapt.start_link([])
      assert false == TestShapt.feature_x()

      GenServer.stop(pid, :normal)
    end

    test "feature_y/0" do
      assert {:ok, pid} = TestShapt.start_link([])
      assert false == TestShapt.feature_y()

      GenServer.stop(pid, :normal)
    end

    test "reload/0" do
      assert {:ok, pid} = TestShapt.start_link([])
      assert false == TestShapt.feature_y()

      System.put_env("B", "true")

      assert :ok == TestShapt.reload()
      assert true == TestShapt.feature_y()

      System.put_env("B", "")
      GenServer.stop(pid, :normal)
    end
  end
end
